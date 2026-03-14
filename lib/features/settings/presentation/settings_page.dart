import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/providers/theme_provider.dart';
import '../presentation/providers/locale_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

import '../../../l10n/app_localizations.dart';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/security/pin_storage.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _rateApp() async {
    final url = Uri.parse(
      "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _shareApp() {
    Share.share(
      "Try Cashflow — simple expense tracker\nhttps://apps.apple.com/app/idYOUR_APP_ID",
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.settings,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// THEME
          Text(t.theme, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          SegmentedButton<AppThemeMode>(
            segments: [
              ButtonSegment(value: AppThemeMode.light, label: Text(t.light)),
              ButtonSegment(value: AppThemeMode.dark, label: Text(t.dark)),
            ],
            selected: {theme},
            onSelectionChanged: (value) {
              ref.read(themeProvider.notifier).setTheme(value.first);
            },
          ),

          const SizedBox(height: 24),

          /// LANGUAGE
          Text(t.language, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 8),

          DropdownButton<String>(
            value: locale.languageCode,
            items: const [
              DropdownMenuItem(value: "it", child: Text("Italiano")),
              DropdownMenuItem(value: "en", child: Text("English")),
              DropdownMenuItem(value: "es", child: Text("Español")),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(localeProvider.notifier).setLocale(value);
              }
            },
          ),

          const SizedBox(height: 24),

          /// APP
          const Text("App", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text("Rate app"),
            onTap: _rateApp,
          ),

          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Share app"),
            onTap: _shareApp,
          ),

          const SizedBox(height: 24),

          /// SECURITY
          Text(t.security, style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          const FaceIdToggle(),

          const SizedBox(height: 24),

          /// DATA RESET
          Text(t.data, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: Text(t.cancelAll),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: Text(t.confirm),
                    content: Text(t.deleteAllQ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(t.cancel),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: Text(t.delete),
                      ),
                    ],
                  );
                },
              );

              if (confirm == true) {
                await ref.read(transactionProvider.notifier).deleteAllData();

                if (context.mounted) {
                  final messenger = ScaffoldMessenger.of(context);

                          messenger
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  t.cancelAll,
                                ),
                                duration: const Duration(seconds: 4),
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            );
                }
              }
            },
          ),

          const SizedBox(height: 260),

          /// FOOTER
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "Cashflow v1.0.0\n© SG All rights reserved",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceIdToggle extends StatefulWidget {
  const FaceIdToggle({super.key});

  @override
  State<FaceIdToggle> createState() => _FaceIdToggleState();
}

class _FaceIdToggleState extends State<FaceIdToggle> {
  final storage = PinStorage();

  bool enabled = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    enabled = await storage.biometricsEnabled();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text("Face ID"),
      value: enabled,
      onChanged: (value) async {
        if (value) {
          await storage.enableBiometrics();
        } else {
          await storage.disableBiometrics();
        }

        setState(() {
          enabled = value;
        });
      },
    );
  }
}
