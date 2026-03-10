import '../../l10n/app_localizations.dart';

String categoryName(String key, AppLocalizations t) {
  switch (key) {
    case 'salary':
      return t.salary;
    case 'food':
      return t.food;
    case 'transport':
      return t.transport;
    case 'shopping':
      return t.shopping;
    case 'entertainment':
      return t.entertainment;
    default:
      return key;
  }
}