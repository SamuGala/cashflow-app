import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AutoLockTimeout { immediately, seconds30, minute1, minutes5, never }

extension AutoLockTimeoutValue on AutoLockTimeout {
  Duration? get duration => switch (this) {
    AutoLockTimeout.immediately => Duration.zero,
    AutoLockTimeout.seconds30 => const Duration(seconds: 30),
    AutoLockTimeout.minute1 => const Duration(minutes: 1),
    AutoLockTimeout.minutes5 => const Duration(minutes: 5),
    AutoLockTimeout.never => null,
  };

  String label(Locale locale) {
    return switch ((this, locale.languageCode)) {
      (AutoLockTimeout.immediately, 'it') => 'Subito',
      (AutoLockTimeout.seconds30, 'it') => 'Dopo 30 secondi',
      (AutoLockTimeout.minute1, 'it') => 'Dopo 1 minuto',
      (AutoLockTimeout.minutes5, 'it') => 'Dopo 5 minuti',
      (AutoLockTimeout.never, 'it') => 'Mai',
      (AutoLockTimeout.immediately, 'es') => 'Inmediatamente',
      (AutoLockTimeout.seconds30, 'es') => 'Después de 30 segundos',
      (AutoLockTimeout.minute1, 'es') => 'Después de 1 minuto',
      (AutoLockTimeout.minutes5, 'es') => 'Después de 5 minutos',
      (AutoLockTimeout.never, 'es') => 'Nunca',
      (AutoLockTimeout.immediately, _) => 'Immediately',
      (AutoLockTimeout.seconds30, _) => 'After 30 seconds',
      (AutoLockTimeout.minute1, _) => 'After 1 minute',
      (AutoLockTimeout.minutes5, _) => 'After 5 minutes',
      (AutoLockTimeout.never, _) => 'Never',
    };
  }
}

const _autoLockKey = 'auto_lock_timeout_v1';

bool shouldAutoLock({
  required DateTime? backgroundedAt,
  required DateTime resumedAt,
  required AutoLockTimeout timeout,
}) {
  final duration = timeout.duration;
  if (backgroundedAt == null || duration == null) return false;
  return !resumedAt.isBefore(backgroundedAt.add(duration));
}

final autoLockProvider =
    AsyncNotifierProvider<AutoLockNotifier, AutoLockTimeout>(
      AutoLockNotifier.new,
    );

class AutoLockNotifier extends AsyncNotifier<AutoLockTimeout> {
  @override
  Future<AutoLockTimeout> build() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getString(_autoLockKey);
    return AutoLockTimeout.values.firstWhere(
      (value) => value.name == stored,
      orElse: () => AutoLockTimeout.seconds30,
    );
  }

  Future<void> setTimeout(AutoLockTimeout timeout) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_autoLockKey, timeout.name);
    state = AsyncData(timeout);
  }
}
