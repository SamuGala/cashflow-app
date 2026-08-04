import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';

import 'currency_metadata.dart';

class CurrencyRatesSnapshot {
  final Map<String, double> ratesPerEuro;
  final DateTime? publishedAt;
  final DateTime fetchedAt;

  const CurrencyRatesSnapshot({
    required this.ratesPerEuro,
    required this.publishedAt,
    required this.fetchedAt,
  });

  bool get isStale =>
      DateTime.now().difference(fetchedAt) > const Duration(hours: 24);

  Map<String, Object?> toJson() => {
    'rates': ratesPerEuro,
    'publishedAt': publishedAt?.toIso8601String(),
    'fetchedAt': fetchedAt.toIso8601String(),
  };

  factory CurrencyRatesSnapshot.fromJson(Map<String, dynamic> json) {
    final rawRates = json['rates'] as Map<String, dynamic>;
    return CurrencyRatesSnapshot(
      ratesPerEuro: rawRates.map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      fetchedAt: DateTime.parse(json['fetchedAt'] as String),
    );
  }
}

class CurrencyConversion {
  final int originalAmountMinor;
  final String originalCurrency;
  final int baseAmountMinor;
  final String baseCurrency;
  final int eurAmountMicros;
  final double exchangeRateToEur;

  const CurrencyConversion({
    required this.originalAmountMinor,
    required this.originalCurrency,
    required this.baseAmountMinor,
    required this.baseCurrency,
    required this.eurAmountMicros,
    required this.exchangeRateToEur,
  });
}

class CurrencyRateException implements Exception {
  final String message;

  const CurrencyRateException(this.message);

  @override
  String toString() => message;
}

class CurrencyRatesService {
  static const _cacheKey = 'currency_rates_ecb_v1';
  static final _ratesUri = Uri.parse(
    'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml',
  );

  final http.Client _client;

  CurrencyRatesService({http.Client? client})
    : _client = client ?? http.Client();

  Future<CurrencyRatesSnapshot> loadCached() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_cacheKey);
    if (raw == null) {
      return CurrencyRatesSnapshot(
        ratesPerEuro: const {'EUR': 1},
        publishedAt: null,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }

    try {
      return CurrencyRatesSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } on FormatException {
      await preferences.remove(_cacheKey);
      return CurrencyRatesSnapshot(
        ratesPerEuro: const {'EUR': 1},
        publishedAt: null,
        fetchedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
    }
  }

  Future<CurrencyRatesSnapshot> refresh() async {
    final response = await _client
        .get(_ratesUri)
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw CurrencyRateException(
        'ECB exchange-rate request failed (${response.statusCode}).',
      );
    }

    final document = XmlDocument.parse(response.body);
    final rates = <String, double>{'EUR': 1};
    DateTime? publishedAt;

    for (final cube in document.descendants.whereType<XmlElement>()) {
      if (cube.name.local != 'Cube') continue;
      final time = cube.getAttribute('time');
      if (time != null) publishedAt = DateTime.tryParse(time);

      final currency = cube.getAttribute('currency');
      final rate = double.tryParse(cube.getAttribute('rate') ?? '');
      if (currency != null && rate != null) rates[currency] = rate;
    }

    if (rates.length < 2) {
      throw const CurrencyRateException(
        'ECB returned no usable exchange rates.',
      );
    }

    final snapshot = CurrencyRatesSnapshot(
      ratesPerEuro: rates,
      publishedAt: publishedAt,
      fetchedAt: DateTime.now(),
    );
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_cacheKey, jsonEncode(snapshot.toJson()));
    return snapshot;
  }

  CurrencyConversion convert({
    required int amountMinor,
    required String sourceCurrency,
    required String baseCurrency,
    required Map<String, double> ratesPerEuro,
  }) {
    final source = sourceCurrency.toUpperCase();
    final base = baseCurrency.toUpperCase();
    final sourceRate = ratesPerEuro[source];
    final baseRate = ratesPerEuro[base];
    if (sourceRate == null || baseRate == null) {
      throw CurrencyRateException('No cached ECB rate for $source or $base.');
    }

    final sourceMajor = minorToMajor(amountMinor, source);
    final eurMajor = sourceMajor / sourceRate;
    final baseMajor = eurMajor * baseRate;
    return CurrencyConversion(
      originalAmountMinor: amountMinor,
      originalCurrency: source,
      baseAmountMinor: majorToMinor(baseMajor, base),
      baseCurrency: base,
      eurAmountMicros: (eurMajor * 1000000).round(),
      exchangeRateToEur: 1 / sourceRate,
    );
  }

  int eurMicrosToMinor(
    int eurAmountMicros,
    String currencyCode,
    Map<String, double> ratesPerEuro,
  ) {
    final rate = ratesPerEuro[currencyCode];
    if (rate == null) {
      throw CurrencyRateException('No cached ECB rate for $currencyCode.');
    }
    return majorToMinor((eurAmountMicros / 1000000) * rate, currencyCode);
  }
}
