// test/smart_redial_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_contacts_dialer/services/smart_redial_service.dart';
import 'package:smart_contacts_dialer/services/telecom_service.dart';
import 'package:smart_contacts_dialer/state/app_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SmartRedialTask', () {
    test('calculates remainingDuration and isExpired correctly', () {
      final now = DateTime.now();
      final future = now.add(const Duration(minutes: 5));
      final task = SmartRedialTask(
        id: 'test_1',
        phoneNumber: '9876543210',
        displayName: 'Alice',
        delayMinutes: 5,
        scheduledAt: now,
        fireAt: future,
      );

      expect(task.isExpired, isFalse);
      expect(task.remainingDuration.inMinutes, greaterThanOrEqualTo(4));
    });
  });

  group('SmartRedialService', () {
    setUp(() {
      // Native only persists a task when the OS alarm was actually armed
      // (see SmartRedialManager.schedule); stub that success here so the
      // Dart-side list-management logic under test isn't blocked by the
      // absence of a real native side.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, (call) async {
            switch (call.method) {
              case 'scheduleSmartRedial':
                return true;
              case 'getPendingSmartRedialIds':
                return <String>[];
              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(TelecomService.methodChannel, null);
    });

    test('schedules and cancels auto-redial task', () async {
      final service = SmartRedialService();
      final task = await service.scheduleAutoRedial(
        phoneNumber: '9876543210',
        displayName: 'Bob',
        delayMinutes: 10,
      );

      expect(service.activeTasks.any((t) => t.id == task.id), isTrue);

      await service.cancelTask(task.id);
      expect(service.activeTasks.any((t) => t.id == task.id), isFalse);
    });
  });

  group('AppSettings Smart Redial', () {
    test('defaults and constants are correct', () {
      expect(
        AppSettings.defaultReachMeMessage,
        contains('Hi, I tried reaching you just now'),
      );
    });
  });
}
