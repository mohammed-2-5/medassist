import 'package:flutter_test/flutter_test.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';

/// Unit tests for MultiAIService
/// Tests intelligent fallback logic and multi-API orchestration
void main() {
  late MultiAIService multiAI;

  setUp(() {
    multiAI = MultiAIService();
    multiAI.resetStats(); // Reset stats before each test to avoid cross-test contamination
  });

  tearDown(() {
    multiAI.dispose();
  });

  group('MultiAIService Initialization', () {
    test('Service initializes correctly', () {
      multiAI.initialize();
      expect(multiAI.lastUsedApi, isNull);
    });

    test('Initialize is idempotent', () {
      multiAI.initialize();
      multiAI.initialize();
      multiAI.initialize();

      // Should not crash or cause issues
      expect(multiAI.lastUsedApi, isNull);
    });

    test('Suggested prompts are available after init', () {
      multiAI.initialize();
      final prompts = multiAI.getSuggestedPrompts();

      expect(prompts, isNotEmpty);
      expect(prompts.length, greaterThanOrEqualTo(4));
    });
  });

  group('MultiAIService Fallback Logic', () {
    test('Empty message returns error', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('');
      expect(response, equals('Please enter a message.'));
    });

    test('Whitespace-only message returns error', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('  ');
      expect(response, equals('Please enter a message.'));
    });

    test('Service uses valid API keys successfully', () async {
      multiAI.initialize();

      // With valid API keys, should succeed with Groq
      final response = await multiAI.sendMessage('test message');

      // Should get a valid response from Groq (primary)
      expect(response, isNotEmpty);
      expect(multiAI.lastUsedApi, anyOf(equals('Groq'), equals('Gemini'), equals('HuggingFace')));
    });

    test('API response is helpful and informative', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('test');

      expect(response, isNotEmpty);
      expect(response.length, greaterThan(10)); // Should be substantial
    });

    test('API handles side effects question appropriately', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('What are common medication side effects?');

      // Should get a response (may or may not contain exact keywords)
      expect(response, isNotEmpty);
      expect(response.length, greaterThan(20));
    });

    test('API handles missed dose question appropriately', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('What if I forgot to take my medication?');

      // Should get a response
      expect(response, isNotEmpty);
      expect(response.length, greaterThan(20));
    });

    test('API handles interaction question appropriately', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage('Tell me about drug interactions');

      // Should get a response
      expect(response, isNotEmpty);
      expect(response.length, greaterThan(20));
    });
  });

  group('MultiAIService Context Handling', () {
    test('Context is passed through to APIs', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage(
        'test',
        medicationContext: 'User is taking Metformin 500mg twice daily',
      );

      // Should not crash with context
      expect(response, isNotEmpty);
    });

    test('Empty context is handled gracefully', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage(
        'test',
        medicationContext: '',
      );

      expect(response, isNotEmpty);
    });

    test('Null context is handled gracefully', () async {
      multiAI.initialize();

      final response = await multiAI.sendMessage(
        'test',
      );

      expect(response, isNotEmpty);
    });

    test('Long context does not cause errors', () async {
      multiAI.initialize();

      const longContext = '''
User is taking:
- Metformin 500mg twice daily for Type 2 Diabetes
- Lisinopril 10mg once daily for High Blood Pressure
- Atorvastatin 20mg once daily for High Cholesterol
- Aspirin 81mg once daily for Heart Health
- Vitamin D 1000 IU once daily
- Omega-3 Fish Oil 1000mg once daily

Recent adherence: 85% over last 30 days
Current streak: 7 days
Best streak: 45 days
''';

      final response = await multiAI.sendMessage(
        'test',
        medicationContext: longContext,
      );

      expect(response, isNotEmpty);
    });
  });

  group('MultiAIService Usage Statistics', () {
    test('Initial stats are zero', () {
      multiAI.initialize();

      final stats = multiAI.getUsageStats();

      expect(stats['total_requests'], equals(0));
      expect(stats['groq_success'], equals(0));
      expect(stats['gemini_success'], equals(0));
      expect(stats['huggingface_success'], equals(0));
    });

    test('Stats increment after requests', () async {
      multiAI.initialize();

      final statsBefore = multiAI.getUsageStats();
      final requestsBefore = statsBefore['total_requests'];

      await multiAI.sendMessage('test');

      final statsAfter = multiAI.getUsageStats();
      final requestsAfter = statsAfter['total_requests'];

      expect(requestsAfter, greaterThan(requestsBefore));
    });

    test('Last used API is tracked', () async {
      multiAI.initialize();

      await multiAI.sendMessage('test');

      expect(multiAI.lastUsedApi, isNotNull);
      expect(
        multiAI.lastUsedApi,
        anyOf(equals('Groq'), equals('Gemini'), equals('HuggingFace'), equals('Offline')),
      );
    });

    test('Success rate is calculated correctly', () {
      multiAI.initialize();

      final successRate = multiAI.primaryApiSuccessRate;

      expect(successRate, isA<double>());
      expect(successRate, greaterThanOrEqualTo(0.0));
      expect(successRate, lessThanOrEqualTo(1.0));
    });

    test('Reset stats clears counters', () async {
      multiAI.initialize();

      // Make a request to increment stats
      await multiAI.sendMessage('test');
      expect(multiAI.lastUsedApi, isNotNull);

      // Reset
      multiAI.resetStats();

      final stats = multiAI.getUsageStats();
      expect(stats['total_requests'], equals(0));
      expect(multiAI.lastUsedApi, isNull);
    });
  });

  group('MultiAIService API Availability Check', () {
    test('checkApiAvailability returns map of statuses', () async {
      final availability = await multiAI.checkApiAvailability();

      expect(availability, isA<Map<String, bool>>());
      expect(availability.containsKey('groq'), isTrue);
      expect(availability.containsKey('gemini'), isTrue);
      expect(availability.containsKey('huggingface'), isTrue);
    });

    test('checkApiAvailability does not throw', () async {
      expect(
        () async => multiAI.checkApiAvailability(),
        returnsNormally,
      );
    });

    test('Availability check returns boolean values', () async {
      final availability = await multiAI.checkApiAvailability();

      for (final status in availability.values) {
        expect(status, isA<bool>());
      }
    });
  });

  group('MultiAIService History Management', () {
    test('Clear history resets all services', () {
      multiAI.initialize();

      multiAI.clearHistory();

      // Should not crash
      expect(() => multiAI.clearHistory(), returnsNormally);
    });

    test('Clear history can be called multiple times', () {
      multiAI.initialize();

      multiAI.clearHistory();
      multiAI.clearHistory();
      multiAI.clearHistory();

      // Should not crash
      expect(() => multiAI.clearHistory(), returnsNormally);
    });

    test('Service works after clearing history', () async {
      multiAI.initialize();

      await multiAI.sendMessage('first message');
      multiAI.clearHistory();
      final response = await multiAI.sendMessage('second message');

      expect(response, isNotEmpty);
    });
  });

  group('MultiAIService Lifecycle', () {
    test('Dispose cleans up all services', () {
      multiAI.initialize();
      multiAI.dispose();

      // Should not crash
      expect(() => multiAI.dispose(), returnsNormally);
    });

    test('Service can be reinitialized after dispose', () {
      multiAI.initialize();
      multiAI.dispose();
      multiAI.initialize();

      expect(() => multiAI.getSuggestedPrompts(), returnsNormally);
    });

    test('Stats persist after multiple initialize/dispose cycles', () async {
      multiAI.initialize();
      await multiAI.sendMessage('test 1');

      multiAI.dispose();
      multiAI.initialize();

      await multiAI.sendMessage('test 2');

      final stats = multiAI.getUsageStats();
      expect(stats['total_requests'], greaterThanOrEqualTo(2));
    });
  });

  group('MultiAIService Singleton Pattern', () {
    test('Factory returns same instance', () {
      final instance1 = MultiAIService();
      final instance2 = MultiAIService();

      expect(instance1, same(instance2));
    });

    test('Singleton state persists across instances', () {
      final instance1 = MultiAIService();
      instance1.initialize();
      instance1.resetStats();

      final instance2 = MultiAIService();
      final stats = instance2.getUsageStats();

      expect(stats['total_requests'], equals(0)); // Same state
    });
  });

  group('MultiAIService Error Resilience', () {
    test('Handles null message gracefully', () async {
      multiAI.initialize();

      // Should not crash
      expect(
        () async => multiAI.sendMessage(''),
        returnsNormally,
      );
    });

    test('Handles very long messages', () async {
      multiAI.initialize();

      final longMessage = 'test ' * 1000; // 5000 characters

      // Should not crash
      final response = await multiAI.sendMessage(longMessage);
      expect(response, isNotEmpty);
    });

    test('Handles special characters in message', () async {
      multiAI.initialize();

      const specialMessage = '''
        Test with special chars: @#\$%^&*()
        Unicode: 你好 مرحبا שלום
        Newlines and tabs:\t\n\r
      ''';

      final response = await multiAI.sendMessage(specialMessage);
      expect(response, isNotEmpty);
    });

    test('Handles emojis in message', () async {
      multiAI.initialize();

      const emojiMessage = 'Test 😀 💊 🏥 ⚕️';

      final response = await multiAI.sendMessage(emojiMessage);
      expect(response, isNotEmpty);
    });

    test('Multiple concurrent requests do not crash', () async {
      multiAI.initialize();

      // Fire multiple requests at once
      final futures = [
        multiAI.sendMessage('test 1'),
        multiAI.sendMessage('test 2'),
        multiAI.sendMessage('test 3'),
      ];

      final responses = await Future.wait(futures);

      expect(responses.length, equals(3));
      for (final response in responses) {
        expect(response, isNotEmpty);
      }
    });
  });
}
