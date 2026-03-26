import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../presentation/providers/theme_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/security/pin_storage.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _rateApp() async {
    final review = InAppReview.instance;

    if (await review.isAvailable()) {
      review.requestReview();
    }
  }

  void _shareApp() {
    Share.share(
      "Try Pockets Vault — simple expense tracker\nhttps://apps.apple.com/app/id6760252780",
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const ThemeSection(),
          const SizedBox(height: 16),

          const LanguageSection(),
          const SizedBox(height: 16),

          AppSection(onRate: _rateApp, onShare: _shareApp),
          const SizedBox(height: 16),

          const SecuritySection(),
          const SizedBox(height: 16),

          const DataSection(),
          const SizedBox(height: 40),

          const AppFooter(),
        ],
      ),
    );
  }
}

class ThemeSection extends ConsumerWidget {
  const ThemeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          ],
        ),
      ),
    );
  }
}

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations.of(context)!;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(t.language),
        trailing: DropdownButton<String>(
          value: locale.languageCode,
          underline: const SizedBox(),
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
      ),
    );
  }
}

class AppSection extends StatelessWidget {
  final VoidCallback onRate;
  final VoidCallback onShare;

  const AppSection({super.key, required this.onRate, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text("Rate app"),
            onTap: onRate,
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text("Share app"),
            onTap: onShare,
          ),
        ],
      ),
    );
  }
}

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.security),
            title: Text(t.security),
          ),
          const FaceIdToggle(),
        ],
      ),
    );
  }
}

class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  t.data,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text(t.confirm),
                        content: Text(t.deleteAllQ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
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
                    await ref
                        .read(transactionProvider.notifier)
                        .deleteAllData();

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(t.canceledAll),
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
                icon: const Icon(Icons.delete),
                label: Text(t.cancelAll),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaceIdToggle extends StatelessWidget {
  const FaceIdToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = PinStorage();

    return FutureBuilder<bool>(
      future: storage.biometricsEnabled(),
      builder: (context, snapshot) {
        final enabled = snapshot.data ?? false;

        return SwitchListTile(
          title: const Text("Face ID"),
          value: enabled,
          onChanged: (value) async {
            if (value) {
              await storage.enableBiometrics();
            } else {
              await storage.disableBiometrics();
            }
          },
        );
      },
    );
  }
}

class AppFooter extends StatefulWidget {
  const AppFooter({super.key});

  @override
  State<AppFooter> createState() => _AppFooterState();
}

class _AppFooterState extends State<AppFooter> {
  String version = "";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      version = "${info.appName} v${info.version}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "$version\n© SG All rights reserved",
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
    );
  }
}
