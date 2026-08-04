import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../presentation/providers/theme_provider.dart';
import 'package:pocket_vault/core/providers/locale_provider.dart';
import '../../transactions/providers/transaction_provider.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/security/pin_storage.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/currency/currency_selector.dart';
import '../../../core/security/auto_lock_provider.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/dashboard_period_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/providers/recurring_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/savings_goals_provider.dart';
import '../../../shared/widgets/safe_prompt_dialog.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<void> _rateApp() async {
    final review = InAppReview.instance;

    if (await review.isAvailable()) {
      review.requestReview();
    }
  }

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            "Try Pockets Vault — simple expense tracker\n"
            "https://apps.apple.com/app/id6760252780",
      ),
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

          const CurrencySection(),
          const SizedBox(height: 16),

          AppSection(onRate: _rateApp, onShare: _shareApp),
          const SizedBox(height: 16),

          const SecuritySection(),
          const SizedBox(height: 16),

          const BackupSection(),
          const SizedBox(height: 16),

          const DataSection(),
          const SizedBox(height: 40),

          const AppFooter(),
        ],
      ),
    );
  }
}

class CurrencySection extends ConsumerWidget {
  const CurrencySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyState = ref.watch(currencyProvider);
    final t = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: currencyState.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, _) => ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(t.mainCurrency),
            subtitle: Text(error.toString()),
          ),
          data: (state) => Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.currency_exchange),
                title: Text(t.mainCurrency),
                subtitle: Text(
                  state.rates.publishedAt == null
                      ? t.ecbRefreshNeeded
                      : t.ecbRatesDate(
                          '${state.rates.publishedAt!.day}/'
                          '${state.rates.publishedAt!.month}/'
                          '${state.rates.publishedAt!.year}',
                        ),
                ),
                trailing: CurrencySelector(
                  value: state.baseCurrency,
                  onChanged: (currency) async {
                    try {
                      await ref
                          .read(currencyProvider.notifier)
                          .setBaseCurrency(currency);
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(error.toString())));
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: state.isRefreshing
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(currencyProvider.notifier)
                                .refreshRates();
                          } catch (error) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())),
                            );
                          }
                        },
                  icon: state.isRefreshing
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(t.updateRates),
                ),
              ),
            ],
          ),
        ),
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
              expandedInsets: EdgeInsets.zero,
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: AppThemeMode.system,
                  label: Text(
                    t.systemTheme,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                ButtonSegment(
                  value: AppThemeMode.light,
                  label: Text(
                    t.light,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                ButtonSegment(
                  value: AppThemeMode.dark,
                  label: Text(
                    t.dark,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
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
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: Text(t.rateApp),
            onTap: onRate,
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(t.shareApp),
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
    return const Card(
      child: Column(
        children: [
          ListTile(leading: Icon(Icons.security), title: _SecurityTitle()),
          FaceIdToggle(),
          AutoLockTile(),
        ],
      ),
    );
  }
}

class _SecurityTitle extends StatelessWidget {
  const _SecurityTitle();

  @override
  Widget build(BuildContext context) {
    return Text(AppLocalizations.of(context)!.security);
  }
}

class AutoLockTile extends ConsumerWidget {
  const AutoLockTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeout = ref.watch(autoLockProvider).value;
    final t = AppLocalizations.of(context)!;
    return ListTile(
      leading: const Icon(Icons.timer_outlined),
      title: Text(t.automaticLock),
      trailing: DropdownButton<AutoLockTimeout>(
        value: timeout ?? AutoLockTimeout.seconds30,
        underline: const SizedBox(),
        items: AutoLockTimeout.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value.label(Localizations.localeOf(context))),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            ref.read(autoLockProvider.notifier).setTimeout(value);
          }
        },
      ),
    );
  }
}

class BackupSection extends ConsumerStatefulWidget {
  const BackupSection({super.key});

  @override
  ConsumerState<BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<BackupSection> {
  bool _busy = false;

  Future<String?> _passwordDialog(
    BuildContext context, {
    required String title,
    required bool confirmPassword,
  }) {
    return showDialog<String>(
      context: context,
      builder: (_) => SafePasswordDialog(
        title: title,
        cancelLabel: AppLocalizations.of(context)!.cancel,
        confirmLabel: AppLocalizations.of(context)!.continueAction,
        requireConfirmation: confirmPassword,
      ),
    );
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Rect? _shareOrigin(BuildContext context) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(backupServiceProvider);
    final t = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          if (_busy) const LinearProgressIndicator(minHeight: 2),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: Text(t.backupPortability),
            subtitle: Text(t.encryptedBackupCaption),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(t.exportEncryptedBackup),
            onTap: _busy
                ? null
                : () async {
                    final password = await _passwordDialog(
                      context,
                      title: t.protectBackup,
                      confirmPassword: true,
                    );
                    if (password == null || !context.mounted) return;
                    setState(() => _busy = true);
                    try {
                      final saved = await service.saveEncryptedBackup(
                        password,
                        sharePositionOrigin: _shareOrigin(context),
                      );
                      if (context.mounted) {
                        _message(
                          context,
                          saved.status == ShareResultStatus.dismissed
                              ? t.exportCanceled
                              : t.backupReady,
                        );
                      }
                    } catch (error) {
                      if (context.mounted) _message(context, error.toString());
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
          ),
          ListTile(
            leading: const Icon(Icons.table_view_outlined),
            title: Text(t.exportTransactionsCsv),
            onTap: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    try {
                      final saved = await service.exportCsv(
                        sharePositionOrigin: _shareOrigin(context),
                      );
                      if (context.mounted) {
                        _message(
                          context,
                          saved.status == ShareResultStatus.dismissed
                              ? t.exportCanceled
                              : t.csvReady,
                        );
                      }
                    } catch (error) {
                      if (context.mounted) _message(context, error.toString());
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  },
          ),
          ListTile(
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(t.importBackup),
            subtitle: Text(t.safeMergeOrReplace),
            onTap: _busy
                ? null
                : () async {
                    try {
                      final bytes = await service.pickBackup();
                      if (bytes == null || !context.mounted) return;
                      final password = await _passwordDialog(
                        context,
                        title: t.unlockBackup,
                        confirmPassword: false,
                      );
                      if (password == null || !context.mounted) return;
                      final replace = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(t.importMode),
                          content: Text(t.importModeExplanation),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(t.cancel),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: Text(t.merge),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: Text(t.replace),
                            ),
                          ],
                        ),
                      );
                      if (replace == null) return;
                      setState(() => _busy = true);
                      await service.restoreEncryptedBackup(
                        bytes,
                        password,
                        replaceExisting: replace,
                      );
                      ref.invalidate(transactionProvider);
                      ref.invalidate(categoryProvider);
                      ref.invalidate(recurringProvider);
                      ref.invalidate(currencyProvider);
                      ref.invalidate(themeProvider);
                      ref.invalidate(localeProvider);
                      ref.invalidate(autoLockProvider);
                      ref.invalidate(balanceVisibilityProvider);
                      ref.invalidate(dashboardPeriodProvider);
                      ref.invalidate(budgetProvider);
                      ref.invalidate(savingsGoalsProvider);
                      if (context.mounted) {
                        _message(context, t.backupRestored);
                      }
                    } catch (error) {
                      if (context.mounted) _message(context, error.toString());
                    } finally {
                      if (mounted && _busy) setState(() => _busy = false);
                    }
                  },
          ),
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
                    ref.invalidate(budgetProvider);
                    ref.invalidate(savingsGoalsProvider);

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
    if (!mounted) return;
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
