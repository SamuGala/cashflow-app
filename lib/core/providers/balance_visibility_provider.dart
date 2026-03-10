import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // false = saldo nascosto di default
  }

  void toggle() {
    state = !state;
  }

  void hide() {
    state = false;
  }

  void show() {
    state = true;
  }
}

final balanceVisibilityProvider =
    NotifierProvider<BalanceVisibilityNotifier, bool>(
  BalanceVisibilityNotifier.new,
);