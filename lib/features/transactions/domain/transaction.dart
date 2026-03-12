class TransactionModel {
  final String id;
  final int amountCents;
  final bool isIncome;
  final String categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;

  const TransactionModel({
    required this.id,
    required this.amountCents,
    required this.isIncome,
    required this.categoryId,
    required this.date,
    this.note,
    this.isRecurring = false,
  });
}
