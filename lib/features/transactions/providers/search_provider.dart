import 'package:flutter_riverpod/flutter_riverpod.dart';

final transactionSearchProvider =
    NotifierProvider<SearchNotifier, String>(SearchNotifier.new);

class SearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String value) {
    state = value;
  }
}