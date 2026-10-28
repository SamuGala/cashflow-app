import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'pin_storage.dart';
import 'biometric_service.dart';
import 'package:pocket_vault/l10n/app_localizations.dart';

class PinPage extends ConsumerStatefulWidget {
  const PinPage({super.key});

  @override
  ConsumerState<PinPage> createState() => _PinPageState();
}

class _PinPageState extends ConsumerState<PinPage>
    with SingleTickerProviderStateMixin {
  final storage = PinStorage();
  final biometric = BiometricService();

  String pin = "";
  String confirmPin = "";

  bool isSetup = false;
  bool biometricsEnabled = false;

  late AnimationController shakeController;

  @override
  void initState() {
    super.initState();

    shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSecurity();
    });
  }

  Future<void> _initSecurity() async {
    final savedPin = await storage.getPin();
    final biometrics = await storage.biometricsEnabled();

    if (!mounted) return;

    if ((savedPin == null || savedPin.isEmpty) && biometrics) {
      await storage.disableBiometrics();
    }

    if (savedPin == null || savedPin.isEmpty) {
      setState(() => isSetup = true);
      return;
    }

    setState(() => biometricsEnabled = biometrics);

    if (biometricsEnabled && mounted) {
      final ok = await biometric.authenticate(
        reason: AppLocalizations.of(context)!.biometricReason,
      );

      if (ok && mounted) {
        ref.read(authProvider.notifier).unlock();
      }
    }
  }

  Future<void> _askEnableBiometrics() async {
    final canUse = await biometric.canUseBiometrics();

    if (!canUse || !mounted) return;

    final t = AppLocalizations.of(context)!;
    final enable = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.enableBiometrics),
        content: Text(t.enableBiometricsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.notNow),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.enable),
          ),
        ],
      ),
    );

    if (enable == true) {
      await storage.enableBiometrics();
      if (mounted) setState(() => biometricsEnabled = true);
    }
  }

  void addDigit(String digit) async {
    if (pin.length >= 6) return;

    HapticFeedback.lightImpact();

    setState(() {
      pin += digit;
    });

    if (pin.length == 6) {
      if (isSetup) {
        if (confirmPin.isEmpty) {
          confirmPin = pin;
          pin = "";
          setState(() {});
          return;
        }

        if (confirmPin == pin) {
          await storage.savePin(pin);

          await _askEnableBiometrics();

          if (mounted) {
            ref.read(authProvider.notifier).unlock();
          }
        } else {
          pin = "";
          confirmPin = "";

          shakeController.forward(from: 0);

          HapticFeedback.heavyImpact();

          setState(() {});
        }

        return;
      }

      final savedPin = await storage.getPin();

      if (savedPin == pin) {
        ref.read(authProvider.notifier).unlock();
      } else {
        pin = "";

        shakeController.forward(from: 0);

        HapticFeedback.heavyImpact();

        setState(() {});
      }
    }
  }

  void removeDigit() {
    if (pin.isEmpty) return;

    HapticFeedback.lightImpact();

    setState(() {
      pin = pin.substring(0, pin.length - 1);
    });
  }

  void clearPin() {
    if (pin.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() => pin = '');
  }

  Future<void> _authenticateBiometrically() async {
    final ok = await biometric.authenticate(
      reason: AppLocalizations.of(context)!.biometricReason,
    );
    if (ok && mounted) {
      ref.read(authProvider.notifier).unlock();
    }
  }

  @override
  void dispose() {
    shakeController.dispose();
    super.dispose();
  }

  Widget dot(BuildContext context, bool filled) {
    final colors = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 13,
      height: 13,
      margin: const EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
        color: filled ? colors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? colors.primary : colors.outline,
          width: 1.6,
        ),
      ),
    );
  }

  Widget key(BuildContext context, String text) {
    return _PinKeyButton(
      semanticsLabel: text,
      onTap: () => addDigit(text),
      child: Text(
        text,
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget buildKeypad(BuildContext context, AppLocalizations t) {
    Widget row(List<Widget> children) => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );

    return Column(
      children: [
        row([key(context, '1'), key(context, '2'), key(context, '3')]),
        const SizedBox(height: 10),
        row([key(context, '4'), key(context, '5'), key(context, '6')]),
        const SizedBox(height: 10),
        row([key(context, '7'), key(context, '8'), key(context, '9')]),
        const SizedBox(height: 10),
        row([
          biometricsEnabled
              ? _PinKeyButton(
                  semanticsLabel: t.biometricUnlock,
                  isAction: true,
                  onTap: _authenticateBiometrically,
                  child: const Icon(Icons.fingerprint_rounded, size: 30),
                )
              : const SizedBox.square(dimension: 68),
          key(context, '0'),
          _PinKeyButton(
            semanticsLabel: t.deleteDigit,
            semanticsHint: t.clearPin,
            isAction: true,
            onTap: removeDigit,
            onLongPress: clearPin,
            child: const Icon(Icons.backspace_outlined, size: 25),
          ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String title;

    final t = AppLocalizations.of(context)!;

    if (isSetup) {
      title = confirmPin.isEmpty ? t.createPin : t.confirmPin;
    } else {
      title = t.enterPin;
    }

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: math.max(0, constraints.maxHeight - 40),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 310),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.lock_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimaryContainer,
                          size: 29,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(
                        animation: shakeController,
                        builder: (context, child) {
                          final decay = 1 - shakeController.value;
                          final offset =
                              math.sin(shakeController.value * math.pi * 5) *
                              9 *
                              decay;
                          return Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (i) => dot(context, i < pin.length),
                          ),
                        ),
                      ),
                      const SizedBox(height: 46),
                      buildKeypad(context, t),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinKeyButton extends StatelessWidget {
  const _PinKeyButton({
    required this.semanticsLabel,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.isAction = false,
    this.semanticsHint,
  });

  final String semanticsLabel;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final Widget child;
  final bool isAction;
  final String? semanticsHint;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: semanticsLabel,
      hint: semanticsHint,
      child: SizedBox.square(
        dimension: 68,
        child: Material(
          color: isAction ? Colors.transparent : colors.surface,
          elevation: isAction ? 0 : 1,
          shadowColor: colors.shadow.withValues(alpha: .12),
          shape: CircleBorder(
            side: BorderSide(
              color: isAction
                  ? Colors.transparent
                  : colors.outlineVariant.withValues(alpha: .8),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            onLongPress: onLongPress,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
