import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_planner.dart';

/// The device side of local notifications, behind an interface so tests and
/// planners never touch the platform.
abstract class NotificationGateway {
  /// [onTap] receives the payload of a tapped notification, also when the
  /// tap launched the app.
  Future<void> initialize(void Function(String? payload) onTap);

  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with [planned].
  Future<void> replaceScheduled(
    List<PlannedNotification> planned, {
    required String channelName,
  });

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
    required String channelName,
  });

  Future<void> cancelScheduled();
}

class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _ready;

  static const _channelId = 'pockets_vault_reminders';

  /// On Android MainActivity reads the tap itself and sends it through the
  /// launch channel, also when the activity is recreated; the plugin's own
  /// report would arrive twice or, after a recreation, not at all.
  static bool get _tapsArriveNatively =>
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<void> initialize(void Function(String? payload) onTap) {
    return _ready ??= () async {
      tz_data.initializeTimeZones();
      try {
        final zone = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(zone.identifier));
      } catch (error) {
        debugPrint('Local time zone unavailable, using UTC: $error');
      }
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_stat_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          if (!_tapsArriveNatively) onTap(response.payload);
        },
      );
      if (_tapsArriveNatively) return;
      final launch = await _plugin.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        onTap(launch!.notificationResponse?.payload);
      }
    }();
  }

  @override
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    return false;
  }

  NotificationDetails _details(String channelName) => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      channelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  Future<void> cancelScheduled() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= recurringIdBase && request.id < budgetIdBase) {
        await _plugin.cancel(id: request.id);
      }
    }
  }

  @override
  Future<void> replaceScheduled(
    List<PlannedNotification> planned, {
    required String channelName,
  }) async {
    await cancelScheduled();
    final details = _details(channelName);
    for (final item in planned) {
      await _plugin.zonedSchedule(
        id: item.id,
        scheduledDate: tz.TZDateTime.from(item.at, tz.local),
        notificationDetails: details,
        // Reminders do not need to the minute: no exact-alarm permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: item.title,
        body: item.body,
        payload: item.payload,
      );
    }
  }

  @override
  Future<void> showNow({
    required int id,
    required String title,
    required String body,
    required String payload,
    required String channelName,
  }) {
    return _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: _details(channelName),
      payload: payload,
    );
  }
}
