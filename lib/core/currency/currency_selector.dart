import 'package:flutter/material.dart';

import 'currency_metadata.dart';
import '../../l10n/app_localizations.dart';

class CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final bool compact;

  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = supportedCurrencyCodes.contains(value) ? value : 'EUR';
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      initialValue: selected,
      tooltip:
          AppLocalizations.of(context)?.changeCurrency ?? 'Change currency',
      onSelected: onChanged,
      itemBuilder: (context) => supportedCurrencyCodes
          .map(
            (currency) => PopupMenuItem<String>(
              value: currency,
              child: Row(
                children: [
                  SizedBox(
                    width: 36,
                    child: Text(
                      _currencySymbol(currency),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(child: Text(currency)),
                  if (currency == selected)
                    Icon(Icons.check_rounded, color: colors.primary, size: 20),
                ],
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 7 : 9,
        ),
        decoration: BoxDecoration(
          color: colors.primaryContainer.withValues(alpha: .55),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.primary.withValues(alpha: .18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected,
              style: TextStyle(
                color: colors.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 14,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.expand_more_rounded,
              size: compact ? 17 : 19,
              color: colors.onPrimaryContainer,
            ),
          ],
        ),
      ),
    );
  }

  String _currencySymbol(String currency) {
    return const {
          'EUR': '€',
          'USD': r'$',
          'GBP': '£',
          'CHF': 'Fr',
          'JPY': '¥',
          'CNY': '¥',
          'INR': '₹',
          'KRW': '₩',
          'TRY': '₺',
          'PLN': 'zł',
          'SEK': 'kr',
          'NOK': 'kr',
          'DKK': 'kr',
        }[currency] ??
        currency;
  }
}
