import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'router.dart';

/// Something the app was opened to do: from a home-screen quick action, the
/// widget or a notification. It waits here until the unlocked shell is on
/// screen, then the page that owns it consumes it.
enum LaunchAction {
  addExpense,
  addIncome,
  scanReceipt,
  openRecurring,
  openHome,
}

final pendingLaunchAction = ValueNotifier<LaunchAction?>(null);

/// Closed while the app is in the background and until the resume has
/// decided whether to lock: on Android a tapped notification arrives before
/// the resume, and must not open anything above the PIN screen.
final launchActionsReady = ValueNotifier<bool>(true);

/// Fires when an action arrives or becomes deliverable.
final launchActionChanges = Listenable.merge([
  pendingLaunchAction,
  launchActionsReady,
]);

/// `pocketvault:///add`, `/add?flow=income`, `/scan`, `/recurring`, `/home`.
LaunchAction? launchActionFromUri(Uri uri) {
  return switch (uri.path) {
    '/add' =>
      uri.queryParameters['flow'] == 'income'
          ? LaunchAction.addIncome
          : LaunchAction.addExpense,
    '/scan' => LaunchAction.scanReceipt,
    '/recurring' => LaunchAction.openRecurring,
    '/home' => LaunchAction.openHome,
    _ => null,
  };
}

/// Returns the pending action if it is one of [accepted], clearing it.
LaunchAction? takeLaunchAction(Set<LaunchAction> accepted) {
  if (!launchActionsReady.value) return null;
  final action = pendingLaunchAction.value;
  if (action == null || !accepted.contains(action)) return null;
  pendingLaunchAction.value = null;
  return action;
}

/// Records [action] and moves to the tab that handles it. Safe to call
/// before the unlocked shell exists: the router keeps the location.
void dispatchLaunchAction(LaunchAction? action) {
  pendingLaunchAction.value = action;
  if (action == null) return;
  appRouter.go(
    action == LaunchAction.openRecurring ? '/transactions' : '/dashboard',
  );
}

const _launchChannel = MethodChannel('pocket_vault/launch');

/// iOS quick actions and Android notification taps arrive here instead of
/// as pushed routes, which would be dropped while the startup animation or
/// the PIN screen is showing.
Future<void> listenForNativeLaunches() async {
  _launchChannel.setMethodCallHandler((call) async {
    if (call.method == 'open' && call.arguments is String) {
      dispatchLaunchAction(
        launchActionFromUri(Uri.parse(call.arguments as String)),
      );
    }
  });
  try {
    final pending = await _launchChannel.invokeMethod<String>('takePending');
    if (pending != null) {
      dispatchLaunchAction(launchActionFromUri(Uri.parse(pending)));
    }
  } on MissingPluginException {
    // Platforms without the channel deliver links as routes instead.
  }
}
