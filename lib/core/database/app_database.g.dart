// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, Transaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isRecurringMeta = const VerificationMeta(
    'isRecurring',
  );
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
    'is_recurring',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_recurring" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalCurrencyMeta = const VerificationMeta(
    'originalCurrency',
  );
  @override
  late final GeneratedColumn<String> originalCurrency = GeneratedColumn<String>(
    'original_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eurAmountMicrosMeta = const VerificationMeta(
    'eurAmountMicros',
  );
  @override
  late final GeneratedColumn<int> eurAmountMicros = GeneratedColumn<int>(
    'eur_amount_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exchangeRateToEurMeta = const VerificationMeta(
    'exchangeRateToEur',
  );
  @override
  late final GeneratedColumn<double> exchangeRateToEur =
      GeneratedColumn<double>(
        'exchange_rate_to_eur',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _receiptPathMeta = const VerificationMeta(
    'receiptPath',
  );
  @override
  late final GeneratedColumn<String> receiptPath = GeneratedColumn<String>(
    'receipt_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringSourceIdMeta = const VerificationMeta(
    'recurringSourceId',
  );
  @override
  late final GeneratedColumn<String> recurringSourceId =
      GeneratedColumn<String>(
        'recurring_source_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recurringOccurrenceKeyMeta =
      const VerificationMeta('recurringOccurrenceKey');
  @override
  late final GeneratedColumn<String> recurringOccurrenceKey =
      GeneratedColumn<String>(
        'recurring_occurrence_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountCents,
    isIncome,
    categoryId,
    note,
    date,
    isRecurring,
    originalAmountMinor,
    originalCurrency,
    eurAmountMicros,
    exchangeRateToEur,
    receiptPath,
    createdAt,
    recurringSourceId,
    recurringOccurrenceKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    } else if (isInserting) {
      context.missing(_isIncomeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
        _isRecurringMeta,
        isRecurring.isAcceptableOrUnknown(
          data['is_recurring']!,
          _isRecurringMeta,
        ),
      );
    }
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('original_currency')) {
      context.handle(
        _originalCurrencyMeta,
        originalCurrency.isAcceptableOrUnknown(
          data['original_currency']!,
          _originalCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('eur_amount_micros')) {
      context.handle(
        _eurAmountMicrosMeta,
        eurAmountMicros.isAcceptableOrUnknown(
          data['eur_amount_micros']!,
          _eurAmountMicrosMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate_to_eur')) {
      context.handle(
        _exchangeRateToEurMeta,
        exchangeRateToEur.isAcceptableOrUnknown(
          data['exchange_rate_to_eur']!,
          _exchangeRateToEurMeta,
        ),
      );
    }
    if (data.containsKey('receipt_path')) {
      context.handle(
        _receiptPathMeta,
        receiptPath.isAcceptableOrUnknown(
          data['receipt_path']!,
          _receiptPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('recurring_source_id')) {
      context.handle(
        _recurringSourceIdMeta,
        recurringSourceId.isAcceptableOrUnknown(
          data['recurring_source_id']!,
          _recurringSourceIdMeta,
        ),
      );
    }
    if (data.containsKey('recurring_occurrence_key')) {
      context.handle(
        _recurringOccurrenceKeyMeta,
        recurringOccurrenceKey.isAcceptableOrUnknown(
          data['recurring_occurrence_key']!,
          _recurringOccurrenceKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {recurringOccurrenceKey},
  ];
  @override
  Transaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isRecurring: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_recurring'],
      )!,
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      ),
      originalCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency'],
      ),
      eurAmountMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eur_amount_micros'],
      ),
      exchangeRateToEur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate_to_eur'],
      ),
      receiptPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      recurringSourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_source_id'],
      ),
      recurringOccurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurring_occurrence_key'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class Transaction extends DataClass implements Insertable<Transaction> {
  final String id;
  final int amountCents;
  final bool isIncome;
  final String categoryId;
  final String? note;
  final DateTime date;
  final bool isRecurring;
  final int? originalAmountMinor;
  final String? originalCurrency;
  final int? eurAmountMicros;
  final double? exchangeRateToEur;
  final String? receiptPath;
  final DateTime? createdAt;
  final String? recurringSourceId;
  final String? recurringOccurrenceKey;
  const Transaction({
    required this.id,
    required this.amountCents,
    required this.isIncome,
    required this.categoryId,
    this.note,
    required this.date,
    required this.isRecurring,
    this.originalAmountMinor,
    this.originalCurrency,
    this.eurAmountMicros,
    this.exchangeRateToEur,
    this.receiptPath,
    this.createdAt,
    this.recurringSourceId,
    this.recurringOccurrenceKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['is_income'] = Variable<bool>(isIncome);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['date'] = Variable<DateTime>(date);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || originalAmountMinor != null) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    }
    if (!nullToAbsent || originalCurrency != null) {
      map['original_currency'] = Variable<String>(originalCurrency);
    }
    if (!nullToAbsent || eurAmountMicros != null) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros);
    }
    if (!nullToAbsent || exchangeRateToEur != null) {
      map['exchange_rate_to_eur'] = Variable<double>(exchangeRateToEur);
    }
    if (!nullToAbsent || receiptPath != null) {
      map['receipt_path'] = Variable<String>(receiptPath);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || recurringSourceId != null) {
      map['recurring_source_id'] = Variable<String>(recurringSourceId);
    }
    if (!nullToAbsent || recurringOccurrenceKey != null) {
      map['recurring_occurrence_key'] = Variable<String>(
        recurringOccurrenceKey,
      );
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      isIncome: Value(isIncome),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      date: Value(date),
      isRecurring: Value(isRecurring),
      originalAmountMinor: originalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountMinor),
      originalCurrency: originalCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCurrency),
      eurAmountMicros: eurAmountMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(eurAmountMicros),
      exchangeRateToEur: exchangeRateToEur == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateToEur),
      receiptPath: receiptPath == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptPath),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      recurringSourceId: recurringSourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringSourceId),
      recurringOccurrenceKey: recurringOccurrenceKey == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringOccurrenceKey),
    );
  }

  factory Transaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transaction(
      id: serializer.fromJson<String>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      originalAmountMinor: serializer.fromJson<int?>(
        json['originalAmountMinor'],
      ),
      originalCurrency: serializer.fromJson<String?>(json['originalCurrency']),
      eurAmountMicros: serializer.fromJson<int?>(json['eurAmountMicros']),
      exchangeRateToEur: serializer.fromJson<double?>(
        json['exchangeRateToEur'],
      ),
      receiptPath: serializer.fromJson<String?>(json['receiptPath']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      recurringSourceId: serializer.fromJson<String?>(
        json['recurringSourceId'],
      ),
      recurringOccurrenceKey: serializer.fromJson<String?>(
        json['recurringOccurrenceKey'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'isIncome': serializer.toJson<bool>(isIncome),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String?>(note),
      'date': serializer.toJson<DateTime>(date),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'originalAmountMinor': serializer.toJson<int?>(originalAmountMinor),
      'originalCurrency': serializer.toJson<String?>(originalCurrency),
      'eurAmountMicros': serializer.toJson<int?>(eurAmountMicros),
      'exchangeRateToEur': serializer.toJson<double?>(exchangeRateToEur),
      'receiptPath': serializer.toJson<String?>(receiptPath),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'recurringSourceId': serializer.toJson<String?>(recurringSourceId),
      'recurringOccurrenceKey': serializer.toJson<String?>(
        recurringOccurrenceKey,
      ),
    };
  }

  Transaction copyWith({
    String? id,
    int? amountCents,
    bool? isIncome,
    String? categoryId,
    Value<String?> note = const Value.absent(),
    DateTime? date,
    bool? isRecurring,
    Value<int?> originalAmountMinor = const Value.absent(),
    Value<String?> originalCurrency = const Value.absent(),
    Value<int?> eurAmountMicros = const Value.absent(),
    Value<double?> exchangeRateToEur = const Value.absent(),
    Value<String?> receiptPath = const Value.absent(),
    Value<DateTime?> createdAt = const Value.absent(),
    Value<String?> recurringSourceId = const Value.absent(),
    Value<String?> recurringOccurrenceKey = const Value.absent(),
  }) => Transaction(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    isIncome: isIncome ?? this.isIncome,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    date: date ?? this.date,
    isRecurring: isRecurring ?? this.isRecurring,
    originalAmountMinor: originalAmountMinor.present
        ? originalAmountMinor.value
        : this.originalAmountMinor,
    originalCurrency: originalCurrency.present
        ? originalCurrency.value
        : this.originalCurrency,
    eurAmountMicros: eurAmountMicros.present
        ? eurAmountMicros.value
        : this.eurAmountMicros,
    exchangeRateToEur: exchangeRateToEur.present
        ? exchangeRateToEur.value
        : this.exchangeRateToEur,
    receiptPath: receiptPath.present ? receiptPath.value : this.receiptPath,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    recurringSourceId: recurringSourceId.present
        ? recurringSourceId.value
        : this.recurringSourceId,
    recurringOccurrenceKey: recurringOccurrenceKey.present
        ? recurringOccurrenceKey.value
        : this.recurringOccurrenceKey,
  );
  Transaction copyWithCompanion(TransactionsCompanion data) {
    return Transaction(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      isRecurring: data.isRecurring.present
          ? data.isRecurring.value
          : this.isRecurring,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      originalCurrency: data.originalCurrency.present
          ? data.originalCurrency.value
          : this.originalCurrency,
      eurAmountMicros: data.eurAmountMicros.present
          ? data.eurAmountMicros.value
          : this.eurAmountMicros,
      exchangeRateToEur: data.exchangeRateToEur.present
          ? data.exchangeRateToEur.value
          : this.exchangeRateToEur,
      receiptPath: data.receiptPath.present
          ? data.receiptPath.value
          : this.receiptPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      recurringSourceId: data.recurringSourceId.present
          ? data.recurringSourceId.value
          : this.recurringSourceId,
      recurringOccurrenceKey: data.recurringOccurrenceKey.present
          ? data.recurringOccurrenceKey.value
          : this.recurringOccurrenceKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transaction(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('isIncome: $isIncome, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('exchangeRateToEur: $exchangeRateToEur, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('recurringSourceId: $recurringSourceId, ')
          ..write('recurringOccurrenceKey: $recurringOccurrenceKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    isIncome,
    categoryId,
    note,
    date,
    isRecurring,
    originalAmountMinor,
    originalCurrency,
    eurAmountMicros,
    exchangeRateToEur,
    receiptPath,
    createdAt,
    recurringSourceId,
    recurringOccurrenceKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transaction &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.isIncome == this.isIncome &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.date == this.date &&
          other.isRecurring == this.isRecurring &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.originalCurrency == this.originalCurrency &&
          other.eurAmountMicros == this.eurAmountMicros &&
          other.exchangeRateToEur == this.exchangeRateToEur &&
          other.receiptPath == this.receiptPath &&
          other.createdAt == this.createdAt &&
          other.recurringSourceId == this.recurringSourceId &&
          other.recurringOccurrenceKey == this.recurringOccurrenceKey);
}

class TransactionsCompanion extends UpdateCompanion<Transaction> {
  final Value<String> id;
  final Value<int> amountCents;
  final Value<bool> isIncome;
  final Value<String> categoryId;
  final Value<String?> note;
  final Value<DateTime> date;
  final Value<bool> isRecurring;
  final Value<int?> originalAmountMinor;
  final Value<String?> originalCurrency;
  final Value<int?> eurAmountMicros;
  final Value<double?> exchangeRateToEur;
  final Value<String?> receiptPath;
  final Value<DateTime?> createdAt;
  final Value<String?> recurringSourceId;
  final Value<String?> recurringOccurrenceKey;
  final Value<int> rowid;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.exchangeRateToEur = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recurringSourceId = const Value.absent(),
    this.recurringOccurrenceKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionsCompanion.insert({
    required String id,
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    this.note = const Value.absent(),
    required DateTime date,
    this.isRecurring = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.exchangeRateToEur = const Value.absent(),
    this.receiptPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.recurringSourceId = const Value.absent(),
    this.recurringOccurrenceKey = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountCents = Value(amountCents),
       isIncome = Value(isIncome),
       categoryId = Value(categoryId),
       date = Value(date);
  static Insertable<Transaction> custom({
    Expression<String>? id,
    Expression<int>? amountCents,
    Expression<bool>? isIncome,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<bool>? isRecurring,
    Expression<int>? originalAmountMinor,
    Expression<String>? originalCurrency,
    Expression<int>? eurAmountMicros,
    Expression<double>? exchangeRateToEur,
    Expression<String>? receiptPath,
    Expression<DateTime>? createdAt,
    Expression<String>? recurringSourceId,
    Expression<String>? recurringOccurrenceKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (isIncome != null) 'is_income': isIncome,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (originalCurrency != null) 'original_currency': originalCurrency,
      if (eurAmountMicros != null) 'eur_amount_micros': eurAmountMicros,
      if (exchangeRateToEur != null) 'exchange_rate_to_eur': exchangeRateToEur,
      if (receiptPath != null) 'receipt_path': receiptPath,
      if (createdAt != null) 'created_at': createdAt,
      if (recurringSourceId != null) 'recurring_source_id': recurringSourceId,
      if (recurringOccurrenceKey != null)
        'recurring_occurrence_key': recurringOccurrenceKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountCents,
    Value<bool>? isIncome,
    Value<String>? categoryId,
    Value<String?>? note,
    Value<DateTime>? date,
    Value<bool>? isRecurring,
    Value<int?>? originalAmountMinor,
    Value<String?>? originalCurrency,
    Value<int?>? eurAmountMicros,
    Value<double?>? exchangeRateToEur,
    Value<String?>? receiptPath,
    Value<DateTime?>? createdAt,
    Value<String?>? recurringSourceId,
    Value<String?>? recurringOccurrenceKey,
    Value<int>? rowid,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      isIncome: isIncome ?? this.isIncome,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
      exchangeRateToEur: exchangeRateToEur ?? this.exchangeRateToEur,
      receiptPath: receiptPath ?? this.receiptPath,
      createdAt: createdAt ?? this.createdAt,
      recurringSourceId: recurringSourceId ?? this.recurringSourceId,
      recurringOccurrenceKey:
          recurringOccurrenceKey ?? this.recurringOccurrenceKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (originalCurrency.present) {
      map['original_currency'] = Variable<String>(originalCurrency.value);
    }
    if (eurAmountMicros.present) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros.value);
    }
    if (exchangeRateToEur.present) {
      map['exchange_rate_to_eur'] = Variable<double>(exchangeRateToEur.value);
    }
    if (receiptPath.present) {
      map['receipt_path'] = Variable<String>(receiptPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (recurringSourceId.present) {
      map['recurring_source_id'] = Variable<String>(recurringSourceId.value);
    }
    if (recurringOccurrenceKey.present) {
      map['recurring_occurrence_key'] = Variable<String>(
        recurringOccurrenceKey.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('isIncome: $isIncome, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('exchangeRateToEur: $exchangeRateToEur, ')
          ..write('receiptPath: $receiptPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('recurringSourceId: $recurringSourceId, ')
          ..write('recurringOccurrenceKey: $recurringOccurrenceKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isIncome,
    icon,
    color,
    isDefault,
    lastUsedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    } else if (isInserting) {
      context.missing(_isIncomeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final bool isIncome;
  final int icon;
  final int color;
  final bool isDefault;
  final DateTime? lastUsedAt;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.isIncome,
    required this.icon,
    required this.color,
    required this.isDefault,
    this.lastUsedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_income'] = Variable<bool>(isIncome);
    map['icon'] = Variable<int>(icon);
    map['color'] = Variable<int>(color);
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      isIncome: Value(isIncome),
      icon: Value(icon),
      color: Value(color),
      isDefault: Value(isDefault),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      icon: serializer.fromJson<int>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      lastUsedAt: serializer.fromJson<DateTime?>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isIncome': serializer.toJson<bool>(isIncome),
      'icon': serializer.toJson<int>(icon),
      'color': serializer.toJson<int>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'lastUsedAt': serializer.toJson<DateTime?>(lastUsedAt),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    bool? isIncome,
    int? icon,
    int? color,
    bool? isDefault,
    Value<DateTime?> lastUsedAt = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    isIncome: isIncome ?? this.isIncome,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    isDefault: isDefault ?? this.isDefault,
    lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isIncome: $isIncome, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, isIncome, icon, color, isDefault, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.isIncome == this.isIncome &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.lastUsedAt == this.lastUsedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isIncome;
  final Value<int> icon;
  final Value<int> color;
  final Value<bool> isDefault;
  final Value<DateTime?> lastUsedAt;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required bool isIncome,
    required int icon,
    required int color,
    this.isDefault = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       isIncome = Value(isIncome),
       icon = Value(icon),
       color = Value(color);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isIncome,
    Expression<int>? icon,
    Expression<int>? color,
    Expression<bool>? isDefault,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isIncome != null) 'is_income': isIncome,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isIncome,
    Value<int>? icon,
    Value<int>? color,
    Value<bool>? isDefault,
    Value<DateTime?>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isIncome: isIncome ?? this.isIncome,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isIncome: $isIncome, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayOfMonthMeta = const VerificationMeta(
    'dayOfMonth',
  );
  @override
  late final GeneratedColumn<int> dayOfMonth = GeneratedColumn<int>(
    'day_of_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastGeneratedMeta = const VerificationMeta(
    'lastGenerated',
  );
  @override
  late final GeneratedColumn<DateTime> lastGenerated =
      GeneratedColumn<DateTime>(
        'last_generated',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _originalAmountMinorMeta =
      const VerificationMeta('originalAmountMinor');
  @override
  late final GeneratedColumn<int> originalAmountMinor = GeneratedColumn<int>(
    'original_amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalCurrencyMeta = const VerificationMeta(
    'originalCurrency',
  );
  @override
  late final GeneratedColumn<String> originalCurrency = GeneratedColumn<String>(
    'original_currency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eurAmountMicrosMeta = const VerificationMeta(
    'eurAmountMicros',
  );
  @override
  late final GeneratedColumn<int> eurAmountMicros = GeneratedColumn<int>(
    'eur_amount_micros',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exchangeRateToEurMeta = const VerificationMeta(
    'exchangeRateToEur',
  );
  @override
  late final GeneratedColumn<double> exchangeRateToEur =
      GeneratedColumn<double>(
        'exchange_rate_to_eur',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthOfYearMeta = const VerificationMeta(
    'monthOfYear',
  );
  @override
  late final GeneratedColumn<int> monthOfYear = GeneratedColumn<int>(
    'month_of_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amountCents,
    isIncome,
    categoryId,
    dayOfMonth,
    startDate,
    note,
    active,
    lastGenerated,
    originalAmountMinor,
    originalCurrency,
    eurAmountMicros,
    exchangeRateToEur,
    frequency,
    interval,
    dayOfWeek,
    monthOfYear,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    } else if (isInserting) {
      context.missing(_isIncomeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('day_of_month')) {
      context.handle(
        _dayOfMonthMeta,
        dayOfMonth.isAcceptableOrUnknown(
          data['day_of_month']!,
          _dayOfMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dayOfMonthMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('last_generated')) {
      context.handle(
        _lastGeneratedMeta,
        lastGenerated.isAcceptableOrUnknown(
          data['last_generated']!,
          _lastGeneratedMeta,
        ),
      );
    }
    if (data.containsKey('original_amount_minor')) {
      context.handle(
        _originalAmountMinorMeta,
        originalAmountMinor.isAcceptableOrUnknown(
          data['original_amount_minor']!,
          _originalAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('original_currency')) {
      context.handle(
        _originalCurrencyMeta,
        originalCurrency.isAcceptableOrUnknown(
          data['original_currency']!,
          _originalCurrencyMeta,
        ),
      );
    }
    if (data.containsKey('eur_amount_micros')) {
      context.handle(
        _eurAmountMicrosMeta,
        eurAmountMicros.isAcceptableOrUnknown(
          data['eur_amount_micros']!,
          _eurAmountMicrosMeta,
        ),
      );
    }
    if (data.containsKey('exchange_rate_to_eur')) {
      context.handle(
        _exchangeRateToEurMeta,
        exchangeRateToEur.isAcceptableOrUnknown(
          data['exchange_rate_to_eur']!,
          _exchangeRateToEurMeta,
        ),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    }
    if (data.containsKey('month_of_year')) {
      context.handle(
        _monthOfYearMeta,
        monthOfYear.isAcceptableOrUnknown(
          data['month_of_year']!,
          _monthOfYearMeta,
        ),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      dayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_month'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      lastGenerated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_generated'],
      ),
      originalAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_amount_minor'],
      ),
      originalCurrency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_currency'],
      ),
      eurAmountMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eur_amount_micros'],
      ),
      exchangeRateToEur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exchange_rate_to_eur'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      ),
      monthOfYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month_of_year'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_date'],
      ),
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransaction extends DataClass
    implements Insertable<RecurringTransaction> {
  final String id;
  final int amountCents;
  final bool isIncome;
  final String categoryId;
  final int dayOfMonth;
  final DateTime startDate;
  final String? note;

  /// NUOVO
  final bool active;
  final DateTime? lastGenerated;
  final int? originalAmountMinor;
  final String? originalCurrency;
  final int? eurAmountMicros;
  final double? exchangeRateToEur;
  final String frequency;
  final int interval;
  final int? dayOfWeek;
  final int? monthOfYear;
  final DateTime? endDate;
  const RecurringTransaction({
    required this.id,
    required this.amountCents,
    required this.isIncome,
    required this.categoryId,
    required this.dayOfMonth,
    required this.startDate,
    this.note,
    required this.active,
    this.lastGenerated,
    this.originalAmountMinor,
    this.originalCurrency,
    this.eurAmountMicros,
    this.exchangeRateToEur,
    required this.frequency,
    required this.interval,
    this.dayOfWeek,
    this.monthOfYear,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount_cents'] = Variable<int>(amountCents);
    map['is_income'] = Variable<bool>(isIncome);
    map['category_id'] = Variable<String>(categoryId);
    map['day_of_month'] = Variable<int>(dayOfMonth);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || lastGenerated != null) {
      map['last_generated'] = Variable<DateTime>(lastGenerated);
    }
    if (!nullToAbsent || originalAmountMinor != null) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor);
    }
    if (!nullToAbsent || originalCurrency != null) {
      map['original_currency'] = Variable<String>(originalCurrency);
    }
    if (!nullToAbsent || eurAmountMicros != null) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros);
    }
    if (!nullToAbsent || exchangeRateToEur != null) {
      map['exchange_rate_to_eur'] = Variable<double>(exchangeRateToEur);
    }
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    if (!nullToAbsent || dayOfWeek != null) {
      map['day_of_week'] = Variable<int>(dayOfWeek);
    }
    if (!nullToAbsent || monthOfYear != null) {
      map['month_of_year'] = Variable<int>(monthOfYear);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      amountCents: Value(amountCents),
      isIncome: Value(isIncome),
      categoryId: Value(categoryId),
      dayOfMonth: Value(dayOfMonth),
      startDate: Value(startDate),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      active: Value(active),
      lastGenerated: lastGenerated == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGenerated),
      originalAmountMinor: originalAmountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(originalAmountMinor),
      originalCurrency: originalCurrency == null && nullToAbsent
          ? const Value.absent()
          : Value(originalCurrency),
      eurAmountMicros: eurAmountMicros == null && nullToAbsent
          ? const Value.absent()
          : Value(eurAmountMicros),
      exchangeRateToEur: exchangeRateToEur == null && nullToAbsent
          ? const Value.absent()
          : Value(exchangeRateToEur),
      frequency: Value(frequency),
      interval: Value(interval),
      dayOfWeek: dayOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(dayOfWeek),
      monthOfYear: monthOfYear == null && nullToAbsent
          ? const Value.absent()
          : Value(monthOfYear),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory RecurringTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransaction(
      id: serializer.fromJson<String>(json['id']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      dayOfMonth: serializer.fromJson<int>(json['dayOfMonth']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      note: serializer.fromJson<String?>(json['note']),
      active: serializer.fromJson<bool>(json['active']),
      lastGenerated: serializer.fromJson<DateTime?>(json['lastGenerated']),
      originalAmountMinor: serializer.fromJson<int?>(
        json['originalAmountMinor'],
      ),
      originalCurrency: serializer.fromJson<String?>(json['originalCurrency']),
      eurAmountMicros: serializer.fromJson<int?>(json['eurAmountMicros']),
      exchangeRateToEur: serializer.fromJson<double?>(
        json['exchangeRateToEur'],
      ),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      dayOfWeek: serializer.fromJson<int?>(json['dayOfWeek']),
      monthOfYear: serializer.fromJson<int?>(json['monthOfYear']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amountCents': serializer.toJson<int>(amountCents),
      'isIncome': serializer.toJson<bool>(isIncome),
      'categoryId': serializer.toJson<String>(categoryId),
      'dayOfMonth': serializer.toJson<int>(dayOfMonth),
      'startDate': serializer.toJson<DateTime>(startDate),
      'note': serializer.toJson<String?>(note),
      'active': serializer.toJson<bool>(active),
      'lastGenerated': serializer.toJson<DateTime?>(lastGenerated),
      'originalAmountMinor': serializer.toJson<int?>(originalAmountMinor),
      'originalCurrency': serializer.toJson<String?>(originalCurrency),
      'eurAmountMicros': serializer.toJson<int?>(eurAmountMicros),
      'exchangeRateToEur': serializer.toJson<double?>(exchangeRateToEur),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'dayOfWeek': serializer.toJson<int?>(dayOfWeek),
      'monthOfYear': serializer.toJson<int?>(monthOfYear),
      'endDate': serializer.toJson<DateTime?>(endDate),
    };
  }

  RecurringTransaction copyWith({
    String? id,
    int? amountCents,
    bool? isIncome,
    String? categoryId,
    int? dayOfMonth,
    DateTime? startDate,
    Value<String?> note = const Value.absent(),
    bool? active,
    Value<DateTime?> lastGenerated = const Value.absent(),
    Value<int?> originalAmountMinor = const Value.absent(),
    Value<String?> originalCurrency = const Value.absent(),
    Value<int?> eurAmountMicros = const Value.absent(),
    Value<double?> exchangeRateToEur = const Value.absent(),
    String? frequency,
    int? interval,
    Value<int?> dayOfWeek = const Value.absent(),
    Value<int?> monthOfYear = const Value.absent(),
    Value<DateTime?> endDate = const Value.absent(),
  }) => RecurringTransaction(
    id: id ?? this.id,
    amountCents: amountCents ?? this.amountCents,
    isIncome: isIncome ?? this.isIncome,
    categoryId: categoryId ?? this.categoryId,
    dayOfMonth: dayOfMonth ?? this.dayOfMonth,
    startDate: startDate ?? this.startDate,
    note: note.present ? note.value : this.note,
    active: active ?? this.active,
    lastGenerated: lastGenerated.present
        ? lastGenerated.value
        : this.lastGenerated,
    originalAmountMinor: originalAmountMinor.present
        ? originalAmountMinor.value
        : this.originalAmountMinor,
    originalCurrency: originalCurrency.present
        ? originalCurrency.value
        : this.originalCurrency,
    eurAmountMicros: eurAmountMicros.present
        ? eurAmountMicros.value
        : this.eurAmountMicros,
    exchangeRateToEur: exchangeRateToEur.present
        ? exchangeRateToEur.value
        : this.exchangeRateToEur,
    frequency: frequency ?? this.frequency,
    interval: interval ?? this.interval,
    dayOfWeek: dayOfWeek.present ? dayOfWeek.value : this.dayOfWeek,
    monthOfYear: monthOfYear.present ? monthOfYear.value : this.monthOfYear,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  RecurringTransaction copyWithCompanion(RecurringTransactionsCompanion data) {
    return RecurringTransaction(
      id: data.id.present ? data.id.value : this.id,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      dayOfMonth: data.dayOfMonth.present
          ? data.dayOfMonth.value
          : this.dayOfMonth,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      note: data.note.present ? data.note.value : this.note,
      active: data.active.present ? data.active.value : this.active,
      lastGenerated: data.lastGenerated.present
          ? data.lastGenerated.value
          : this.lastGenerated,
      originalAmountMinor: data.originalAmountMinor.present
          ? data.originalAmountMinor.value
          : this.originalAmountMinor,
      originalCurrency: data.originalCurrency.present
          ? data.originalCurrency.value
          : this.originalCurrency,
      eurAmountMicros: data.eurAmountMicros.present
          ? data.eurAmountMicros.value
          : this.eurAmountMicros,
      exchangeRateToEur: data.exchangeRateToEur.present
          ? data.exchangeRateToEur.value
          : this.exchangeRateToEur,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      monthOfYear: data.monthOfYear.present
          ? data.monthOfYear.value
          : this.monthOfYear,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransaction(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('isIncome: $isIncome, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startDate: $startDate, ')
          ..write('note: $note, ')
          ..write('active: $active, ')
          ..write('lastGenerated: $lastGenerated, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('exchangeRateToEur: $exchangeRateToEur, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('monthOfYear: $monthOfYear, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amountCents,
    isIncome,
    categoryId,
    dayOfMonth,
    startDate,
    note,
    active,
    lastGenerated,
    originalAmountMinor,
    originalCurrency,
    eurAmountMicros,
    exchangeRateToEur,
    frequency,
    interval,
    dayOfWeek,
    monthOfYear,
    endDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransaction &&
          other.id == this.id &&
          other.amountCents == this.amountCents &&
          other.isIncome == this.isIncome &&
          other.categoryId == this.categoryId &&
          other.dayOfMonth == this.dayOfMonth &&
          other.startDate == this.startDate &&
          other.note == this.note &&
          other.active == this.active &&
          other.lastGenerated == this.lastGenerated &&
          other.originalAmountMinor == this.originalAmountMinor &&
          other.originalCurrency == this.originalCurrency &&
          other.eurAmountMicros == this.eurAmountMicros &&
          other.exchangeRateToEur == this.exchangeRateToEur &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.dayOfWeek == this.dayOfWeek &&
          other.monthOfYear == this.monthOfYear &&
          other.endDate == this.endDate);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransaction> {
  final Value<String> id;
  final Value<int> amountCents;
  final Value<bool> isIncome;
  final Value<String> categoryId;
  final Value<int> dayOfMonth;
  final Value<DateTime> startDate;
  final Value<String?> note;
  final Value<bool> active;
  final Value<DateTime?> lastGenerated;
  final Value<int?> originalAmountMinor;
  final Value<String?> originalCurrency;
  final Value<int?> eurAmountMicros;
  final Value<double?> exchangeRateToEur;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<int?> dayOfWeek;
  final Value<int?> monthOfYear;
  final Value<DateTime?> endDate;
  final Value<int> rowid;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.dayOfMonth = const Value.absent(),
    this.startDate = const Value.absent(),
    this.note = const Value.absent(),
    this.active = const Value.absent(),
    this.lastGenerated = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.exchangeRateToEur = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.monthOfYear = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    required String id,
    required int amountCents,
    required bool isIncome,
    required String categoryId,
    required int dayOfMonth,
    required DateTime startDate,
    this.note = const Value.absent(),
    this.active = const Value.absent(),
    this.lastGenerated = const Value.absent(),
    this.originalAmountMinor = const Value.absent(),
    this.originalCurrency = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.exchangeRateToEur = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.monthOfYear = const Value.absent(),
    this.endDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amountCents = Value(amountCents),
       isIncome = Value(isIncome),
       categoryId = Value(categoryId),
       dayOfMonth = Value(dayOfMonth),
       startDate = Value(startDate);
  static Insertable<RecurringTransaction> custom({
    Expression<String>? id,
    Expression<int>? amountCents,
    Expression<bool>? isIncome,
    Expression<String>? categoryId,
    Expression<int>? dayOfMonth,
    Expression<DateTime>? startDate,
    Expression<String>? note,
    Expression<bool>? active,
    Expression<DateTime>? lastGenerated,
    Expression<int>? originalAmountMinor,
    Expression<String>? originalCurrency,
    Expression<int>? eurAmountMicros,
    Expression<double>? exchangeRateToEur,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<int>? dayOfWeek,
    Expression<int>? monthOfYear,
    Expression<DateTime>? endDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountCents != null) 'amount_cents': amountCents,
      if (isIncome != null) 'is_income': isIncome,
      if (categoryId != null) 'category_id': categoryId,
      if (dayOfMonth != null) 'day_of_month': dayOfMonth,
      if (startDate != null) 'start_date': startDate,
      if (note != null) 'note': note,
      if (active != null) 'active': active,
      if (lastGenerated != null) 'last_generated': lastGenerated,
      if (originalAmountMinor != null)
        'original_amount_minor': originalAmountMinor,
      if (originalCurrency != null) 'original_currency': originalCurrency,
      if (eurAmountMicros != null) 'eur_amount_micros': eurAmountMicros,
      if (exchangeRateToEur != null) 'exchange_rate_to_eur': exchangeRateToEur,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (monthOfYear != null) 'month_of_year': monthOfYear,
      if (endDate != null) 'end_date': endDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amountCents,
    Value<bool>? isIncome,
    Value<String>? categoryId,
    Value<int>? dayOfMonth,
    Value<DateTime>? startDate,
    Value<String?>? note,
    Value<bool>? active,
    Value<DateTime?>? lastGenerated,
    Value<int?>? originalAmountMinor,
    Value<String?>? originalCurrency,
    Value<int?>? eurAmountMicros,
    Value<double?>? exchangeRateToEur,
    Value<String>? frequency,
    Value<int>? interval,
    Value<int?>? dayOfWeek,
    Value<int?>? monthOfYear,
    Value<DateTime?>? endDate,
    Value<int>? rowid,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      amountCents: amountCents ?? this.amountCents,
      isIncome: isIncome ?? this.isIncome,
      categoryId: categoryId ?? this.categoryId,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      startDate: startDate ?? this.startDate,
      note: note ?? this.note,
      active: active ?? this.active,
      lastGenerated: lastGenerated ?? this.lastGenerated,
      originalAmountMinor: originalAmountMinor ?? this.originalAmountMinor,
      originalCurrency: originalCurrency ?? this.originalCurrency,
      eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
      exchangeRateToEur: exchangeRateToEur ?? this.exchangeRateToEur,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      endDate: endDate ?? this.endDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (dayOfMonth.present) {
      map['day_of_month'] = Variable<int>(dayOfMonth.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (lastGenerated.present) {
      map['last_generated'] = Variable<DateTime>(lastGenerated.value);
    }
    if (originalAmountMinor.present) {
      map['original_amount_minor'] = Variable<int>(originalAmountMinor.value);
    }
    if (originalCurrency.present) {
      map['original_currency'] = Variable<String>(originalCurrency.value);
    }
    if (eurAmountMicros.present) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros.value);
    }
    if (exchangeRateToEur.present) {
      map['exchange_rate_to_eur'] = Variable<double>(exchangeRateToEur.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (monthOfYear.present) {
      map['month_of_year'] = Variable<int>(monthOfYear.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amountCents: $amountCents, ')
          ..write('isIncome: $isIncome, ')
          ..write('categoryId: $categoryId, ')
          ..write('dayOfMonth: $dayOfMonth, ')
          ..write('startDate: $startDate, ')
          ..write('note: $note, ')
          ..write('active: $active, ')
          ..write('lastGenerated: $lastGenerated, ')
          ..write('originalAmountMinor: $originalAmountMinor, ')
          ..write('originalCurrency: $originalCurrency, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('exchangeRateToEur: $exchangeRateToEur, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('monthOfYear: $monthOfYear, ')
          ..write('endDate: $endDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eurAmountMicrosMeta = const VerificationMeta(
    'eurAmountMicros',
  );
  @override
  late final GeneratedColumn<int> eurAmountMicros = GeneratedColumn<int>(
    'eur_amount_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodTypeMeta = const VerificationMeta(
    'periodType',
  );
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
    'period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _rolloverMeta = const VerificationMeta(
    'rollover',
  );
  @override
  late final GeneratedColumn<bool> rollover = GeneratedColumn<bool>(
    'rollover',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("rollover" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    categoryId,
    amountMinor,
    eurAmountMicros,
    periodType,
    rollover,
    active,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BudgetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('eur_amount_micros')) {
      context.handle(
        _eurAmountMicrosMeta,
        eurAmountMicros.isAcceptableOrUnknown(
          data['eur_amount_micros']!,
          _eurAmountMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eurAmountMicrosMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
        _periodTypeMeta,
        periodType.isAcceptableOrUnknown(data['period_type']!, _periodTypeMeta),
      );
    }
    if (data.containsKey('rollover')) {
      context.handle(
        _rolloverMeta,
        rollover.isAcceptableOrUnknown(data['rollover']!, _rolloverMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {categoryId},
  ];
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      eurAmountMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eur_amount_micros'],
      )!,
      periodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_type'],
      )!,
      rollover: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}rollover'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String id;
  final String categoryId;
  final int amountMinor;
  final int eurAmountMicros;
  final String periodType;
  final bool rollover;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BudgetRow({
    required this.id,
    required this.categoryId,
    required this.amountMinor,
    required this.eurAmountMicros,
    required this.periodType,
    required this.rollover,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category_id'] = Variable<String>(categoryId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['eur_amount_micros'] = Variable<int>(eurAmountMicros);
    map['period_type'] = Variable<String>(periodType);
    map['rollover'] = Variable<bool>(rollover);
    map['active'] = Variable<bool>(active);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      categoryId: Value(categoryId),
      amountMinor: Value(amountMinor),
      eurAmountMicros: Value(eurAmountMicros),
      periodType: Value(periodType),
      rollover: Value(rollover),
      active: Value(active),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BudgetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<String>(json['id']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      eurAmountMicros: serializer.fromJson<int>(json['eurAmountMicros']),
      periodType: serializer.fromJson<String>(json['periodType']),
      rollover: serializer.fromJson<bool>(json['rollover']),
      active: serializer.fromJson<bool>(json['active']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'categoryId': serializer.toJson<String>(categoryId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'eurAmountMicros': serializer.toJson<int>(eurAmountMicros),
      'periodType': serializer.toJson<String>(periodType),
      'rollover': serializer.toJson<bool>(rollover),
      'active': serializer.toJson<bool>(active),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BudgetRow copyWith({
    String? id,
    String? categoryId,
    int? amountMinor,
    int? eurAmountMicros,
    String? periodType,
    bool? rollover,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BudgetRow(
    id: id ?? this.id,
    categoryId: categoryId ?? this.categoryId,
    amountMinor: amountMinor ?? this.amountMinor,
    eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
    periodType: periodType ?? this.periodType,
    rollover: rollover ?? this.rollover,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      eurAmountMicros: data.eurAmountMicros.present
          ? data.eurAmountMicros.value
          : this.eurAmountMicros,
      periodType: data.periodType.present
          ? data.periodType.value
          : this.periodType,
      rollover: data.rollover.present ? data.rollover.value : this.rollover,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('periodType: $periodType, ')
          ..write('rollover: $rollover, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    categoryId,
    amountMinor,
    eurAmountMicros,
    periodType,
    rollover,
    active,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.eurAmountMicros == this.eurAmountMicros &&
          other.periodType == this.periodType &&
          other.rollover == this.rollover &&
          other.active == this.active &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> id;
  final Value<String> categoryId;
  final Value<int> amountMinor;
  final Value<int> eurAmountMicros;
  final Value<String> periodType;
  final Value<bool> rollover;
  final Value<bool> active;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.periodType = const Value.absent(),
    this.rollover = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    required String categoryId,
    required int amountMinor,
    required int eurAmountMicros,
    this.periodType = const Value.absent(),
    this.rollover = const Value.absent(),
    this.active = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       categoryId = Value(categoryId),
       amountMinor = Value(amountMinor),
       eurAmountMicros = Value(eurAmountMicros),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BudgetRow> custom({
    Expression<String>? id,
    Expression<String>? categoryId,
    Expression<int>? amountMinor,
    Expression<int>? eurAmountMicros,
    Expression<String>? periodType,
    Expression<bool>? rollover,
    Expression<bool>? active,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (eurAmountMicros != null) 'eur_amount_micros': eurAmountMicros,
      if (periodType != null) 'period_type': periodType,
      if (rollover != null) 'rollover': rollover,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? categoryId,
    Value<int>? amountMinor,
    Value<int>? eurAmountMicros,
    Value<String>? periodType,
    Value<bool>? rollover,
    Value<bool>? active,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BudgetsCompanion(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
      periodType: periodType ?? this.periodType,
      rollover: rollover ?? this.rollover,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (eurAmountMicros.present) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (rollover.present) {
      map['rollover'] = Variable<bool>(rollover.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('periodType: $periodType, ')
          ..write('rollover: $rollover, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategorizationRulesTable extends CategorizationRules
    with TableInfo<$CategorizationRulesTable, CategorizationRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategorizationRulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _matchTypeMeta = const VerificationMeta(
    'matchType',
  );
  @override
  late final GeneratedColumn<String> matchType = GeneratedColumn<String>(
    'match_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('contains'),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'is_income',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_income" IN (0, 1))',
    ),
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pattern,
    matchType,
    categoryId,
    isIncome,
    priority,
    enabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorization_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategorizationRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('match_type')) {
      context.handle(
        _matchTypeMeta,
        matchType.isAcceptableOrUnknown(data['match_type']!, _matchTypeMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_income')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['is_income']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategorizationRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategorizationRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      matchType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}match_type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_income'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CategorizationRulesTable createAlias(String alias) {
    return $CategorizationRulesTable(attachedDatabase, alias);
  }
}

class CategorizationRuleRow extends DataClass
    implements Insertable<CategorizationRuleRow> {
  final String id;
  final String pattern;
  final String matchType;
  final String categoryId;
  final bool? isIncome;
  final int priority;
  final bool enabled;
  final DateTime createdAt;
  const CategorizationRuleRow({
    required this.id,
    required this.pattern,
    required this.matchType,
    required this.categoryId,
    this.isIncome,
    required this.priority,
    required this.enabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pattern'] = Variable<String>(pattern);
    map['match_type'] = Variable<String>(matchType);
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || isIncome != null) {
      map['is_income'] = Variable<bool>(isIncome);
    }
    map['priority'] = Variable<int>(priority);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CategorizationRulesCompanion toCompanion(bool nullToAbsent) {
    return CategorizationRulesCompanion(
      id: Value(id),
      pattern: Value(pattern),
      matchType: Value(matchType),
      categoryId: Value(categoryId),
      isIncome: isIncome == null && nullToAbsent
          ? const Value.absent()
          : Value(isIncome),
      priority: Value(priority),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory CategorizationRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategorizationRuleRow(
      id: serializer.fromJson<String>(json['id']),
      pattern: serializer.fromJson<String>(json['pattern']),
      matchType: serializer.fromJson<String>(json['matchType']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      isIncome: serializer.fromJson<bool?>(json['isIncome']),
      priority: serializer.fromJson<int>(json['priority']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'pattern': serializer.toJson<String>(pattern),
      'matchType': serializer.toJson<String>(matchType),
      'categoryId': serializer.toJson<String>(categoryId),
      'isIncome': serializer.toJson<bool?>(isIncome),
      'priority': serializer.toJson<int>(priority),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CategorizationRuleRow copyWith({
    String? id,
    String? pattern,
    String? matchType,
    String? categoryId,
    Value<bool?> isIncome = const Value.absent(),
    int? priority,
    bool? enabled,
    DateTime? createdAt,
  }) => CategorizationRuleRow(
    id: id ?? this.id,
    pattern: pattern ?? this.pattern,
    matchType: matchType ?? this.matchType,
    categoryId: categoryId ?? this.categoryId,
    isIncome: isIncome.present ? isIncome.value : this.isIncome,
    priority: priority ?? this.priority,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
  );
  CategorizationRuleRow copyWithCompanion(CategorizationRulesCompanion data) {
    return CategorizationRuleRow(
      id: data.id.present ? data.id.value : this.id,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      matchType: data.matchType.present ? data.matchType.value : this.matchType,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      priority: data.priority.present ? data.priority.value : this.priority,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategorizationRuleRow(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('matchType: $matchType, ')
          ..write('categoryId: $categoryId, ')
          ..write('isIncome: $isIncome, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    pattern,
    matchType,
    categoryId,
    isIncome,
    priority,
    enabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategorizationRuleRow &&
          other.id == this.id &&
          other.pattern == this.pattern &&
          other.matchType == this.matchType &&
          other.categoryId == this.categoryId &&
          other.isIncome == this.isIncome &&
          other.priority == this.priority &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class CategorizationRulesCompanion
    extends UpdateCompanion<CategorizationRuleRow> {
  final Value<String> id;
  final Value<String> pattern;
  final Value<String> matchType;
  final Value<String> categoryId;
  final Value<bool?> isIncome;
  final Value<int> priority;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CategorizationRulesCompanion({
    this.id = const Value.absent(),
    this.pattern = const Value.absent(),
    this.matchType = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategorizationRulesCompanion.insert({
    required String id,
    required String pattern,
    this.matchType = const Value.absent(),
    required String categoryId,
    this.isIncome = const Value.absent(),
    this.priority = const Value.absent(),
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       pattern = Value(pattern),
       categoryId = Value(categoryId),
       createdAt = Value(createdAt);
  static Insertable<CategorizationRuleRow> custom({
    Expression<String>? id,
    Expression<String>? pattern,
    Expression<String>? matchType,
    Expression<String>? categoryId,
    Expression<bool>? isIncome,
    Expression<int>? priority,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pattern != null) 'pattern': pattern,
      if (matchType != null) 'match_type': matchType,
      if (categoryId != null) 'category_id': categoryId,
      if (isIncome != null) 'is_income': isIncome,
      if (priority != null) 'priority': priority,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategorizationRulesCompanion copyWith({
    Value<String>? id,
    Value<String>? pattern,
    Value<String>? matchType,
    Value<String>? categoryId,
    Value<bool?>? isIncome,
    Value<int>? priority,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CategorizationRulesCompanion(
      id: id ?? this.id,
      pattern: pattern ?? this.pattern,
      matchType: matchType ?? this.matchType,
      categoryId: categoryId ?? this.categoryId,
      isIncome: isIncome ?? this.isIncome,
      priority: priority ?? this.priority,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (matchType.present) {
      map['match_type'] = Variable<String>(matchType.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isIncome.present) {
      map['is_income'] = Variable<bool>(isIncome.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategorizationRulesCompanion(')
          ..write('id: $id, ')
          ..write('pattern: $pattern, ')
          ..write('matchType: $matchType, ')
          ..write('categoryId: $categoryId, ')
          ..write('isIncome: $isIncome, ')
          ..write('priority: $priority, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTable extends SavingsGoals
    with TableInfo<$SavingsGoalsTable, SavingsGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMinorMeta = const VerificationMeta(
    'targetAmountMinor',
  );
  @override
  late final GeneratedColumn<int> targetAmountMinor = GeneratedColumn<int>(
    'target_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAmountMinorMeta = const VerificationMeta(
    'savedAmountMinor',
  );
  @override
  late final GeneratedColumn<int> savedAmountMinor = GeneratedColumn<int>(
    'saved_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetEurMicrosMeta = const VerificationMeta(
    'targetEurMicros',
  );
  @override
  late final GeneratedColumn<int> targetEurMicros = GeneratedColumn<int>(
    'target_eur_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedEurMicrosMeta = const VerificationMeta(
    'savedEurMicros',
  );
  @override
  late final GeneratedColumn<int> savedEurMicros = GeneratedColumn<int>(
    'saved_eur_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<int> icon = GeneratedColumn<int>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetAmountMinor,
    savedAmountMinor,
    targetEurMicros,
    savedEurMicros,
    currencyCode,
    dueDate,
    icon,
    color,
    completed,
    archived,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount_minor')) {
      context.handle(
        _targetAmountMinorMeta,
        targetAmountMinor.isAcceptableOrUnknown(
          data['target_amount_minor']!,
          _targetAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMinorMeta);
    }
    if (data.containsKey('saved_amount_minor')) {
      context.handle(
        _savedAmountMinorMeta,
        savedAmountMinor.isAcceptableOrUnknown(
          data['saved_amount_minor']!,
          _savedAmountMinorMeta,
        ),
      );
    }
    if (data.containsKey('target_eur_micros')) {
      context.handle(
        _targetEurMicrosMeta,
        targetEurMicros.isAcceptableOrUnknown(
          data['target_eur_micros']!,
          _targetEurMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetEurMicrosMeta);
    }
    if (data.containsKey('saved_eur_micros')) {
      context.handle(
        _savedEurMicrosMeta,
        savedEurMicros.isAcceptableOrUnknown(
          data['saved_eur_micros']!,
          _savedEurMicrosMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount_minor'],
      )!,
      savedAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_amount_minor'],
      )!,
      targetEurMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_eur_micros'],
      )!,
      savedEurMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saved_eur_micros'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}icon'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SavingsGoalsTable createAlias(String alias) {
    return $SavingsGoalsTable(attachedDatabase, alias);
  }
}

class SavingsGoalRow extends DataClass implements Insertable<SavingsGoalRow> {
  final String id;
  final String name;
  final int targetAmountMinor;
  final int savedAmountMinor;
  final int targetEurMicros;
  final int savedEurMicros;
  final String currencyCode;
  final DateTime? dueDate;
  final int icon;
  final int color;
  final bool completed;
  final bool archived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavingsGoalRow({
    required this.id,
    required this.name,
    required this.targetAmountMinor,
    required this.savedAmountMinor,
    required this.targetEurMicros,
    required this.savedEurMicros,
    required this.currencyCode,
    this.dueDate,
    required this.icon,
    required this.color,
    required this.completed,
    required this.archived,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_amount_minor'] = Variable<int>(targetAmountMinor);
    map['saved_amount_minor'] = Variable<int>(savedAmountMinor);
    map['target_eur_micros'] = Variable<int>(targetEurMicros);
    map['saved_eur_micros'] = Variable<int>(savedEurMicros);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['icon'] = Variable<int>(icon);
    map['color'] = Variable<int>(color);
    map['completed'] = Variable<bool>(completed);
    map['archived'] = Variable<bool>(archived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavingsGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsCompanion(
      id: Value(id),
      name: Value(name),
      targetAmountMinor: Value(targetAmountMinor),
      savedAmountMinor: Value(savedAmountMinor),
      targetEurMicros: Value(targetEurMicros),
      savedEurMicros: Value(savedEurMicros),
      currencyCode: Value(currencyCode),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      icon: Value(icon),
      color: Value(color),
      completed: Value(completed),
      archived: Value(archived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavingsGoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmountMinor: serializer.fromJson<int>(json['targetAmountMinor']),
      savedAmountMinor: serializer.fromJson<int>(json['savedAmountMinor']),
      targetEurMicros: serializer.fromJson<int>(json['targetEurMicros']),
      savedEurMicros: serializer.fromJson<int>(json['savedEurMicros']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      icon: serializer.fromJson<int>(json['icon']),
      color: serializer.fromJson<int>(json['color']),
      completed: serializer.fromJson<bool>(json['completed']),
      archived: serializer.fromJson<bool>(json['archived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetAmountMinor': serializer.toJson<int>(targetAmountMinor),
      'savedAmountMinor': serializer.toJson<int>(savedAmountMinor),
      'targetEurMicros': serializer.toJson<int>(targetEurMicros),
      'savedEurMicros': serializer.toJson<int>(savedEurMicros),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'icon': serializer.toJson<int>(icon),
      'color': serializer.toJson<int>(color),
      'completed': serializer.toJson<bool>(completed),
      'archived': serializer.toJson<bool>(archived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavingsGoalRow copyWith({
    String? id,
    String? name,
    int? targetAmountMinor,
    int? savedAmountMinor,
    int? targetEurMicros,
    int? savedEurMicros,
    String? currencyCode,
    Value<DateTime?> dueDate = const Value.absent(),
    int? icon,
    int? color,
    bool? completed,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SavingsGoalRow(
    id: id ?? this.id,
    name: name ?? this.name,
    targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
    savedAmountMinor: savedAmountMinor ?? this.savedAmountMinor,
    targetEurMicros: targetEurMicros ?? this.targetEurMicros,
    savedEurMicros: savedEurMicros ?? this.savedEurMicros,
    currencyCode: currencyCode ?? this.currencyCode,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    completed: completed ?? this.completed,
    archived: archived ?? this.archived,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SavingsGoalRow copyWithCompanion(SavingsGoalsCompanion data) {
    return SavingsGoalRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmountMinor: data.targetAmountMinor.present
          ? data.targetAmountMinor.value
          : this.targetAmountMinor,
      savedAmountMinor: data.savedAmountMinor.present
          ? data.savedAmountMinor.value
          : this.savedAmountMinor,
      targetEurMicros: data.targetEurMicros.present
          ? data.targetEurMicros.value
          : this.targetEurMicros,
      savedEurMicros: data.savedEurMicros.present
          ? data.savedEurMicros.value
          : this.savedEurMicros,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      completed: data.completed.present ? data.completed.value : this.completed,
      archived: data.archived.present ? data.archived.value : this.archived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmountMinor: $targetAmountMinor, ')
          ..write('savedAmountMinor: $savedAmountMinor, ')
          ..write('targetEurMicros: $targetEurMicros, ')
          ..write('savedEurMicros: $savedEurMicros, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dueDate: $dueDate, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('completed: $completed, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetAmountMinor,
    savedAmountMinor,
    targetEurMicros,
    savedEurMicros,
    currencyCode,
    dueDate,
    icon,
    color,
    completed,
    archived,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmountMinor == this.targetAmountMinor &&
          other.savedAmountMinor == this.savedAmountMinor &&
          other.targetEurMicros == this.targetEurMicros &&
          other.savedEurMicros == this.savedEurMicros &&
          other.currencyCode == this.currencyCode &&
          other.dueDate == this.dueDate &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.completed == this.completed &&
          other.archived == this.archived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavingsGoalsCompanion extends UpdateCompanion<SavingsGoalRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> targetAmountMinor;
  final Value<int> savedAmountMinor;
  final Value<int> targetEurMicros;
  final Value<int> savedEurMicros;
  final Value<String> currencyCode;
  final Value<DateTime?> dueDate;
  final Value<int> icon;
  final Value<int> color;
  final Value<bool> completed;
  final Value<bool> archived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavingsGoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmountMinor = const Value.absent(),
    this.savedAmountMinor = const Value.absent(),
    this.targetEurMicros = const Value.absent(),
    this.savedEurMicros = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.completed = const Value.absent(),
    this.archived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsCompanion.insert({
    required String id,
    required String name,
    required int targetAmountMinor,
    this.savedAmountMinor = const Value.absent(),
    required int targetEurMicros,
    this.savedEurMicros = const Value.absent(),
    required String currencyCode,
    this.dueDate = const Value.absent(),
    required int icon,
    required int color,
    this.completed = const Value.absent(),
    this.archived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetAmountMinor = Value(targetAmountMinor),
       targetEurMicros = Value(targetEurMicros),
       currencyCode = Value(currencyCode),
       icon = Value(icon),
       color = Value(color),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SavingsGoalRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? targetAmountMinor,
    Expression<int>? savedAmountMinor,
    Expression<int>? targetEurMicros,
    Expression<int>? savedEurMicros,
    Expression<String>? currencyCode,
    Expression<DateTime>? dueDate,
    Expression<int>? icon,
    Expression<int>? color,
    Expression<bool>? completed,
    Expression<bool>? archived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmountMinor != null) 'target_amount_minor': targetAmountMinor,
      if (savedAmountMinor != null) 'saved_amount_minor': savedAmountMinor,
      if (targetEurMicros != null) 'target_eur_micros': targetEurMicros,
      if (savedEurMicros != null) 'saved_eur_micros': savedEurMicros,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (dueDate != null) 'due_date': dueDate,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (completed != null) 'completed': completed,
      if (archived != null) 'archived': archived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? targetAmountMinor,
    Value<int>? savedAmountMinor,
    Value<int>? targetEurMicros,
    Value<int>? savedEurMicros,
    Value<String>? currencyCode,
    Value<DateTime?>? dueDate,
    Value<int>? icon,
    Value<int>? color,
    Value<bool>? completed,
    Value<bool>? archived,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
      savedAmountMinor: savedAmountMinor ?? this.savedAmountMinor,
      targetEurMicros: targetEurMicros ?? this.targetEurMicros,
      savedEurMicros: savedEurMicros ?? this.savedEurMicros,
      currencyCode: currencyCode ?? this.currencyCode,
      dueDate: dueDate ?? this.dueDate,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      completed: completed ?? this.completed,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmountMinor.present) {
      map['target_amount_minor'] = Variable<int>(targetAmountMinor.value);
    }
    if (savedAmountMinor.present) {
      map['saved_amount_minor'] = Variable<int>(savedAmountMinor.value);
    }
    if (targetEurMicros.present) {
      map['target_eur_micros'] = Variable<int>(targetEurMicros.value);
    }
    if (savedEurMicros.present) {
      map['saved_eur_micros'] = Variable<int>(savedEurMicros.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (icon.present) {
      map['icon'] = Variable<int>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmountMinor: $targetAmountMinor, ')
          ..write('savedAmountMinor: $savedAmountMinor, ')
          ..write('targetEurMicros: $targetEurMicros, ')
          ..write('savedEurMicros: $savedEurMicros, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('dueDate: $dueDate, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('completed: $completed, ')
          ..write('archived: $archived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalContributionsTable extends SavingsGoalContributions
    with TableInfo<$SavingsGoalContributionsTable, SavingsGoalContributionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES savings_goals (id)',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eurAmountMicrosMeta = const VerificationMeta(
    'eurAmountMicros',
  );
  @override
  late final GeneratedColumn<int> eurAmountMicros = GeneratedColumn<int>(
    'eur_amount_micros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    goalId,
    amountMinor,
    eurAmountMicros,
    currencyCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goal_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoalContributionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('eur_amount_micros')) {
      context.handle(
        _eurAmountMicrosMeta,
        eurAmountMicros.isAcceptableOrUnknown(
          data['eur_amount_micros']!,
          _eurAmountMicrosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eurAmountMicrosMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalContributionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalContributionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      eurAmountMicros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eur_amount_micros'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavingsGoalContributionsTable createAlias(String alias) {
    return $SavingsGoalContributionsTable(attachedDatabase, alias);
  }
}

class SavingsGoalContributionRow extends DataClass
    implements Insertable<SavingsGoalContributionRow> {
  final String id;
  final String goalId;
  final int amountMinor;
  final int eurAmountMicros;
  final String currencyCode;
  final DateTime createdAt;
  const SavingsGoalContributionRow({
    required this.id,
    required this.goalId,
    required this.amountMinor,
    required this.eurAmountMicros,
    required this.currencyCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['goal_id'] = Variable<String>(goalId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['eur_amount_micros'] = Variable<int>(eurAmountMicros);
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingsGoalContributionsCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalContributionsCompanion(
      id: Value(id),
      goalId: Value(goalId),
      amountMinor: Value(amountMinor),
      eurAmountMicros: Value(eurAmountMicros),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
    );
  }

  factory SavingsGoalContributionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalContributionRow(
      id: serializer.fromJson<String>(json['id']),
      goalId: serializer.fromJson<String>(json['goalId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      eurAmountMicros: serializer.fromJson<int>(json['eurAmountMicros']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'goalId': serializer.toJson<String>(goalId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'eurAmountMicros': serializer.toJson<int>(eurAmountMicros),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingsGoalContributionRow copyWith({
    String? id,
    String? goalId,
    int? amountMinor,
    int? eurAmountMicros,
    String? currencyCode,
    DateTime? createdAt,
  }) => SavingsGoalContributionRow(
    id: id ?? this.id,
    goalId: goalId ?? this.goalId,
    amountMinor: amountMinor ?? this.amountMinor,
    eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
    currencyCode: currencyCode ?? this.currencyCode,
    createdAt: createdAt ?? this.createdAt,
  );
  SavingsGoalContributionRow copyWithCompanion(
    SavingsGoalContributionsCompanion data,
  ) {
    return SavingsGoalContributionRow(
      id: data.id.present ? data.id.value : this.id,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      eurAmountMicros: data.eurAmountMicros.present
          ? data.eurAmountMicros.value
          : this.eurAmountMicros,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalContributionRow(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    goalId,
    amountMinor,
    eurAmountMicros,
    currencyCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalContributionRow &&
          other.id == this.id &&
          other.goalId == this.goalId &&
          other.amountMinor == this.amountMinor &&
          other.eurAmountMicros == this.eurAmountMicros &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt);
}

class SavingsGoalContributionsCompanion
    extends UpdateCompanion<SavingsGoalContributionRow> {
  final Value<String> id;
  final Value<String> goalId;
  final Value<int> amountMinor;
  final Value<int> eurAmountMicros;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavingsGoalContributionsCompanion({
    this.id = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.eurAmountMicros = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalContributionsCompanion.insert({
    required String id,
    required String goalId,
    required int amountMinor,
    required int eurAmountMicros,
    required String currencyCode,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       goalId = Value(goalId),
       amountMinor = Value(amountMinor),
       eurAmountMicros = Value(eurAmountMicros),
       currencyCode = Value(currencyCode),
       createdAt = Value(createdAt);
  static Insertable<SavingsGoalContributionRow> custom({
    Expression<String>? id,
    Expression<String>? goalId,
    Expression<int>? amountMinor,
    Expression<int>? eurAmountMicros,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (goalId != null) 'goal_id': goalId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (eurAmountMicros != null) 'eur_amount_micros': eurAmountMicros,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalContributionsCompanion copyWith({
    Value<String>? id,
    Value<String>? goalId,
    Value<int>? amountMinor,
    Value<int>? eurAmountMicros,
    Value<String>? currencyCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalContributionsCompanion(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      amountMinor: amountMinor ?? this.amountMinor,
      eurAmountMicros: eurAmountMicros ?? this.eurAmountMicros,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (eurAmountMicros.present) {
      map['eur_amount_micros'] = Variable<int>(eurAmountMicros.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalContributionsCompanion(')
          ..write('id: $id, ')
          ..write('goalId: $goalId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('eurAmountMicros: $eurAmountMicros, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $CategorizationRulesTable categorizationRules =
      $CategorizationRulesTable(this);
  late final $SavingsGoalsTable savingsGoals = $SavingsGoalsTable(this);
  late final $SavingsGoalContributionsTable savingsGoalContributions =
      $SavingsGoalContributionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    transactions,
    categories,
    recurringTransactions,
    budgets,
    categorizationRules,
    savingsGoals,
    savingsGoalContributions,
  ];
}

typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      required String id,
      required int amountCents,
      required bool isIncome,
      required String categoryId,
      Value<String?> note,
      required DateTime date,
      Value<bool> isRecurring,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrency,
      Value<int?> eurAmountMicros,
      Value<double?> exchangeRateToEur,
      Value<String?> receiptPath,
      Value<DateTime?> createdAt,
      Value<String?> recurringSourceId,
      Value<String?> recurringOccurrenceKey,
      Value<int> rowid,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<String> id,
      Value<int> amountCents,
      Value<bool> isIncome,
      Value<String> categoryId,
      Value<String?> note,
      Value<DateTime> date,
      Value<bool> isRecurring,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrency,
      Value<int?> eurAmountMicros,
      Value<double?> exchangeRateToEur,
      Value<String?> receiptPath,
      Value<DateTime?> createdAt,
      Value<String?> recurringSourceId,
      Value<String?> recurringOccurrenceKey,
      Value<int> rowid,
    });

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringSourceId => $composableBuilder(
    column: $table.recurringSourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recurringOccurrenceKey => $composableBuilder(
    column: $table.recurringOccurrenceKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringSourceId => $composableBuilder(
    column: $table.recurringSourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurringOccurrenceKey => $composableBuilder(
    column: $table.recurringOccurrenceKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
    column: $table.isRecurring,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptPath => $composableBuilder(
    column: $table.receiptPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get recurringSourceId => $composableBuilder(
    column: $table.recurringSourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recurringOccurrenceKey => $composableBuilder(
    column: $table.recurringOccurrenceKey,
    builder: (column) => column,
  );
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          Transaction,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (
            Transaction,
            BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
          ),
          Transaction,
          PrefetchHooks Function()
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isRecurring = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> eurAmountMicros = const Value.absent(),
                Value<double?> exchangeRateToEur = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> recurringSourceId = const Value.absent(),
                Value<String?> recurringOccurrenceKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amountCents: amountCents,
                isIncome: isIncome,
                categoryId: categoryId,
                note: note,
                date: date,
                isRecurring: isRecurring,
                originalAmountMinor: originalAmountMinor,
                originalCurrency: originalCurrency,
                eurAmountMicros: eurAmountMicros,
                exchangeRateToEur: exchangeRateToEur,
                receiptPath: receiptPath,
                createdAt: createdAt,
                recurringSourceId: recurringSourceId,
                recurringOccurrenceKey: recurringOccurrenceKey,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountCents,
                required bool isIncome,
                required String categoryId,
                Value<String?> note = const Value.absent(),
                required DateTime date,
                Value<bool> isRecurring = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> eurAmountMicros = const Value.absent(),
                Value<double?> exchangeRateToEur = const Value.absent(),
                Value<String?> receiptPath = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<String?> recurringSourceId = const Value.absent(),
                Value<String?> recurringOccurrenceKey = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amountCents: amountCents,
                isIncome: isIncome,
                categoryId: categoryId,
                note: note,
                date: date,
                isRecurring: isRecurring,
                originalAmountMinor: originalAmountMinor,
                originalCurrency: originalCurrency,
                eurAmountMicros: eurAmountMicros,
                exchangeRateToEur: exchangeRateToEur,
                receiptPath: receiptPath,
                createdAt: createdAt,
                recurringSourceId: recurringSourceId,
                recurringOccurrenceKey: recurringOccurrenceKey,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      Transaction,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (
        Transaction,
        BaseReferences<_$AppDatabase, $TransactionsTable, Transaction>,
      ),
      Transaction,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required bool isIncome,
      required int icon,
      required int color,
      Value<bool> isDefault,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isIncome,
      Value<int> icon,
      Value<int> color,
      Value<bool> isDefault,
      Value<DateTime?> lastUsedAt,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<int> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                isIncome: isIncome,
                icon: icon,
                color: color,
                isDefault: isDefault,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required bool isIncome,
                required int icon,
                required int color,
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime?> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                isIncome: isIncome,
                icon: icon,
                color: color,
                isDefault: isDefault,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      required String id,
      required int amountCents,
      required bool isIncome,
      required String categoryId,
      required int dayOfMonth,
      required DateTime startDate,
      Value<String?> note,
      Value<bool> active,
      Value<DateTime?> lastGenerated,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrency,
      Value<int?> eurAmountMicros,
      Value<double?> exchangeRateToEur,
      Value<String> frequency,
      Value<int> interval,
      Value<int?> dayOfWeek,
      Value<int?> monthOfYear,
      Value<DateTime?> endDate,
      Value<int> rowid,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<String> id,
      Value<int> amountCents,
      Value<bool> isIncome,
      Value<String> categoryId,
      Value<int> dayOfMonth,
      Value<DateTime> startDate,
      Value<String?> note,
      Value<bool> active,
      Value<DateTime?> lastGenerated,
      Value<int?> originalAmountMinor,
      Value<String?> originalCurrency,
      Value<int?> eurAmountMicros,
      Value<double?> exchangeRateToEur,
      Value<String> frequency,
      Value<int> interval,
      Value<int?> dayOfWeek,
      Value<int?> monthOfYear,
      Value<DateTime?> endDate,
      Value<int> rowid,
    });

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dayOfMonth => $composableBuilder(
    column: $table.dayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get lastGenerated => $composableBuilder(
    column: $table.lastGenerated,
    builder: (column) => column,
  );

  GeneratedColumn<int> get originalAmountMinor => $composableBuilder(
    column: $table.originalAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalCurrency => $composableBuilder(
    column: $table.originalCurrency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => column,
  );

  GeneratedColumn<double> get exchangeRateToEur => $composableBuilder(
    column: $table.exchangeRateToEur,
    builder: (column) => column,
  );

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get monthOfYear => $composableBuilder(
    column: $table.monthOfYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (
            RecurringTransaction,
            BaseReferences<
              _$AppDatabase,
              $RecurringTransactionsTable,
              RecurringTransaction
            >,
          ),
          RecurringTransaction,
          PrefetchHooks Function()
        > {
  $$RecurringTransactionsTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> dayOfMonth = const Value.absent(),
                Value<DateTime> startDate = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastGenerated = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> eurAmountMicros = const Value.absent(),
                Value<double?> exchangeRateToEur = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<int?> monthOfYear = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                amountCents: amountCents,
                isIncome: isIncome,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                startDate: startDate,
                note: note,
                active: active,
                lastGenerated: lastGenerated,
                originalAmountMinor: originalAmountMinor,
                originalCurrency: originalCurrency,
                eurAmountMicros: eurAmountMicros,
                exchangeRateToEur: exchangeRateToEur,
                frequency: frequency,
                interval: interval,
                dayOfWeek: dayOfWeek,
                monthOfYear: monthOfYear,
                endDate: endDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amountCents,
                required bool isIncome,
                required String categoryId,
                required int dayOfMonth,
                required DateTime startDate,
                Value<String?> note = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime?> lastGenerated = const Value.absent(),
                Value<int?> originalAmountMinor = const Value.absent(),
                Value<String?> originalCurrency = const Value.absent(),
                Value<int?> eurAmountMicros = const Value.absent(),
                Value<double?> exchangeRateToEur = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<int?> dayOfWeek = const Value.absent(),
                Value<int?> monthOfYear = const Value.absent(),
                Value<DateTime?> endDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                amountCents: amountCents,
                isIncome: isIncome,
                categoryId: categoryId,
                dayOfMonth: dayOfMonth,
                startDate: startDate,
                note: note,
                active: active,
                lastGenerated: lastGenerated,
                originalAmountMinor: originalAmountMinor,
                originalCurrency: originalCurrency,
                eurAmountMicros: eurAmountMicros,
                exchangeRateToEur: exchangeRateToEur,
                frequency: frequency,
                interval: interval,
                dayOfWeek: dayOfWeek,
                monthOfYear: monthOfYear,
                endDate: endDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionsTable,
      RecurringTransaction,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (
        RecurringTransaction,
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransaction
        >,
      ),
      RecurringTransaction,
      PrefetchHooks Function()
    >;
typedef $$BudgetsTableCreateCompanionBuilder =
    BudgetsCompanion Function({
      required String id,
      required String categoryId,
      required int amountMinor,
      required int eurAmountMicros,
      Value<String> periodType,
      Value<bool> rollover,
      Value<bool> active,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BudgetsTableUpdateCompanionBuilder =
    BudgetsCompanion Function({
      Value<String> id,
      Value<String> categoryId,
      Value<int> amountMinor,
      Value<int> eurAmountMicros,
      Value<String> periodType,
      Value<bool> rollover,
      Value<bool> active,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get rollover => $composableBuilder(
    column: $table.rollover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get rollover =>
      $composableBuilder(column: $table.rollover, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BudgetsTable,
          BudgetRow,
          $$BudgetsTableFilterComposer,
          $$BudgetsTableOrderingComposer,
          $$BudgetsTableAnnotationComposer,
          $$BudgetsTableCreateCompanionBuilder,
          $$BudgetsTableUpdateCompanionBuilder,
          (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
          BudgetRow,
          PrefetchHooks Function()
        > {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> eurAmountMicros = const Value.absent(),
                Value<String> periodType = const Value.absent(),
                Value<bool> rollover = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion(
                id: id,
                categoryId: categoryId,
                amountMinor: amountMinor,
                eurAmountMicros: eurAmountMicros,
                periodType: periodType,
                rollover: rollover,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String categoryId,
                required int amountMinor,
                required int eurAmountMicros,
                Value<String> periodType = const Value.absent(),
                Value<bool> rollover = const Value.absent(),
                Value<bool> active = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BudgetsCompanion.insert(
                id: id,
                categoryId: categoryId,
                amountMinor: amountMinor,
                eurAmountMicros: eurAmountMicros,
                periodType: periodType,
                rollover: rollover,
                active: active,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BudgetsTable,
      BudgetRow,
      $$BudgetsTableFilterComposer,
      $$BudgetsTableOrderingComposer,
      $$BudgetsTableAnnotationComposer,
      $$BudgetsTableCreateCompanionBuilder,
      $$BudgetsTableUpdateCompanionBuilder,
      (BudgetRow, BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow>),
      BudgetRow,
      PrefetchHooks Function()
    >;
typedef $$CategorizationRulesTableCreateCompanionBuilder =
    CategorizationRulesCompanion Function({
      required String id,
      required String pattern,
      Value<String> matchType,
      required String categoryId,
      Value<bool?> isIncome,
      Value<int> priority,
      Value<bool> enabled,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CategorizationRulesTableUpdateCompanionBuilder =
    CategorizationRulesCompanion Function({
      Value<String> id,
      Value<String> pattern,
      Value<String> matchType,
      Value<String> categoryId,
      Value<bool?> isIncome,
      Value<int> priority,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CategorizationRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get matchType => $composableBuilder(
    column: $table.matchType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategorizationRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get matchType => $composableBuilder(
    column: $table.matchType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategorizationRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategorizationRulesTable> {
  $$CategorizationRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<String> get matchType =>
      $composableBuilder(column: $table.matchType, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CategorizationRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategorizationRulesTable,
          CategorizationRuleRow,
          $$CategorizationRulesTableFilterComposer,
          $$CategorizationRulesTableOrderingComposer,
          $$CategorizationRulesTableAnnotationComposer,
          $$CategorizationRulesTableCreateCompanionBuilder,
          $$CategorizationRulesTableUpdateCompanionBuilder,
          (
            CategorizationRuleRow,
            BaseReferences<
              _$AppDatabase,
              $CategorizationRulesTable,
              CategorizationRuleRow
            >,
          ),
          CategorizationRuleRow,
          PrefetchHooks Function()
        > {
  $$CategorizationRulesTableTableManager(
    _$AppDatabase db,
    $CategorizationRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategorizationRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategorizationRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CategorizationRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<String> matchType = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<bool?> isIncome = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategorizationRulesCompanion(
                id: id,
                pattern: pattern,
                matchType: matchType,
                categoryId: categoryId,
                isIncome: isIncome,
                priority: priority,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String pattern,
                Value<String> matchType = const Value.absent(),
                required String categoryId,
                Value<bool?> isIncome = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CategorizationRulesCompanion.insert(
                id: id,
                pattern: pattern,
                matchType: matchType,
                categoryId: categoryId,
                isIncome: isIncome,
                priority: priority,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategorizationRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategorizationRulesTable,
      CategorizationRuleRow,
      $$CategorizationRulesTableFilterComposer,
      $$CategorizationRulesTableOrderingComposer,
      $$CategorizationRulesTableAnnotationComposer,
      $$CategorizationRulesTableCreateCompanionBuilder,
      $$CategorizationRulesTableUpdateCompanionBuilder,
      (
        CategorizationRuleRow,
        BaseReferences<
          _$AppDatabase,
          $CategorizationRulesTable,
          CategorizationRuleRow
        >,
      ),
      CategorizationRuleRow,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableCreateCompanionBuilder =
    SavingsGoalsCompanion Function({
      required String id,
      required String name,
      required int targetAmountMinor,
      Value<int> savedAmountMinor,
      required int targetEurMicros,
      Value<int> savedEurMicros,
      required String currencyCode,
      Value<DateTime?> dueDate,
      required int icon,
      required int color,
      Value<bool> completed,
      Value<bool> archived,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableUpdateCompanionBuilder =
    SavingsGoalsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> targetAmountMinor,
      Value<int> savedAmountMinor,
      Value<int> targetEurMicros,
      Value<int> savedEurMicros,
      Value<String> currencyCode,
      Value<DateTime?> dueDate,
      Value<int> icon,
      Value<int> color,
      Value<bool> completed,
      Value<bool> archived,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$SavingsGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $SavingsGoalsTable, SavingsGoalRow> {
  $$SavingsGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $SavingsGoalContributionsTable,
    List<SavingsGoalContributionRow>
  >
  _savingsGoalContributionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.savingsGoalContributions,
        aliasName: $_aliasNameGenerator(
          db.savingsGoals.id,
          db.savingsGoalContributions.goalId,
        ),
      );

  $$SavingsGoalContributionsTableProcessedTableManager
  get savingsGoalContributionsRefs {
    final manager = $$SavingsGoalContributionsTableTableManager(
      $_db,
      $_db.savingsGoalContributions,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _savingsGoalContributionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SavingsGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedAmountMinor => $composableBuilder(
    column: $table.savedAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetEurMicros => $composableBuilder(
    column: $table.targetEurMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get savedEurMicros => $composableBuilder(
    column: $table.savedEurMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> savingsGoalContributionsRefs(
    Expression<bool> Function($$SavingsGoalContributionsTableFilterComposer f)
    f,
  ) {
    final $$SavingsGoalContributionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savingsGoalContributions,
          getReferencedColumn: (t) => t.goalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavingsGoalContributionsTableFilterComposer(
                $db: $db,
                $table: $db.savingsGoalContributions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavingsGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedAmountMinor => $composableBuilder(
    column: $table.savedAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetEurMicros => $composableBuilder(
    column: $table.targetEurMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get savedEurMicros => $composableBuilder(
    column: $table.savedEurMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTable> {
  $$SavingsGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedAmountMinor => $composableBuilder(
    column: $table.savedAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetEurMicros => $composableBuilder(
    column: $table.targetEurMicros,
    builder: (column) => column,
  );

  GeneratedColumn<int> get savedEurMicros => $composableBuilder(
    column: $table.savedEurMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> savingsGoalContributionsRefs<T extends Object>(
    Expression<T> Function($$SavingsGoalContributionsTableAnnotationComposer a)
    f,
  ) {
    final $$SavingsGoalContributionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.savingsGoalContributions,
          getReferencedColumn: (t) => t.goalId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$SavingsGoalContributionsTableAnnotationComposer(
                $db: $db,
                $table: $db.savingsGoalContributions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SavingsGoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTable,
          SavingsGoalRow,
          $$SavingsGoalsTableFilterComposer,
          $$SavingsGoalsTableOrderingComposer,
          $$SavingsGoalsTableAnnotationComposer,
          $$SavingsGoalsTableCreateCompanionBuilder,
          $$SavingsGoalsTableUpdateCompanionBuilder,
          (SavingsGoalRow, $$SavingsGoalsTableReferences),
          SavingsGoalRow,
          PrefetchHooks Function({bool savingsGoalContributionsRefs})
        > {
  $$SavingsGoalsTableTableManager(_$AppDatabase db, $SavingsGoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> targetAmountMinor = const Value.absent(),
                Value<int> savedAmountMinor = const Value.absent(),
                Value<int> targetEurMicros = const Value.absent(),
                Value<int> savedEurMicros = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> icon = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion(
                id: id,
                name: name,
                targetAmountMinor: targetAmountMinor,
                savedAmountMinor: savedAmountMinor,
                targetEurMicros: targetEurMicros,
                savedEurMicros: savedEurMicros,
                currencyCode: currencyCode,
                dueDate: dueDate,
                icon: icon,
                color: color,
                completed: completed,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int targetAmountMinor,
                Value<int> savedAmountMinor = const Value.absent(),
                required int targetEurMicros,
                Value<int> savedEurMicros = const Value.absent(),
                required String currencyCode,
                Value<DateTime?> dueDate = const Value.absent(),
                required int icon,
                required int color,
                Value<bool> completed = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsCompanion.insert(
                id: id,
                name: name,
                targetAmountMinor: targetAmountMinor,
                savedAmountMinor: savedAmountMinor,
                targetEurMicros: targetEurMicros,
                savedEurMicros: savedEurMicros,
                currencyCode: currencyCode,
                dueDate: dueDate,
                icon: icon,
                color: color,
                completed: completed,
                archived: archived,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingsGoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({savingsGoalContributionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (savingsGoalContributionsRefs) db.savingsGoalContributions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savingsGoalContributionsRefs)
                    await $_getPrefetchedData<
                      SavingsGoalRow,
                      $SavingsGoalsTable,
                      SavingsGoalContributionRow
                    >(
                      currentTable: table,
                      referencedTable: $$SavingsGoalsTableReferences
                          ._savingsGoalContributionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SavingsGoalsTableReferences(
                            db,
                            table,
                            p0,
                          ).savingsGoalContributionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.goalId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SavingsGoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTable,
      SavingsGoalRow,
      $$SavingsGoalsTableFilterComposer,
      $$SavingsGoalsTableOrderingComposer,
      $$SavingsGoalsTableAnnotationComposer,
      $$SavingsGoalsTableCreateCompanionBuilder,
      $$SavingsGoalsTableUpdateCompanionBuilder,
      (SavingsGoalRow, $$SavingsGoalsTableReferences),
      SavingsGoalRow,
      PrefetchHooks Function({bool savingsGoalContributionsRefs})
    >;
typedef $$SavingsGoalContributionsTableCreateCompanionBuilder =
    SavingsGoalContributionsCompanion Function({
      required String id,
      required String goalId,
      required int amountMinor,
      required int eurAmountMicros,
      required String currencyCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$SavingsGoalContributionsTableUpdateCompanionBuilder =
    SavingsGoalContributionsCompanion Function({
      Value<String> id,
      Value<String> goalId,
      Value<int> amountMinor,
      Value<int> eurAmountMicros,
      Value<String> currencyCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SavingsGoalContributionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavingsGoalContributionsTable,
          SavingsGoalContributionRow
        > {
  $$SavingsGoalContributionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SavingsGoalsTable _goalIdTable(_$AppDatabase db) =>
      db.savingsGoals.createAlias(
        $_aliasNameGenerator(
          db.savingsGoalContributions.goalId,
          db.savingsGoals.id,
        ),
      );

  $$SavingsGoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<String>('goal_id')!;

    final manager = $$SavingsGoalsTableTableManager(
      $_db,
      $_db.savingsGoals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavingsGoalContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalContributionsTable> {
  $$SavingsGoalContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SavingsGoalsTableFilterComposer get goalId {
    final $$SavingsGoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingsGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsGoalsTableFilterComposer(
            $db: $db,
            $table: $db.savingsGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsGoalContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalContributionsTable> {
  $$SavingsGoalContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SavingsGoalsTableOrderingComposer get goalId {
    final $$SavingsGoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingsGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsGoalsTableOrderingComposer(
            $db: $db,
            $table: $db.savingsGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsGoalContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalContributionsTable> {
  $$SavingsGoalContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eurAmountMicros => $composableBuilder(
    column: $table.eurAmountMicros,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SavingsGoalsTableAnnotationComposer get goalId {
    final $$SavingsGoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.savingsGoals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsGoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingsGoals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsGoalContributionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalContributionsTable,
          SavingsGoalContributionRow,
          $$SavingsGoalContributionsTableFilterComposer,
          $$SavingsGoalContributionsTableOrderingComposer,
          $$SavingsGoalContributionsTableAnnotationComposer,
          $$SavingsGoalContributionsTableCreateCompanionBuilder,
          $$SavingsGoalContributionsTableUpdateCompanionBuilder,
          (
            SavingsGoalContributionRow,
            $$SavingsGoalContributionsTableReferences,
          ),
          SavingsGoalContributionRow,
          PrefetchHooks Function({bool goalId})
        > {
  $$SavingsGoalContributionsTableTableManager(
    _$AppDatabase db,
    $SavingsGoalContributionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalContributionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SavingsGoalContributionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavingsGoalContributionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> goalId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<int> eurAmountMicros = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalContributionsCompanion(
                id: id,
                goalId: goalId,
                amountMinor: amountMinor,
                eurAmountMicros: eurAmountMicros,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String goalId,
                required int amountMinor,
                required int eurAmountMicros,
                required String currencyCode,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalContributionsCompanion.insert(
                id: id,
                goalId: goalId,
                amountMinor: amountMinor,
                eurAmountMicros: eurAmountMicros,
                currencyCode: currencyCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SavingsGoalContributionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.goalId,
                                referencedTable:
                                    $$SavingsGoalContributionsTableReferences
                                        ._goalIdTable(db),
                                referencedColumn:
                                    $$SavingsGoalContributionsTableReferences
                                        ._goalIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SavingsGoalContributionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalContributionsTable,
      SavingsGoalContributionRow,
      $$SavingsGoalContributionsTableFilterComposer,
      $$SavingsGoalContributionsTableOrderingComposer,
      $$SavingsGoalContributionsTableAnnotationComposer,
      $$SavingsGoalContributionsTableCreateCompanionBuilder,
      $$SavingsGoalContributionsTableUpdateCompanionBuilder,
      (SavingsGoalContributionRow, $$SavingsGoalContributionsTableReferences),
      SavingsGoalContributionRow,
      PrefetchHooks Function({bool goalId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$CategorizationRulesTableTableManager get categorizationRules =>
      $$CategorizationRulesTableTableManager(_db, _db.categorizationRules);
  $$SavingsGoalsTableTableManager get savingsGoals =>
      $$SavingsGoalsTableTableManager(_db, _db.savingsGoals);
  $$SavingsGoalContributionsTableTableManager get savingsGoalContributions =>
      $$SavingsGoalContributionsTableTableManager(
        _db,
        _db.savingsGoalContributions,
      );
}
