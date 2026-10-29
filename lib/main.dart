import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'core/database/database_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'core/security/auth_provider.dart';
import 'core/security/auto_lock_provider.dart';
import 'app/app.dart';
import 'app/launch_actions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  unawaited(listenForNativeLaunches());

  runApp(const ProviderScope(child: RootApp()));
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> with WidgetsBindingObserver {
  DateTime? _backgroundedAt;
  bool _privacyShield = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_generateRecurringTransactions());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      launchActionsReady.value = false;
      if (mounted && !_privacyShield) {
        setState(() => _privacyShield = true);
      }
    }

    if ((state == AppLifecycleState.hidden ||
            state == AppLifecycleState.paused) &&
        mounted) {
      final container = ProviderScope.containerOf(context);
      if (container.read(authProvider)) {
        _backgroundedAt ??= DateTime.now();
      }
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_handleResume());
    }
  }

  /// Links that arrive while the app runs (widget, quick actions, the
  /// `pocketvault://` scheme). The app's MaterialApp has no route table, so
  /// they are turned into launch actions here instead.
  @override
  Future<bool> didPushRouteInformation(RouteInformation routeInformation) {
    final action = launchActionFromUri(routeInformation.uri);
    if (action == null) return Future.value(false);
    dispatchLaunchAction(action);
    return Future.value(true);
  }

  Future<void> _handleResume() async {
    if (!mounted) return;
    final container = ProviderScope.containerOf(context);
    final timeout = await container.read(autoLockProvider.future);
    final backgroundedAt = _backgroundedAt;
    if (shouldAutoLock(
      backgroundedAt: backgroundedAt,
      resumedAt: DateTime.now(),
      timeout: timeout,
    )) {
      container.read(authProvider.notifier).lock();
    }
    _backgroundedAt = null;
    // Lock decided and drawn: actions that arrived meanwhile go to the
    // unlocked app, or wait for the PIN.
    await WidgetsBinding.instance.endOfFrame;
    launchActionsReady.value = true;
    if (mounted && _privacyShield) {
      setState(() => _privacyShield = false);
    }
    await _generateRecurringTransactions();
  }

  Future<void> _generateRecurringTransactions() async {
    if (!mounted) return;

    final container = ProviderScope.containerOf(context);
    final generated = await container
        .read(databaseProvider)
        .generateRecurringTransactions();

    if (generated > 0) {
      container.invalidate(transactionProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topLeft,
      children: [
        const CashflowApp(),
        if (_privacyShield)
          const Directionality(
            textDirection: TextDirection.ltr,
            child: ColoredBox(
              color: Color(0xFF0B1220),
              child: Center(
                child: Icon(Icons.lock_rounded, color: Colors.white, size: 42),
              ),
            ),
          ),
      ],
    );
  }
}
