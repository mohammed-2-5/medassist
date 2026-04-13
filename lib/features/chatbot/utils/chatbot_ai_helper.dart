import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/services/ai/medication_context_service.dart';
import 'package:med_assist/services/ai/multi_ai_service.dart';

const chatAiTimeout = Duration(seconds: 30);
const chatTitleMaxLength = 40;

Future<String> sendAiMessage(
  String text, {
  required MultiAIService aiService,
  required AppDatabase db,
}) async {
  String? medicationContext;
  try {
    medicationContext =
        await MedicationContextService(db).getMedicationContext();
  } on Exception {
    medicationContext = null;
  }
  return aiService
      .sendMessage(text, medicationContext: medicationContext)
      .timeout(chatAiTimeout);
}

String generateSessionTitle(String firstMessage) {
  return firstMessage.length > chatTitleMaxLength
      ? '${firstMessage.substring(0, chatTitleMaxLength).trim()}...'
      : firstMessage;
}
