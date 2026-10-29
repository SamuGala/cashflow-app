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
import '../../../core/notifications/notification_planner.dart';
import '../../../core/notifications/notification_providers.dart';
import '../../../core/providers/balance_visibility_provider.dart';
import '../../../core/providers/dashboard_period_provider.dart';
import '../../transactions/providers/category_provider.dart';
import '../../transactions/providers/recurring_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../goals/providers/savings_goals_provider.dart';
import '../../../shared/widgets/safe_prompt_dialog.dart';
import '../../../shared/widgets/vault_dialogs.dart';
import '../../../shared/widgets/vault_style.dart';

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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            VaultPageHeader(title: t.settings),
            const SizedBox(height: 20),
            VaultSectionLabel(t.settingsAppearance),
            const _SettingsGroup(children: [ThemeSection(), LanguageSection()]),
            const SizedBox(height: 24),
            VaultSectionLabel(t.mainCurrency),
            const CurrencySection(),
            const SizedBox(height: 24),
            VaultSectionLabel(t.security),
            const SecuritySection(),
            const SizedBox(height: 24),
            VaultSectionLabel(t.notifications),
            const NotificationsSection(),
            const SizedBox(height: 24),
            VaultSectionLabel(t.backupPortability),
            const BackupSection(),
            const SizedBox(height: 24),
            VaultSectionLabel(t.settingsSupport),
            AppSection(onRate: _rateApp, onShare: _shareApp),
            const SizedBox(height: 24),
            VaultSectionLabel(t.data),
            const DataSection(),
            const SizedBox(height: 32),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

/// Vault card holding a list of settings rows separated by hairlines.
class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return VaultSurface(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: .7,
                indent: 64,
                color: colors.outlineVariant.withValues(alpha: .6),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Settings row: tinted icon tile, title, optional caption and trailing
/// control.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.wideTrailing = false,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  /// Text-sized controls such as dropdowns move under the title on narrow
  /// screens or with large text instead of squeezing it.
  final bool wideTrailing;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final tint = color ?? colors.primary;
    final trailing = this.trailing;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stacked =
                  wideTrailing &&
                  (constraints.maxWidth < 330 ||
                      MediaQuery.textScalerOf(context).scale(1) > 1.15);
              final labels = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color ?? colors.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.3,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (stacked && trailing != null) ...[
                    const SizedBox(height: 8),
                    trailing,
                  ],
                ],
              );
              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: tint.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, size: 20, color: tint),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: labels),
                  if (trailing != null && !stacked) ...[
                    const SizedBox(width: 8),
                    trailing,
                  ] else if (trailing == null && onTap != null)
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colors.onSurfaceVariant,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Tinted pill that opens a checked menu, like the currency selector.
class SettingsMenu<T> extends StatelessWidget {
  const SettingsMenu({
    super.key,
    required this.value,
    required this.options,
    required this.onSelected,
  });

  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => [
        for (final entry in options.entries)
          PopupMenuItem<T>(
            value: entry.key,
            child: Row(
              children: [
                Expanded(child: Text(entry.value)),
                if (entry.key == value)
                  Icon(Icons.check_rounded, size: 19, color: colors.primary),
              ],
            ),
          ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 168),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 7, 8, 7),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  options[value] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.expand_more_rounded, size: 18, color: colors.primary),
            ],
          ),
        ),
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

    Future<void> guard(Future<void> Function() action) async {
      try {
        await action();
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }

    return _SettingsGroup(
      children: currencyState.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          ),
        ],
        error: (error, _) => [
          SettingsRow(
            icon: Icons.currency_exchange_rounded,
            title: t.mainCurrency,
            subtitle: error.toString(),
          ),
        ],
        data: (state) => [
          SettingsRow(
            icon: Icons.currency_exchange_rounded,
            title: t.mainCurrency,
            trailing: CurrencySelector(
              value: state.baseCurrency,
              onChanged: (currency) => guard(
                () => ref
                    .read(currencyProvider.notifier)
                    .setBaseCurrency(currency),
              ),
            ),
          ),
          SettingsRow(
            key: const ValueKey('settings-refresh-rates'),
            icon: Icons.sync_rounded,
            title: t.updateRates,
            subtitle: state.rates.publishedAt == null
                ? t.ecbRefreshNeeded
                : t.ecbRatesDate(
                    '${state.rates.publishedAt!.day}/'
                    '${state.rates.publishedAt!.month}/'
                    '${state.rates.publishedAt!.year}',
                  ),
            trailing: state.isRefreshing
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            onTap: state.isRefreshing
                ? null
                : () => guard(
                    () => ref.read(currencyProvider.notifier).refreshRates(),
                  ),
          ),
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

    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.contrast_rounded,
                  size: 20,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                t.theme,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SegmentedButton<AppThemeMode>(
            expandedInsets: EdgeInsets.zero,
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              minimumSize: const Size(0, 40),
              side: BorderSide(color: colors.outlineVariant, width: .7),
              selectedBackgroundColor: colors.primary.withValues(alpha: .12),
              selectedForegroundColor: colors.primary,
              textStyle: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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
    );
  }
}

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final t = AppLocalizations.of(context)!;

    return SettingsRow(
      icon: Icons.translate_rounded,
      title: t.language,
      wideTrailing: true,
      trailing: SettingsMenu<String>(
        key: const ValueKey('settings-language'),
        value: locale.languageCode,
        options: const {"it": "Italiano", "en": "English", "es": "Español"},
        onSelected: (value) =>
            ref.read(localeProvider.notifier).setLocale(value),
      ),
    );
  }
}

class NotificationsSection extends ConsumerWidget {
  const NotificationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;
    final prefs =
        ref.watch(notificationPreferencesProvider).value ??
        const NotificationPreferences();
    final locale = Localizations.localeOf(context);

    Future<void> save(NotificationPreferences next) async {
      final saved = await ref
          .read(notificationPreferencesProvider.notifier)
          .save(next);
      if (!saved && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.notifyPermissionDenied)));
      }
    }

    Widget toggle(String key, bool value, ValueChanged<bool> onChanged) =>
        Switch.adaptive(key: ValueKey(key), value: value, onChanged: onChanged);

    final time = TimeOfDay(
      hour: prefs.reminderHour,
      minute: prefs.reminderMinute,
    );
    return _SettingsGroup(
      children: [
        SettingsRow(
          icon: Icons.autorenew_rounded,
          title: t.notifyRecurring,
          subtitle: t.notifyRecurringCaption,
          trailing: toggle(
            'notify-recurring',
            prefs.recurring,
            (value) => save(prefs.copyWith(recurring: value)),
          ),
        ),
        if (prefs.recurring)
          SettingsRow(
            icon: Icons.event_outlined,
            title: t.notifyWhen,
            wideTrailing: true,
            trailing: SettingsMenu<int>(
              key: const ValueKey('notify-recurring-days'),
              value: prefs.recurringDaysBefore,
              options: {
                0: t.notifySameDay,
                for (final days in [1, 2, 3]) days: t.notifyDaysBefore(days),
              },
              onSelected: (days) =>
                  save(prefs.copyWith(recurringDaysBefore: days)),
            ),
          ),
        SettingsRow(
          icon: Icons.donut_large_rounded,
          title: t.notifyBudget,
          subtitle: t.notifyBudgetCaption,
          trailing: toggle(
            'notify-budget',
            prefs.budget,
            (value) => save(prefs.copyWith(budget: value)),
          ),
        ),
        if (prefs.budget)
          SettingsRow(
            icon: Icons.speed_rounded,
            title: t.notifyThreshold,
            trailing: SettingsMenu<int>(
              key: const ValueKey('notify-budget-threshold'),
              value: prefs.budgetThreshold,
              options: {
                for (final percent in [50, 80, 90, 100])
                  percent: t.notifyAtPercent(percent),
              },
              onSelected: (percent) =>
                  save(prefs.copyWith(budgetThreshold: percent)),
            ),
          ),
        SettingsRow(
          icon: Icons.nightlight_outlined,
          title: t.notifyReminder,
          subtitle: t.notifyReminderCaption,
          trailing: toggle(
            'notify-reminder',
            prefs.reminder,
            (value) => save(prefs.copyWith(reminder: value)),
          ),
        ),
        if (prefs.reminder)
          SettingsRow(
            key: const ValueKey('notify-reminder-time'),
            icon: Icons.schedule_rounded,
            title: t.notifyTime,
            trailing: Text(
              MaterialLocalizations.of(context).formatTimeOfDay(
                time,
                alwaysUse24HourFormat:
                    MediaQuery.alwaysUse24HourFormatOf(context) ||
                    locale.languageCode != 'en',
              ),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (picked == null) return;
              await save(
                prefs.copyWith(
                  reminderHour: picked.hour,
                  reminderMinute: picked.minute,
                ),
              );
            },
          ),
        SettingsRow(
          icon: Icons.visibility_off_outlined,
          title: t.notifyHideAmounts,
          trailing: toggle(
            'notify-hide-amounts',
            prefs.hideAmounts,
            (value) => save(prefs.copyWith(hideAmounts: value)),
          ),
        ),
      ],
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
    return _SettingsGroup(
      children: [
        SettingsRow(
          icon: Icons.star_rounded,
          color: const Color(0xFFE29A12),
          title: t.rateApp,
          onTap: onRate,
        ),
        SettingsRow(
          icon: Icons.ios_share_rounded,
          title: t.shareApp,
          onTap: onShare,
        ),
      ],
    );
  }
}

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SettingsGroup(children: [FaceIdToggle(), AutoLockTile()]);
  }
}

class AutoLockTile extends ConsumerWidget {
  const AutoLockTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeout = ref.watch(autoLockProvider).value;
    final t = AppLocalizations.of(context)!;
    return SettingsRow(
      icon: Icons.timer_outlined,
      title: t.automaticLock,
      wideTrailing: true,
      trailing: SettingsMenu<AutoLockTimeout>(
        key: const ValueKey('settings-auto-lock'),
        value: timeout ?? AutoLockTimeout.seconds30,
        options: {
          for (final value in AutoLockTimeout.values)
            value: value.label(Localizations.localeOf(context)),
        },
        onSelected: (value) =>
            ref.read(autoLockProvider.notifier).setTimeout(value),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SettingsGroup(
          children: [
            if (_busy) const LinearProgressIndicator(minHeight: 2),
            SettingsRow(
              icon: Icons.lock_outline_rounded,
              title: t.exportEncryptedBackup,
              subtitle: t.encryptedBackupCaption,
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
                        if (context.mounted) {
                          _message(context, error.toString());
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
            SettingsRow(
              icon: Icons.table_view_outlined,
              title: t.exportTransactionsCsv,
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
                        if (context.mounted) {
                          _message(context, error.toString());
                        }
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
            ),
            SettingsRow(
              icon: Icons.settings_backup_restore_rounded,
              title: t.importBackup,
              subtitle: t.safeMergeOrReplace,
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
                        if (context.mounted) {
                          _message(context, error.toString());
                        }
                      } finally {
                        if (mounted && _busy) setState(() => _busy = false);
                      }
                    },
            ),
          ],
        ),
      ],
    );
  }
}

class DataSection extends ConsumerWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context)!;

    final danger = VaultColors.expense(context);
    return _SettingsGroup(
      children: [
        SettingsRow(
          key: const ValueKey('settings-delete-all'),
          icon: Icons.delete_outline_rounded,
          color: danger,
          title: t.cancelAll,
          onTap: () async {
            final confirm = await showVaultDeleteDialog(
              context,
              title: t.confirm,
              message: t.deleteAllQ,
            );

            if (confirm == true) {
              await ref.read(transactionProvider.notifier).deleteAllData();
              ref.invalidate(budgetProvider);
              ref.invalidate(savingsGoalsProvider);

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(t.canceledAll)));
              }
            }
          },
        ),
      ],
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
  late Future<bool> enabled = storage.biometricsEnabled();

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return FutureBuilder<bool>(
      future: enabled,
      builder: (context, snapshot) {
        return SettingsRow(
          icon: isIOS ? Icons.face_retouching_natural : Icons.fingerprint,
          title: isIOS
              ? "Face ID"
              : AppLocalizations.of(context)!.biometricUnlock,
          trailing: Switch.adaptive(
            value: snapshot.data ?? false,
            onChanged: (value) async {
              if (value) {
                await storage.enableBiometrics();
              } else {
                await storage.disableBiometrics();
              }
              if (mounted) {
                setState(() {
                  enabled = storage.biometricsEnabled();
                });
              }
            },
          ),
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
      style: TextStyle(
        fontSize: 12,
        height: 1.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
