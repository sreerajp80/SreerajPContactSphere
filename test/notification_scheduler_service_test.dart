// test/notification_scheduler_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/notification_scheduler_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ScheduledNotificationItem', () {
    test('calculates remainingDuration and isExpired correctly', () {
      final now = DateTime.now();
      final future = now.add(const Duration(minutes: 10));
      final item = ScheduledNotificationItem(
        id: 'notif_1',
        title: 'Test Title',
        body: 'Test Body',
        scheduledAt: now,
        fireAt: future,
        payload: 'test_payload',
      );

      expect(item.isExpired, isFalse);
      expect(item.remainingDuration.inMinutes, greaterThanOrEqualTo(9));
      expect(item.payload, equals('test_payload'));
    });

    test('serializes to and from JSON', () {
      final now = DateTime.now();
      final future = now.add(const Duration(minutes: 30));
      final item = ScheduledNotificationItem(
        id: 'notif_2',
        title: 'Call Back',
        body: 'Remember to call John',
        scheduledAt: now,
        fireAt: future,
        payload: 'contact_123',
        category: 'reminder',
      );

      final json = item.toJson();
      final restored = ScheduledNotificationItem.fromJson(json);

      expect(restored.id, equals(item.id));
      expect(restored.title, equals(item.title));
      expect(restored.body, equals(item.body));
      expect(restored.payload, equals(item.payload));
      expect(restored.category, equals(item.category));
    });
  });

  group('NotificationSchedulerService', () {
    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
        switch (call.method) {
          case 'scheduleNotification':
            return true;
          case 'cancelNotification':
            return null;
          case 'getPendingNotificationIds':
            return <String>[];
          case 'hasExactAlarmPermission':
            return true;
          case 'getPendingNotificationPayload':
            return 'payload_sample';
          default:
            return null;
        }
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, null);
    });

    test('schedules and cancels notification task', () async {
      final service = NotificationSchedulerService();
      final future = DateTime.now().add(const Duration(minutes: 15));

      final task = await service.scheduleNotification(
        id: 'test_n1',
        title: 'Meeting Alert',
        body: 'Prepare call notes',
        fireAt: future,
        payload: 'contact_456',
      );

      expect(service.activeTasks.any((t) => t.id == task.id), isTrue);

      await service.cancelNotification(task.id);
      expect(service.activeTasks.any((t) => t.id == task.id), isFalse);
    });

    test('queries pending notification payload', () async {
      final service = NotificationSchedulerService();
      final payload = await service.getPendingNotificationPayload();
      expect(payload, equals('payload_sample'));
    });
  });
}
