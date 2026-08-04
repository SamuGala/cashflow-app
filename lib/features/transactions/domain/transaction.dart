class TransactionModel {
  final String id;
  final int amountCents;
  final bool isIncome;
  final String categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final int originalAmountMinor;
  final String originalCurrency;
  final int eurAmountMicros;
  final double exchangeRateToEur;
  final String? receiptPath;
  final DateTime createdAt;
  final String? recurringSourceId;
  final String? recurringOccurrenceKey;

  const TransactionModel({
    required this.id,
    required this.amountCents,
    required this.isIncome,
    required this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
    int? originalAmountMinor,
    this.originalCurrency = 'EUR',
    int? eurAmountMicros,
    this.exchangeRateToEur = 1,
    this.receiptPath,
    DateTime? createdAt,
    this.recurringSourceId,
    this.recurringOccurrenceKey,
  }) : originalAmountMinor = originalAmountMinor ?? amountCents,
       eurAmountMicros = eurAmountMicros ?? amountCents * 10000,
       createdAt = createdAt ?? date;
}
