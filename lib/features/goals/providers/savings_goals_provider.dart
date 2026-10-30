import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/currency/currency_provider.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/providers/time_filter_provider.dart';

final savingsGoalsProvider =
    AsyncNotifierProvider<SavingsGoalsNotifier, List<SavingsGoalRow>>(
      SavingsGoalsNotifier.new,
    );

/// Contributions and releases of the goals that still exist. Deleting a goal
/// undoes its reservations, so its history no longer counts in any period;
/// the rows stay in the database for undo and backups.
final savingsGoalContributionsProvider =
    FutureProvider<List<SavingsGoalContributionRow>>((ref) async {
      ref.watch(savingsGoalsProvider);
      final db = ref.read(databaseProvider);
      final query =
          db.select(db.savingsGoalContributions).join([
              innerJoin(
                db.savingsGoals,
                db.savingsGoals.id.equalsExp(
                  db.savingsGoalContributions.goalId,
                ),
              ),
            ])
            ..where(db.savingsGoals.archived.equals(false))
            ..orderBy([
              OrderingTerm.desc(db.savingsGoalContributions.createdAt),
            ]);
      return [
        for (final row in await query.get())
          row.readTable(db.savingsGoalContributions),
      ];
    });

/// Money set aside in the selected period. A release of money reserved in an
/// earlier period cannot make it negative: that period simply reserved
/// nothing. Over the whole history the sum stays exact.
int reservedInSelection(
  Iterable<SavingsGoalContributionRow> contributions,
  TimeFilterState timeState,
) {
  final net = contributions
      .where((row) => isInSelectedTimeWindow(row.createdAt, timeState))
      .fold<int>(0, (total, row) => total + row.amountMinor);
  return net < 0 ? 0 : net;
}

class SavingsGoalRemoval {
  final SavingsGoalRow goal;
  final String? releaseContributionId;

  const SavingsGoalRemoval({
    required this.goal,
    required this.releaseContributionId,
  });
}

class SavingsGoalsNotifier extends AsyncNotifier<List<SavingsGoalRow>> {
  final _uuid = const Uuid();

  @override
  Future<List<SavingsGoalRow>> build() async {
    ref.watch(currencyProvider.select((value) => value.value?.baseCurrency));
    final db = ref.read(databaseProvider);
    return (db.select(db.savingsGoals)
          ..where((row) => row.archived.equals(false))
          ..orderBy([
            (row) => OrderingTerm.asc(row.completed),
            (row) => OrderingTerm.asc(row.dueDate),
            (row) => OrderingTerm.asc(row.createdAt),
          ]))
        .get();
  }

  Future<void> addGoal({
    required String name,
    required int targetAmountMinor,
    DateTime? dueDate,
  }) async {
    final currency = ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    final conversion = await ref
        .read(currencyProvider.notifier)
        .convert(amountMinor: targetAmountMinor, sourceCurrency: currency);
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    await db
        .into(db.savingsGoals)
        .insert(
          SavingsGoalRow(
            id: _uuid.v4(),
            name: name.trim(),
            targetAmountMinor: targetAmountMinor,
            savedAmountMinor: 0,
            targetEurMicros: conversion.eurAmountMicros,
            savedEurMicros: 0,
            currencyCode: currency,
            dueDate: dueDate,
            icon: IconsFlag.savings,
            color: 0xFF4F46E5,
            completed: false,
            archived: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
    ref.invalidateSelf();
  }

  Future<void> contribute(String id, int amountMinor) async {
    if (amountMinor <= 0) throw ArgumentError.value(amountMinor, 'amountMinor');
    final currency = ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    final conversion = await ref
        .read(currencyProvider.notifier)
        .convert(amountMinor: amountMinor, sourceCurrency: currency);
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      final current = await (db.select(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).getSingle();
      final remaining = current.targetAmountMinor - current.savedAmountMinor;
      if (amountMinor > remaining) {
        throw StateError('The contribution exceeds the remaining target.');
      }
      final now = DateTime.now();
      final saved = current.savedAmountMinor + amountMinor;
      await db
          .into(db.savingsGoalContributions)
          .insert(
            SavingsGoalContributionRow(
              id: _uuid.v4(),
              goalId: id,
              amountMinor: amountMinor,
              eurAmountMicros: conversion.eurAmountMicros,
              currencyCode: currency,
              createdAt: now,
            ),
          );
      await (db.update(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).write(
        SavingsGoalsCompanion(
          savedAmountMinor: Value(saved),
          savedEurMicros: Value(
            current.savedEurMicros + conversion.eurAmountMicros,
          ),
          completed: Value(saved >= current.targetAmountMinor),
          updatedAt: Value(now),
        ),
      );
    });
    ref.invalidateSelf();
  }

  Future<void> release(String id, int amountMinor) async {
    if (amountMinor <= 0) throw ArgumentError.value(amountMinor, 'amountMinor');
    final currency = ref.read(currencyProvider).value?.baseCurrency ?? 'EUR';
    final conversion = await ref
        .read(currencyProvider.notifier)
        .convert(amountMinor: amountMinor, sourceCurrency: currency);
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      final current = await (db.select(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).getSingle();
      if (amountMinor > current.savedAmountMinor) {
        throw StateError('The release exceeds the reserved amount.');
      }
      final now = DateTime.now();
      final saved = current.savedAmountMinor - amountMinor;
      final savedEur = amountMinor == current.savedAmountMinor
          ? 0
          : (current.savedEurMicros - conversion.eurAmountMicros)
                .clamp(0, current.savedEurMicros)
                .toInt();
      await db
          .into(db.savingsGoalContributions)
          .insert(
            SavingsGoalContributionRow(
              id: _uuid.v4(),
              goalId: id,
              amountMinor: -amountMinor,
              eurAmountMicros: -conversion.eurAmountMicros,
              currencyCode: currency,
              createdAt: now,
            ),
          );
      await (db.update(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).write(
        SavingsGoalsCompanion(
          savedAmountMinor: Value(saved),
          savedEurMicros: Value(savedEur),
          completed: const Value(false),
          updatedAt: Value(now),
        ),
      );
    });
    ref.invalidateSelf();
  }

  Future<SavingsGoalRemoval> remove(String id) async {
    final db = ref.read(databaseProvider);
    late SavingsGoalRemoval removal;
    await db.transaction(() async {
      final goal = await (db.select(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).getSingle();
      final now = DateTime.now();
      String? releaseId;
      if (goal.savedAmountMinor > 0) {
        releaseId = _uuid.v4();
        await db
            .into(db.savingsGoalContributions)
            .insert(
              SavingsGoalContributionRow(
                id: releaseId,
                goalId: id,
                amountMinor: -goal.savedAmountMinor,
                eurAmountMicros: -goal.savedEurMicros,
                currencyCode: goal.currencyCode,
                createdAt: now,
              ),
            );
      }
      await (db.update(
        db.savingsGoals,
      )..where((row) => row.id.equals(id))).write(
        SavingsGoalsCompanion(
          savedAmountMinor: const Value(0),
          savedEurMicros: const Value(0),
          completed: const Value(false),
          archived: const Value(true),
          updatedAt: Value(now),
        ),
      );
      removal = SavingsGoalRemoval(
        goal: goal,
        releaseContributionId: releaseId,
      );
    });
    ref.invalidateSelf();
    return removal;
  }

  Future<void> restore(SavingsGoalRemoval removal) async {
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      final releaseId = removal.releaseContributionId;
      if (releaseId != null) {
        await (db.delete(
          db.savingsGoalContributions,
        )..where((row) => row.id.equals(releaseId))).go();
      }
      await db.into(db.savingsGoals).insertOnConflictUpdate(removal.goal);
    });
    ref.invalidateSelf();
  }
}

abstract final class IconsFlag {
  static const savings = 0xe2eb;
}
