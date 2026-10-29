import 'transaction.dart';

enum FlowFilter { all, expense, income }

enum ReceiptFilter { any, withReceipt, withoutReceipt }

/// Optional filters of the Movements history, combined with the search and
/// the shared period. Amounts are in base-currency minor units, as stored.
class MovementFilters {
  final FlowFilter flow;
  final Set<String> categoryIds;
  final int? minAmount;
  final int? maxAmount;
  final Set<String> currencies;
  final ReceiptFilter receipt;

  const MovementFilters({
    this.flow = FlowFilter.all,
    this.categoryIds = const {},
    this.minAmount,
    this.maxAmount,
    this.currencies = const {},
    this.receipt = ReceiptFilter.any,
  });

  static const none = MovementFilters();

  bool get hasAmount => minAmount != null || maxAmount != null;

  int get activeCount => [
    flow != FlowFilter.all,
    categoryIds.isNotEmpty,
    hasAmount,
    currencies.isNotEmpty,
    receipt != ReceiptFilter.any,
  ].where((active) => active).length;

  bool get isEmpty => activeCount == 0;

  bool matches(TransactionModel tx) {
    if (flow == FlowFilter.expense && tx.isIncome) return false;
    if (flow == FlowFilter.income && !tx.isIncome) return false;
    if (categoryIds.isNotEmpty && !categoryIds.contains(tx.categoryId)) {
      return false;
    }
    if (minAmount != null && tx.amountCents < minAmount!) return false;
    if (maxAmount != null && tx.amountCents > maxAmount!) return false;
    if (currencies.isNotEmpty && !currencies.contains(tx.originalCurrency)) {
      return false;
    }
    final hasReceipt = tx.receiptPath != null && tx.receiptPath!.isNotEmpty;
    if (receipt == ReceiptFilter.withReceipt && !hasReceipt) return false;
    if (receipt == ReceiptFilter.withoutReceipt && hasReceipt) return false;
    return true;
  }

  MovementFilters copyWith({
    FlowFilter? flow,
    Set<String>? categoryIds,
    int? Function()? minAmount,
    int? Function()? maxAmount,
    Set<String>? currencies,
    ReceiptFilter? receipt,
  }) => MovementFilters(
    flow: flow ?? this.flow,
    categoryIds: categoryIds ?? this.categoryIds,
    minAmount: minAmount != null ? minAmount() : this.minAmount,
    maxAmount: maxAmount != null ? maxAmount() : this.maxAmount,
    currencies: currencies ?? this.currencies,
    receipt: receipt ?? this.receipt,
  );

  MovementFilters withoutAmount() =>
      copyWith(minAmount: () => null, maxAmount: () => null);
}
