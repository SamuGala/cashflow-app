import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StartupReveal extends StatefulWidget {
  const StartupReveal({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<StartupReveal> createState() => _StartupRevealState();
}

class _StartupRevealState extends State<StartupReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _started = false;
  bool _notified = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 2100),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && !_notified) {
            _notified = true;
            widget.onFinished();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.duration = const Duration(milliseconds: 250);
    }
    // Wait until Flutter has painted once so the platform splash is no longer
    // covering this animation on slower cold starts.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: const Color(0xFF312E81),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.primary,
                Color.lerp(colors.primary, const Color(0xFF312E81), .72)!,
              ],
            ),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final entrance = CurvedAnimation(
                parent: _controller,
                curve: const Interval(0, .38, curve: Curves.easeOutBack),
              ).value.clamp(0.0, 1.0).toDouble();
              final progress = CurvedAnimation(
                parent: _controller,
                curve: const Interval(.12, .82, curve: Curves.easeInOutCubic),
              ).value.clamp(0.0, 1.0).toDouble();
              final exit = CurvedAnimation(
                parent: _controller,
                curve: const Interval(.86, 1, curve: Curves.easeInCubic),
              ).value;
              final opacity = (entrance * (1 - exit))
                  .clamp(0.0, 1.0)
                  .toDouble();

              return Opacity(
                opacity: opacity,
                child: Transform.translate(
                  offset: Offset(0, 16 * (1 - entrance)),
                  child: Transform.scale(
                    scale: .84 + (.16 * entrance),
                    child: Center(
                      child: RepaintBoundary(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              key: const ValueKey('startup-app-icon'),
                              width: 92,
                              height: 92,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .25),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .16),
                                    blurRadius: 30,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  'assets/icon/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Pockets Vault',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 29,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .3,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              key: const ValueKey('startup-progress-track'),
                              width: 196,
                              height: 6,
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .18),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: .16),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(99),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: FractionallySizedBox(
                                    key: const ValueKey(
                                      'startup-progress-fill',
                                    ),
                                    widthFactor: progress,
                                    heightFactor: 1,
                                    child: const DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFFFFFF),
                                            Color(0xFFDDD6FE),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
