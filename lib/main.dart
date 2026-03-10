import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';

import 'core/security/auth_provider.dart';
import 'core/security/pin_page.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  runApp(const ProviderScope(child: RootApp()));
}

class RootApp extends ConsumerWidget {
  const RootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(authProvider);

    if (!unlocked) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: PinPage(),
      );
    }

    return const CashflowApp();
  }
}
