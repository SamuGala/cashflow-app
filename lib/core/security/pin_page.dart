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

    biometricsEnabled = biometrics;

    if (biometricsEnabled) {
      final ok = await biometric.authenticate();

      if (ok && mounted) {
        ref.read(authProvider.notifier).unlock();
      }
    }
  }

  Future<void> _askEnableBiometrics() async {
    final canUse = await biometric.canUseBiometrics();

    if (!canUse || !mounted) return;

    final enable = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Enable Face ID"),
        content: const Text(
          "Use Face ID to unlock Cashflow?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (enable == true) {
      await storage.enableBiometrics();
      biometricsEnabled = true;
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

  Widget dot(bool filled) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: filled ? 18 : 14,
      height: filled ? 18 : 14,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: filled ? Colors.black : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget key(String text) {
    return InkResponse(
      radius: 36,
      onTap: () => addDigit(text),
      child: Container(
        alignment: Alignment.center,
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildKeypad() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [key("1"), key("2"), key("3")],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [key("4"), key("5"), key("6")],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [key("7"), key("8"), key("9")],
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            biometricsEnabled
                ? InkResponse(
                    onTap: () async {
                      final ok = await biometric.authenticate();

                      if (ok && mounted) {
                        ref.read(authProvider.notifier).unlock();
                      }
                    },
                    child: const SizedBox(
                      width: 78,
                      height: 78,
                      child: Icon(
                        Icons.face,
                        size: 30,
                      ),
                    ),
                  )
                : const SizedBox(width: 78),

            key("0"),

            InkResponse(
              radius: 36,
              onTap: removeDigit,
              child: const SizedBox(
                width: 78,
                height: 78,
                child: Icon(Icons.backspace_outlined),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shake = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );

    String title;

    final t = AppLocalizations.of(context)!;

if (isSetup) {
  title = confirmPin.isEmpty ? t.createPin : t.confirmPin;
} else {
  title = t.enterPin;
}

    return Scaffold(
      body: AnimatedBuilder(
        animation: shakeController,
        builder: (_, child) {
          return Transform.translate(
            offset: Offset(shake.value, 0),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (i) => dot(i < pin.length),
                ),
              ),

              const SizedBox(height: 60),

              buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }
}