import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_vault/core/security/auto_lock_provider.dart';

void main() {
  final backgroundedAt = DateTime(2026, 7, 31, 12);

  test('immediate auto-lock locks as soon as the app resumes', () {
    expect(
      shouldAutoLock(
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt,
        timeout: AutoLockTimeout.immediately,
      ),
      isTrue,
    );
  });

  test('timed auto-lock respects the configured threshold', () {
    expect(
      shouldAutoLock(
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(seconds: 29)),
        timeout: AutoLockTimeout.seconds30,
      ),
      isFalse,
    );
    expect(
      shouldAutoLock(
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(seconds: 30)),
        timeout: AutoLockTimeout.seconds30,
      ),
      isTrue,
    );
  });

  test('never and a missing background timestamp do not lock', () {
    expect(
      shouldAutoLock(
        backgroundedAt: backgroundedAt,
        resumedAt: backgroundedAt.add(const Duration(days: 1)),
        timeout: AutoLockTimeout.never,
      ),
      isFalse,
    );
    expect(
      shouldAutoLock(
        backgroundedAt: null,
        resumedAt: backgroundedAt,
        timeout: AutoLockTimeout.immediately,
      ),
      isFalse,
    );
  });
}
