import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'core/database/database_provider.dart';
import 'core/security/auth_provider.dart';
import 'core/security/pin_page.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  runApp(const ProviderScope(child: RootApp()));
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;

      Future.microtask(() async {
        final container = ProviderScope.containerOf(context);
        final db = container.read(databaseProvider);
        await db.generateRecurringTransactions();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final unlocked = ref.watch(authProvider);

        if (!unlocked) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: PinPage(),
          );
        }

        return const CashflowApp();
      },
    );
  }
}
