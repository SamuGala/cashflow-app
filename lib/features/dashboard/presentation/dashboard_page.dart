import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/selected_month_provider.dart';

import '../providers/dashboard_provider.dart';
import '../providers/recent_transactions_provider.dart';

import '../../transactions/providers/category_provider.dart';

import '../widgets/revolut_month_selector.dart';
import '../../../l10n/app_localizations.dart';
import '../../transactions/domain/category.dart';
import '../../../core/utils/category_localization.dart';
import '../../transactions/presentation/quick_add_transaction_sheet.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool monthly = false;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final stats = ref.watch(dashboardProvider(monthly));
    final showBalance = ref.watch(balanceVisibilityProvider);

    final recent = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    final List<Category> categories = categoriesAsync.value ?? [];

    final locale = Localizations.localeOf(context).toString();
    final currency = NumberFormat.currency(locale: locale, symbol: '€');

    String hide(String value) => showBalance ? value : "••••";

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => const QuickAddTransactionSheet(),
          );
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
        children: [
          /// HEADER
          Row(
            children: [
              Text(
                t.appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  showBalance ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  ref.read(balanceVisibilityProvider.notifier).toggle();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// TOTAL / MONTH TOGGLE
          Row(
            children: [
              ChoiceChip(
                label: Text(t.total),
                selected: !monthly,
                onSelected: (_) {
                  setState(() {
                    monthly = false;
                  });
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(t.month),
                selected: monthly,
                onSelected: (_) {
                  setState(() {
                    monthly = true;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// MONTH SELECTOR
          if (monthly) ...[
            const RevolutMonthSelector(),
            const SizedBox(height: 16),
          ],

          /// BALANCE CARD
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff6366F1), Color(0xff4F46E5)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.balance,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),

                const SizedBox(height: 6),

                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: stats.balance / 100),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Text(
                      hide(currency.format(value)),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    _StatBox(
                      label: t.income,
                      value: hide(currency.format(stats.income / 100)),
                      color: Colors.green,
                      icon: Icons.arrow_downward,
                    ),

                    const SizedBox(width: 12),

                    _StatBox(
                      label: t.expense,
                      value: hide(currency.format(stats.expense / 100)),
                      color: Colors.red,
                      icon: Icons.arrow_upward,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            t.recentTransactions,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          if (recent.isEmpty) Text(t.noTransactions),

          /// RECENT TRANSACTIONS
          ...recent.asMap().entries.map((entry) {
            final index = entry.key;
            final tx = entry.value;

            final category =
                categories.where((c) => c.id == tx.categoryId).firstOrNull ??
                categories.first;

            final amount = (tx.amountCents / 100).toStringAsFixed(2);
            final date = DateFormat.yMd(locale).format(tx.date);

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 300 + (index * 80)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.surfaceContainer
                      : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    /// CATEGORY ICON + RECURRING BADGE
                    Container(
                      height: 42,
                      width: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Color(category.color).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Icon(
                              categoryIcon(category.name),
                              size: 22,
                              color: Color(category.color),
                            ),
                          ),
                          if (tx.isRecurring)
                            Positioned(
                              right: -6,
                              bottom: -6,
                              child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.autorenew, size: 10),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            categoryName(category.name, t),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      '${tx.isIncome ? '+' : '-'} €$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: tx.isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white70)),

                  const SizedBox(height: 2),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
