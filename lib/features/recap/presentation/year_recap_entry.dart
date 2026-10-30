import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/vault_style.dart';
import '../domain/year_recap.dart';
import 'year_recap_page.dart';

const recapBannerDismissedKey = 'year_recap_banner_dismissed_v1';

/// Home banner offered from 20 December to 31 January, until dismissed for
/// that year.
class YearRecapBanner extends ConsumerStatefulWidget {
  const YearRecapBanner({super.key});

  @override
  ConsumerState<YearRecapBanner> createState() => _YearRecapBannerState();
}

class _YearRecapBannerState extends ConsumerState<YearRecapBanner> {
  int? _dismissedYear;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      if (!mounted) return;
      setState(() {
        _dismissedYear = prefs.getInt(recapBannerDismissedKey);
        _loaded = true;
      });
    });
  }

  Future<void> _dismiss(int year) async {
    setState(() => _dismissedYear = year);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(recapBannerDismissedKey, year);
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(recapClockProvider)();
    final year = defaultRecapYear(now);
    final recap = ref.watch(yearRecapProvider(year));
    final show =
        _loaded &&
        isRecapSeason(now) &&
        _dismissedYear != year &&
        recap != null &&
        !recap.isEmpty;
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final income = VaultColors.income(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedSize(
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: !show
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: VaultElevation.surface(dark),
                ),
                child: Material(
                  key: const ValueKey('year-recap-banner'),
                  color: colors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: colors.outlineVariant, width: .7),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => showYearRecap(context, year),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: colors.outlineVariant,
                                width: .7,
                              ),
                              gradient: RadialGradient(
                                center: const Alignment(-.6, -.6),
                                radius: 1.1,
                                colors: [
                                  income.withValues(alpha: .4),
                                  colors.surface,
                                ],
                              ),
                            ),
                            child: Text(
                              '$year',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.recapBannerTitle('$year'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.recapBannerBody(recapCardCount(recap)),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            key: const ValueKey('year-recap-banner-close'),
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                            icon: Icon(
                              Icons.close_rounded,
                              size: 20,
                              color: colors.onSurfaceVariant,
                            ),
                            onPressed: () => _dismiss(year),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Statistics entry, available all year once the year has movements.
class YearRecapEntry extends ConsumerWidget {
  const YearRecapEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = defaultRecapYear(ref.watch(recapClockProvider)());
    final recap = ref.watch(yearRecapProvider(year));
    if (recap == null || recap.isEmpty) return const SizedBox.shrink();
    final t = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ActionChip(
          key: const ValueKey('stats-year-recap'),
          avatar: Icon(
            Icons.auto_awesome_rounded,
            size: 18,
            color: colors.primary,
          ),
          label: Text(
            t.recapOpen('$year'),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
          side: BorderSide(color: colors.primary.withValues(alpha: .3)),
          backgroundColor: colors.primary.withValues(alpha: .08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          onPressed: () => showYearRecap(context, year),
        ),
      ),
    );
  }
}
