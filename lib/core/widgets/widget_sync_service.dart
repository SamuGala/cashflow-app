import 'dart:io';

import 'package:flutter/services.dart';

import '../../features/transactions/domain/transaction.dart';
import '../currency/currency_metadata.dart';

class WidgetSyncService {
  static const _channel = MethodChannel('pocket_vault/widget');

  Future<void> sync({
    required List<TransactionModel> transactions,
    required String currencyCode,
  }) async {
    if (!Platform.isAndroid) return;
    final now = DateTime.now();
    var balance = 0;
    var monthlyExpenses = 0;
    for (final transaction in transactions) {
      balance += transaction.isIncome
          ? transaction.amountCents
          : -transaction.amountCents;
      if (!transaction.isIncome &&
          transaction.date.year == now.year &&
          transaction.date.month == now.month) {
        monthlyExpenses += transaction.amountCents;
      }
    }
    await _channel.invokeMethod<void>('sync', {
      'balance': '$currencyCode ${amountInputText(balance, currencyCode)}',
      'monthlyExpenses':
          '$currencyCode ${amountInputText(monthlyExpenses, currencyCode)}',
    });
  }
}
