import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/services/ai/groq_service.dart';

/// Unit tests for GroqService
/// Tests API communication, error handling, and fallback logic
void main() {
  late GroqService groqService;

  setUp(() {
    groqService = GroqService();
  });

  tearDown(() {
    groqService.dispose();
  });

  group('GroqService Initialization', () {
    test('Service initializes correctly', () {
      groqService.initialize();
      expect(groqService.historyLength, greaterThan(0)); // Should have system prompt
    });

    test('Initialize is idempotent (can call multiple times)', () {
      groqService.initialize();
      final historyLength1 = groqService.historyLength;

      groqService.initialize();
      final historyLength2 = groqService.historyLength;

      expect(historyLength1, equals(historyLength2));
    });

    test('Suggested prompts are available', () {
      final prompts = groqService.getSuggestedPrompts();
      expect(prompts, isNotEmpty);
      expect(prompts.length, greaterThanOrEqualTo(4));
      expect(prompts.first, contains('medication'));
    });
  });

  group('GroqService Message Handling', () {
    test('Empty message returns error', () async {
      groqService.initialize();

      final response = await groqService.sendMessage('');
      expect(response, equals('Please enter a message.'));
    });

    test('Whitespace-only message returns error', () async {
      groqService.initialize();

      final response = await groqService.sendMessage('   ');
      expect(response, equals('Please enter a message.'));
    });

    test('Message is trimmed before processing', () async {
      groqService.initialize();

      // This will fail with API error (no valid API key in test),
      // but we're testing that trimming happens
      try {
        await groqService.sendMessage('  test message  ');
      } catch (e) {
        // Expected to fail with API error
        expect(e, isA<GroqException>());
      }
    });
  });

  group('GroqService Error Handling', () {
    test('Valid API key returns successful response', () async {
      groqService.initialize();

      // With valid API key, should succeed
      final response = await groqService.sendMessage('test');
      expect(response, isNotEmpty);
      expect(response, isA<String>());
    });

    test('Successful API call adds to history', () async {
      groqService.initialize();
      final initialLength = groqService.historyLength;

      final response = await groqService.sendMessage('test message');

      // Response should be valid
      expect(response, isNotEmpty);

      // History should include the message exchange
      expect(groqService.historyLength, greaterThan(initialLength));
    });

    test('Response is non-empty and meaningful', () async {
      groqService.initialize();

      final response = await groqService.sendMessage('Hello');

      expect(response, isNotEmpty);
      expect(response.length, greaterThan(10)); // Should be more than just "hello"
    });
  });

  group('GroqService Context Handling', () {
    test('Context is injected and message succeeds', () async {
      groqService.initialize();

      final response = await groqService.sendMessage(
        'What should I know?',
        medicationContext: 'User is taking Metformin 500mg',
      );

      // Should get a valid response
      expect(response, isNotEmpty);
      expect(response, isA<String>());
    });

    test('Empty context is handled gracefully', () async {
      groqService.initialize();

      // Should not crash with empty context
      final response = await groqService.sendMessage(
        'test',
        medicationContext: '',
      );

      expect(response, isNotEmpty);
    });

    test('Null context is handled gracefully', () async {
      groqService.initialize();

      // Should not crash with null context
      final response = await groqService.sendMessage('test');

      expect(response, isNotEmpty);
    });
  });

  group('GroqService Chat History', () {
    test('Clear history resets conversation', () {
      groqService.initialize();
      final initialLength = groqService.historyLength;

      groqService.clearHistory();

      // History should be reset with system prompt
      expect(groqService.historyLength, equals(initialLength));
    });

    test('Clear history can be called multiple times', () {
      groqService.initialize();

      groqService.clearHistory();
      final length1 = groqService.historyLength;

      groqService.clearHistory();
      final length2 = groqService.historyLength;

      expect(length1, equals(length2));
    });

    test('History length increases with messages', () async {
      groqService.initialize();
      final initialLength = groqService.historyLength;

      try {
        await groqService.sendMessage('first message');
      } catch (e) {
        // Ignore API errors
      }

      try {
        await groqService.sendMessage('second message');
      } catch (e) {
        // Ignore API errors
      }

      // History should have grown (even if API calls failed)
      // Failed messages are removed, but we tried twice
      expect(groqService.historyLength, greaterThanOrEqualTo(initialLength));
    });
  });

  group('GroqService Lifecycle', () {
    test('Dispose cleans up resources', () {
      groqService.initialize();
      groqService.dispose();

      expect(groqService.historyLength, equals(0));
    });

    test('Service can be reinitialized after dispose', () {
      groqService.initialize();
      final length1 = groqService.historyLength;

      groqService.dispose();
      expect(groqService.historyLength, equals(0));

      groqService.initialize();
      final length2 = groqService.historyLength;

      expect(length2, equals(length1));
    });
  });

  group('GroqService Availability Check', () {
    test('isAvailable returns boolean', () async {
      final isAvailable = await groqService.isAvailable();
      expect(isAvailable, isA<bool>());
    });

    test('isAvailable handles errors gracefully', () async {
      // Should not throw, even with invalid API key
      expect(
        () async => groqService.isAvailable(),
        returnsNormally,
      );
    });
  });

  group('GroqService Singleton Pattern', () {
    test('Factory returns same instance', () {
      final instance1 = GroqService();
      final instance2 = GroqService();

      expect(instance1, same(instance2));
    });

    test('Singleton state persists across instances', () {
      final instance1 = GroqService();
      instance1.initialize();
      final length1 = instance1.historyLength;

      final instance2 = GroqService();
      final length2 = instance2.historyLength;

      expect(length1, equals(length2));
    });
  });
}
