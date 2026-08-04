import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_provider.dart';
import 'currency_rates_service.dart';

const _baseCurrencyKey = 'base_currency_v1';

class CurrencyState {
  final String baseCurrency;
  final CurrencyRatesSnapshot rates;
  final bool isRefreshing;

  const CurrencyState({
    required this.baseCurrency,
    required this.rates,
    this.isRefreshing = false,
  });

  CurrencyState copyWith({
    String? baseCurrency,
    CurrencyRatesSnapshot? rates,
    bool? isRefreshing,
  }) {
    return CurrencyState(
      baseCurrency: baseCurrency ?? this.baseCurrency,
      rates: rates ?? this.rates,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final currencyRatesServiceProvider = Provider<CurrencyRatesService>((ref) {
  return CurrencyRatesService();
});

final currencyProvider = AsyncNotifierProvider<CurrencyNotifier, CurrencyState>(
  CurrencyNotifier.new,
);

class CurrencyNotifier extends AsyncNotifier<CurrencyState> {
  CurrencyRatesService get _service => ref.read(currencyRatesServiceProvider);

  @override
  Future<CurrencyState> build() async {
    final preferences = await SharedPreferences.getInstance();
    final cached = await _service.loadCached();
    final result = CurrencyState(
      baseCurrency: preferences.getString(_baseCurrencyKey) ?? 'EUR',
      rates: cached,
    );
    if (cached.isStale) unawaited(refreshRates(silent: true));
    return result;
  }

  Future<void> refreshRates({bool silent = false}) async {
    final current = state.value ?? await future;
    state = AsyncData(current.copyWith(isRefreshing: true));
    try {
      final rates = await _service.refresh();
      state = AsyncData(current.copyWith(rates: rates, isRefreshing: false));
    } catch (_) {
      state = AsyncData(current.copyWith(isRefreshing: false));
      if (!silent) rethrow;
    }
  }

  Future<CurrencyConversion> convert({
    required int amountMinor,
    required String sourceCurrency,
  }) async {
    var current = state.value ?? await future;
    final hasRequiredRates =
        current.rates.ratesPerEuro.containsKey(sourceCurrency) &&
        current.rates.ratesPerEuro.containsKey(current.baseCurrency);
    final needsRefresh =
        !hasRequiredRates ||
        (sourceCurrency != current.baseCurrency && current.rates.isStale);
    if (needsRefresh) {
      try {
        await refreshRates();
        current = state.requireValue;
      } catch (_) {
        // A valid cached quote is preferable to blocking an offline user.
        // If a currency has never been downloaded, there is no safe fallback.
        if (!hasRequiredRates) rethrow;
      }
    }
    return _service.convert(
      amountMinor: amountMinor,
      sourceCurrency: sourceCurrency,
      baseCurrency: current.baseCurrency,
      ratesPerEuro: current.rates.ratesPerEuro,
    );
  }

  Future<void> setBaseCurrency(String currencyCode) async {
    var current = state.value ?? await future;
    if (currencyCode == current.baseCurrency) return;
    final hasRequiredRate = current.rates.ratesPerEuro.containsKey(
      currencyCode,
    );
    if (!hasRequiredRate || current.rates.isStale) {
      try {
        await refreshRates();
        current = state.requireValue;
      } catch (_) {
        if (!hasRequiredRate) rethrow;
      }
    }

    final rates = current.rates.ratesPerEuro;
    final service = _service;
    await ref
        .read(databaseProvider)
        .revalueAmounts(
          currencyCode: currencyCode,
          fromEurMicros: (amount) =>
              service.eurMicrosToMinor(amount, currencyCode, rates),
        );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_baseCurrencyKey, currencyCode);
    state = AsyncData(current.copyWith(baseCurrency: currencyCode));
  }
}
