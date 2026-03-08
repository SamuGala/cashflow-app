import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// carica tutti i locale per intl (date format)
  await initializeDateFormatting();

  runApp(
    const ProviderScope(
      child: CashflowApp(),
    ),
  );
}