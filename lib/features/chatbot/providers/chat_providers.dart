import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/chatbot/models/chat_session.dart';
import 'package:med_assist/features/chatbot/repositories/chat_repository.dart';
import 'package:med_assist/services/ai/medication_context_service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return ChatRepository(database);
});

final chatSessionsProvider = FutureProvider<List<ChatSession>>((ref) async {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getAllSessions();
});

final quickSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final contextService = MedicationContextService(db);
  return contextService.getQuickSuggestions();
});
