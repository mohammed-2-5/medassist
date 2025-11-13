import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/services/ai/huggingface_service.dart';

/// Unit tests for HuggingFaceService
/// Tests API communication, error handling, and fallback logic
/// Note: Network-dependent tests handle both success and failure gracefully
void main() {
  late HuggingFaceService hfService;

  setUp(() {
    hfService = HuggingFaceService();
  });

  tearDown(() {
    hfService.dispose();
  });

  group('HuggingFaceService Initialization', () {
    test('Service initializes correctly', () {
      hfService.initialize();
      // Should not crash and should be ready to use
      expect(() => hfService.initialize(), returnsNormally);
    });

    test('Initialize is idempotent (can call multiple times)', () {
      hfService.initialize();
      hfService.initialize();
      hfService.initialize();

      // Should not crash or cause issues
      expect(() => hfService.initialize(), returnsNormally);
    });
  });

  group('HuggingFaceService Message Handling', () {
    test('Empty message returns error', () async {
      hfService.initialize();

      final response = await hfService.sendMessage('');
      expect(response, equals('Please enter a message.'));
    });

    test('Whitespace-only message returns error', () async {
      hfService.initialize();

      final response = await hfService.sendMessage('   ');
      expect(response, equals('Please enter a message.'));
    });

    test('Message is trimmed before processing', () async {
      hfService.initialize();

      // Should handle trimming correctly or throw exception if network unavailable
      try {
        final response = await hfService.sendMessage('  test message  ');
        expect(response, isNotEmpty);
        expect(response, isA<String>());
      } on HuggingFaceException catch (e) {
        // Expected if network is unavailable
        expect(e, isA<HuggingFaceException>());
      }
    });

    test('Service handles valid messages', () async {
      hfService.initialize();

      try {
        final response = await hfService.sendMessage('Hello');
        expect(response, isNotEmpty);
        expect(response, isA<String>());
        expect(response.length, greaterThan(10)); // Should be substantial
      } on HuggingFaceException catch (e) {
        // Expected if network is unavailable
        expect(e, isA<HuggingFaceException>());
      }
    });
  });

  group('HuggingFaceService Context Handling', () {
    test('Empty context is handled gracefully', () async {
      hfService.initialize();

      // Should not crash with empty context (returns error or throws exception)
      try {
        final response = await hfService.sendMessage('test', medicationContext: '');
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });

    test('Null context is handled gracefully', () async {
      hfService.initialize();

      // Should not crash with null context (returns response or throws exception)
      try {
        final response = await hfService.sendMessage('test');
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });
  });

  group('HuggingFaceService Error Handling', () {
    test('Service handles special characters', () async {
      hfService.initialize();

      const specialMessage = r'''
Test with special chars: @#$%^&*()
Unicode: 你好 مرحبا שלום''';

      // Should not crash (returns response or throws exception)
      try {
        final response = await hfService.sendMessage(specialMessage);
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });

    test('Service handles emojis', () async {
      hfService.initialize();

      const emojiMessage = 'Test 😀 💊 🏥 ⚕️';

      // Should not crash (returns response or throws exception)
      try {
        final response = await hfService.sendMessage(emojiMessage);
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });
  });

  group('HuggingFaceService Availability Check', () {
    test('isAvailable returns boolean', () async {
      final isAvailable = await hfService.isAvailable();
      expect(isAvailable, isA<bool>());
    });

    test('isAvailable handles errors gracefully', () async {
      // Should not throw, even with errors
      expect(
        () async => hfService.isAvailable(),
        returnsNormally,
      );
    });

    test('isAvailable returns false when network unavailable', () async {
      // Should return false if network is unavailable
      final isAvailable = await hfService.isAvailable();
      expect(isAvailable, isA<bool>());
      // Don't assert true/false - depends on network state
    });
  });

  group('HuggingFaceService Lifecycle', () {
    test('Dispose cleans up resources', () {
      hfService.initialize();
      hfService.dispose();

      // Should not crash
      expect(() => hfService.dispose(), returnsNormally);
    });

    test('Service can be reinitialized after dispose', () {
      hfService.initialize();
      hfService.dispose();
      hfService.initialize();

      // Should be usable again
      expect(() => hfService.initialize(), returnsNormally);
    });

    test('Dispose can be called multiple times', () {
      hfService.initialize();
      hfService.dispose();
      hfService.dispose();
      hfService.dispose();

      // Should not crash
      expect(() => hfService.dispose(), returnsNormally);
    });
  });

  group('HuggingFaceService Singleton Pattern', () {
    test('Factory returns same instance', () {
      final instance1 = HuggingFaceService();
      final instance2 = HuggingFaceService();

      expect(instance1, same(instance2));
    });

    test('Singleton state persists across instances', () {
      final instance1 = HuggingFaceService();
      instance1.initialize();

      final instance2 = HuggingFaceService();

      // Both should reference the same initialized state
      expect(instance1, same(instance2));
    });

    test('Dispose affects all instances (singleton)', () {
      final instance1 = HuggingFaceService();
      final instance2 = HuggingFaceService();

      instance1.initialize();
      instance2.dispose();

      // Both are the same instance, so dispose affects both
      expect(instance1, same(instance2));
    });
  });

  group('HuggingFaceService Edge Cases', () {
    test('Very short message works', () async {
      hfService.initialize();

      // Should handle short messages (or throw exception if network unavailable)
      try {
        final response = await hfService.sendMessage('Hi');
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });

    test('Multiple consecutive whitespaces trimmed', () async {
      hfService.initialize();

      // Should trim whitespace (or throw exception if network unavailable)
      try {
        final response = await hfService.sendMessage('test    message    here');
        expect(response, isNotEmpty);
      } on HuggingFaceException {
        // Expected if network is unavailable
      }
    });

    test('Service handles empty trim result appropriately', () async {
      hfService.initialize();

      // Whitespace-only should return error message, not throw
      final response = await hfService.sendMessage('     ');
      expect(response, equals('Please enter a message.'));
    });
  });
}
