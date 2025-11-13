# AI Enhancement Plan - MedAssist
**Created:** 2025-01-12
**Priority:** MEDIUM-HIGH
**Estimated Effort:** 3-4 weeks
**Current AI Status:** Basic Gemini integration (20% complete)

---

## 🎯 OVERVIEW

Transform MedAssist's AI chatbot from a basic Q&A assistant into an intelligent, context-aware health companion that understands your medications, detects potential issues, and provides personalized guidance.

---

## 📊 CURRENT STATE ANALYSIS

### ✅ What Exists:
- Basic GeminiService with REST API integration
- ChatbotScreen with Material Design 3 UI
- Simple chat history (in-memory only)
- Generic system prompt
- 8 suggested prompts
- Error handling for API failures
- Typing indicator

### ❌ What's Missing:
- **No context awareness** - AI doesn't know user's medications
- **No persistence** - Chat history lost on app restart
- **No drug interactions** - Can't warn about dangerous combinations
- **No medical knowledge base** - Relies solely on Gemini's training
- **No proactive assistance** - Only reactive Q&A
- **No symptom tracking** - Can't correlate symptoms with medications
- **No voice input/output** - Text only
- **No personalization** - Same experience for all users

---

## 🚀 ENHANCEMENT PHASES

## **PHASE 1: CONTEXT-AWARE AI** ⭐ HIGH PRIORITY
**Effort:** 1 week
**Impact:** VERY HIGH - Makes AI truly useful

### 1.1 Medication Context Integration
**Goal:** AI knows exactly what medications user is taking

#### Implementation:
**File:** `lib/services/ai/medication_context_service.dart` (NEW - ~200 lines)
```dart
class MedicationContextService {
  final AppDatabase _database;

  // Generate context summary for AI
  Future<String> getMedicationContext() async {
    final medications = await _database.getAllMedications();

    String context = "User's Current Medications:\n";
    for (final med in medications) {
      if (med.isActive) {
        context += "- ${med.medicineName} (${med.medicineType})\n";
        context += "  Dosage: ${med.dosageAmount}${med.dosageUnit}\n";
        context += "  Frequency: ${med.frequency}\n";
        context += "  Times: ${await _getReminderTimes(med.id)}\n";
      }
    }
    return context;
  }

  // Get adherence context for AI recommendations
  Future<String> getAdherenceContext() async {
    final analytics = AnalyticsNotifier(_database);
    final weekStats = await analytics.getWeekAdherence();
    final insights = await analytics.getMedicationInsights();

    String context = "\nRecent Adherence:\n";
    context += "- Overall: ${weekStats.adherencePercentage.toStringAsFixed(1)}%\n";
    context += "- Taken: ${weekStats.takenDoses}/${weekStats.totalDoses} doses\n";

    // Add problematic medications
    final problematic = insights.where((i) => i.adherenceRate < 80);
    if (problematic.isNotEmpty) {
      context += "\nMedications with low adherence:\n";
      for (final med in problematic) {
        context += "- ${med.medicationName}: ${med.adherenceRate.toStringAsFixed(1)}%\n";
      }
    }

    return context;
  }

  // Get recent dose history context
  Future<String> getRecentActivityContext() async {
    // Last 7 days of dose activity
    final history = await _database.getAllDoseHistory();
    final recent = history.where((d) =>
      d.scheduledDate.isAfter(DateTime.now().subtract(Duration(days: 7)))
    ).toList();

    final missed = recent.where((d) => d.status == 'missed').length;
    final snoozed = recent.where((d) => d.status == 'snoozed').length;

    String context = "\nRecent Activity (Last 7 days):\n";
    context += "- Total doses: ${recent.length}\n";
    context += "- Missed: $missed\n";
    context += "- Snoozed: $snoozed\n";

    return context;
  }
}
```

#### Modified Files:
**File:** `lib/services/ai/gemini_service.dart`
- Update `_getSystemPrompt()` to include medication context
- Add `setUserContext()` method called before each chat session
- Inject context into conversation automatically

```dart
String _getSystemPrompt() {
  String basePrompt = '''You are MedAssist AI, a personalized medication assistant.

CRITICAL CONTEXT - USER'S MEDICATIONS:
$_userMedicationContext

ADHERENCE INFORMATION:
$_userAdherenceContext

RECENT ACTIVITY:
$_userActivityContext

YOUR ENHANCED CAPABILITIES:
1. Provide personalized advice based on their specific medications
2. Answer questions about their current medications
3. Explain potential interactions between their medications
4. Suggest timing optimizations based on their schedule
5. Offer adherence improvement tips tailored to their patterns
6. Remind them about medication-specific precautions

IMPORTANT GUIDELINES:
- Reference their actual medications when giving advice
- Use specific medication names they're taking
- Provide context-aware recommendations
- Alert about potential drug interactions
- Be empathetic about adherence challenges
- Never diagnose or prescribe - always refer to healthcare provider for medical decisions
''';
  return basePrompt;
}
```

**Benefit:** AI can now say "I see you're taking Metformin. Did you know it's best taken with meals?" instead of generic responses.

---

### 1.2 Enhanced System Prompts
**Goal:** Smarter, more helpful AI responses

#### Implementation:
**File:** `lib/services/ai/prompt_templates.dart` (NEW - ~150 lines)
```dart
class PromptTemplates {
  // Specialized prompts for different scenarios

  static String getDrugInteractionPrompt(List<String> medications) {
    return '''Analyze potential interactions between these medications:
${medications.join(", ")}

Provide:
1. Known interactions (if any)
2. Severity level (mild/moderate/severe)
3. What to watch for
4. Recommendations
''';
  }

  static String getAdherenceImprovementPrompt(MedicationInsight insight) {
    return '''The user is struggling with ${insight.medicationName}.
Current adherence: ${insight.adherenceRate.toStringAsFixed(1)}%
Taken: ${insight.takenDoses}/${insight.totalDoses} doses

Provide 3-5 practical, personalized tips to improve adherence for this specific medication.
Consider common barriers and provide actionable solutions.
''';
  }

  static String getMedicationTimingPrompt(String medication, List<String> otherMeds) {
    return '''The user takes $medication along with ${otherMeds.join(", ")}.
Provide optimal timing recommendations:
1. Best time of day
2. With or without food
3. Spacing from other medications
4. Things to avoid (e.g., grapefruit, alcohol)
''';
  }

  static String getSideEffectAnalysisPrompt(String medication, String symptoms) {
    return '''The user is taking $medication and experiencing: $symptoms

Analyze:
1. Are these known side effects?
2. How common are they?
3. Should they be concerned?
4. When to contact a doctor
5. Any self-care tips

IMPORTANT: Always err on the side of caution.
''';
  }
}
```

**Benefit:** Structured, high-quality responses for common scenarios.

---

## **PHASE 2: DRUG INTERACTION CHECKER** ⚠️ HIGH PRIORITY
**Effort:** 1 week
**Impact:** CRITICAL - Safety feature

### 2.1 Drug Interaction Database
**Goal:** Offline database of common drug interactions

#### Implementation:
**File:** `lib/services/ai/drug_interactions_db.dart` (NEW - ~400 lines)
```dart
class DrugInteraction {
  final String drug1;
  final String drug2;
  final String severity; // mild, moderate, severe
  final String description;
  final String recommendation;
  final List<String> symptoms;

  DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.severity,
    required this.description,
    required this.recommendation,
    required this.symptoms,
  });
}

class DrugInteractionDatabase {
  // Curated list of common drug interactions
  static final List<DrugInteraction> interactions = [
    DrugInteraction(
      drug1: 'warfarin',
      drug2: 'aspirin',
      severity: 'severe',
      description: 'Both are blood thinners. Taking together increases bleeding risk.',
      recommendation: 'Consult doctor immediately. Do NOT take without medical supervision.',
      symptoms: ['Easy bruising', 'Prolonged bleeding', 'Blood in urine/stool'],
    ),

    DrugInteraction(
      drug1: 'metformin',
      drug2: 'alcohol',
      severity: 'moderate',
      description: 'Alcohol can increase risk of lactic acidosis.',
      recommendation: 'Limit alcohol consumption. Avoid binge drinking.',
      symptoms: ['Nausea', 'Vomiting', 'Rapid breathing', 'Weakness'],
    ),

    DrugInteraction(
      drug1: 'simvastatin',
      drug2: 'grapefruit',
      severity: 'moderate',
      description: 'Grapefruit increases simvastatin levels, raising risk of side effects.',
      recommendation: 'Avoid grapefruit and grapefruit juice.',
      symptoms: ['Muscle pain', 'Weakness', 'Dark urine'],
    ),

    // Add 50-100 most common interactions...
  ];

  // Fuzzy matching for medication names
  static List<DrugInteraction> checkInteractions(List<String> userMedications) {
    final List<DrugInteraction> found = [];

    for (int i = 0; i < userMedications.length; i++) {
      for (int j = i + 1; j < userMedications.length; j++) {
        final med1 = userMedications[i].toLowerCase();
        final med2 = userMedications[j].toLowerCase();

        for (final interaction in interactions) {
          if (_medicationMatches(med1, interaction.drug1) &&
              _medicationMatches(med2, interaction.drug2) ||
              _medicationMatches(med1, interaction.drug2) &&
              _medicationMatches(med2, interaction.drug1)) {
            found.add(interaction);
          }
        }
      }
    }

    return found;
  }

  static bool _medicationMatches(String medication, String interactionDrug) {
    // Fuzzy matching - handles brand names, generics, typos
    medication = medication.toLowerCase().trim();
    interactionDrug = interactionDrug.toLowerCase().trim();

    return medication.contains(interactionDrug) ||
           interactionDrug.contains(medication) ||
           _levenshteinDistance(medication, interactionDrug) <= 2;
  }

  static int _levenshteinDistance(String s1, String s2) {
    // Implementation of Levenshtein distance for fuzzy matching
    // ... (standard algorithm)
  }
}
```

#### Modified Files:
**File:** `lib/features/add_medication/screens/steps/step1_type_info.dart`
- Add interaction check when adding new medication
- Show warning dialog if interaction detected

```dart
Future<void> _checkForInteractions(String newMedication) async {
  final existingMeds = await ref.read(medicationsProvider.future);
  final medNames = existingMeds.map((m) => m.medicineName).toList();
  medNames.add(newMedication);

  final interactions = DrugInteractionDatabase.checkInteractions(medNames);

  if (interactions.isNotEmpty) {
    _showInteractionWarning(interactions);
  }
}

void _showInteractionWarning(List<DrugInteraction> interactions) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Drug Interaction Alert'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: interactions.map((interaction) {
            return Card(
              color: interaction.severity == 'severe'
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${interaction.drug1} + ${interaction.drug2}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Severity: ${interaction.severity.toUpperCase()}',
                      style: TextStyle(
                        color: interaction.severity == 'severe'
                            ? Colors.red
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(interaction.description),
                    SizedBox(height: 8),
                    Text(
                      'Recommendation: ${interaction.recommendation}',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('I Understand'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            // Open chatbot for more info
            context.go('/chatbot');
          },
          child: Text('Ask AI for Details'),
        ),
      ],
    ),
  );
}
```

**Benefit:** Proactive safety warnings before problems occur.

---

### 2.2 Real-time Interaction Monitoring
**Goal:** Continuous monitoring of medication combinations

#### Implementation:
**File:** `lib/services/ai/interaction_monitor_service.dart` (NEW - ~180 lines)
```dart
class InteractionMonitorService {
  final AppDatabase _database;

  // Check for new interactions after medication changes
  Future<void> performDailyCheck() async {
    final medications = await _database.getAllMedications();
    final activeMeds = medications.where((m) => m.isActive).toList();

    if (activeMeds.length < 2) return;

    final medNames = activeMeds.map((m) => m.medicineName).toList();
    final interactions = DrugInteractionDatabase.checkInteractions(medNames);

    if (interactions.isNotEmpty) {
      await _showInteractionNotification(interactions);
      await _logInteractionAlert(interactions);
    }
  }

  Future<void> _showInteractionNotification(List<DrugInteraction> interactions) async {
    final severe = interactions.where((i) => i.severity == 'severe').toList();

    if (severe.isNotEmpty) {
      await NotificationService().showNotification(
        title: '⚠️ Important Drug Interaction Alert',
        body: 'Potential severe interaction detected. Tap to learn more.',
        payload: 'interaction_alert',
      );
    }
  }
}
```

**Benefit:** Ongoing safety monitoring, not just one-time check.

---

## **PHASE 3: PERSISTENT CHAT HISTORY** 💾 MEDIUM PRIORITY
**Effort:** 3-4 days
**Impact:** MEDIUM - Better UX

### 3.1 Chat History Database
**Goal:** Save conversations, build long-term context

#### Implementation:
**File:** `lib/core/database/tables/chat_history_table.dart` (NEW - ~80 lines)
```dart
@DataClassName('ChatHistoryData')
class ChatHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get message => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime()();
  TextColumn get sessionId => text()(); // Group related conversations
  TextColumn get context => text().nullable()(); // What triggered this chat

  @override
  Set<Column> get primaryKey => {id};
}
```

**File:** `lib/core/database/app_database.dart`
- Add ChatHistory table to database
- Add CRUD methods:
```dart
// Insert message
Future<int> insertChatMessage(ChatHistoryCompanion message);

// Get all messages for a session
Future<List<ChatHistoryData>> getChatHistory(String sessionId);

// Get recent conversations (last 30 days)
Future<List<ChatHistoryData>> getRecentChats();

// Clear old history (> 90 days)
Future<void> clearOldChatHistory();

// Search chat history
Future<List<ChatHistoryData>> searchChatHistory(String query);
```

#### Modified Files:
**File:** `lib/services/ai/gemini_service.dart`
- Load chat history from database on init
- Save messages to database after each interaction
- Restore context from previous sessions

**File:** `lib/features/chatbot/screens/chatbot_screen.dart`
- Load previous session on startup
- Add "View History" button
- Add search functionality

**Benefit:** Continuity across app sessions, can reference past conversations.

---

## **PHASE 4: SMART PROACTIVE FEATURES** 🤖 HIGH VALUE
**Effort:** 1 week
**Impact:** HIGH - Differentiation factor

### 4.1 Proactive Health Tips
**Goal:** AI initiates helpful conversations

#### Implementation:
**File:** `lib/services/ai/proactive_ai_service.dart` (NEW - ~250 lines)
```dart
class ProactiveAIService {
  final AppDatabase _database;
  final GeminiService _geminiService;

  // Daily health check-in
  Future<void> performDailyCheckIn() async {
    final insights = await _generateDailyInsights();

    if (insights.isNotEmpty) {
      await _sendProactiveMessage(insights);
    }
  }

  Future<List<String>> _generateDailyInsights() async {
    final insights = <String>[];

    // Check adherence patterns
    final analytics = AnalyticsNotifier(_database);
    final weekStats = await analytics.getWeekAdherence();

    if (weekStats.adherencePercentage < 70) {
      insights.add('adherence_low');
    }

    // Check for streak milestones
    final streak = await analytics.getStreakInfo();
    if (streak.currentStreak > 0 && streak.currentStreak % 7 == 0) {
      insights.add('streak_milestone_${streak.currentStreak}');
    }

    // Check for time-of-day patterns
    final hourlyData = await analytics.getHourlyAdherenceData(
      DateTime.now().subtract(Duration(days: 7)),
      DateTime.now(),
    );

    final problematicHours = hourlyData.where((h) =>
      h.totalDoses > 0 && h.adherencePercentage < 60
    );

    if (problematicHours.isNotEmpty) {
      insights.add('timing_issue');
    }

    return insights;
  }

  Future<void> _sendProactiveMessage(List<String> insights) async {
    String prompt = '''Based on the user's recent medication activity, generate a friendly, encouraging message that:
1. Acknowledges their progress (if any)
2. Gently addresses any concerning patterns: ${insights.join(", ")}
3. Offers 1-2 specific, actionable tips
4. Keeps tone positive and supportive (not judgmental)
5. Keeps it brief (2-3 sentences)

Generate the message:''';

    final message = await _geminiService.sendMessage(prompt);

    // Show as notification
    await NotificationService().showNotification(
      title: '💡 MedAssist Health Tip',
      body: message,
      payload: 'proactive_tip',
    );

    // Also add to chat as "AI initiated" message
    await _database.insertChatMessage(ChatHistoryCompanion(
      message: drift.Value(message),
      isUser: drift.Value(false),
      timestamp: drift.Value(DateTime.now()),
      sessionId: drift.Value('proactive_${DateTime.now().millisecondsSinceEpoch}'),
      context: drift.Value('Daily check-in: ${insights.join(", ")}'),
    ));
  }
}
```

#### Trigger Points:
- Daily at 9 AM
- After achieving streak milestone (7, 14, 30, 60, 90 days)
- When adherence drops below 70%
- After missing 3 consecutive doses
- Weekly summary (Sundays)

**Benefit:** AI feels alive, helpful, and engaged (not just reactive).

---

### 4.2 Smart Question Suggestions
**Goal:** AI suggests relevant questions based on context

#### Implementation:
**File:** `lib/services/ai/smart_suggestions_service.dart` (NEW - ~150 lines)
```dart
class SmartSuggestionsService {
  // Generate contextual suggestions
  Future<List<String>> getContextualSuggestions() async {
    final medications = await _database.getAllMedications();
    final analytics = AnalyticsNotifier(_database);
    final weekStats = await analytics.getWeekAdherence();

    List<String> suggestions = [];

    // Time-based suggestions
    final hour = DateTime.now().hour;
    if (hour < 12) {
      suggestions.add('What should I eat for breakfast with my medications?');
    } else if (hour < 18) {
      suggestions.add('Is it okay to exercise after taking my medication?');
    } else {
      suggestions.add('Can I take my medication before bed?');
    }

    // Adherence-based suggestions
    if (weekStats.adherencePercentage < 80) {
      suggestions.add('How can I remember to take my medications?');
      suggestions.add('What are the consequences of missing doses?');
    }

    // Medication-specific suggestions
    if (medications.any((m) => m.medicineType == 'Injection')) {
      suggestions.add('What are proper injection techniques?');
      suggestions.add('How should I store my injectable medication?');
    }

    // Seasonal suggestions
    final month = DateTime.now().month;
    if (month >= 11 || month <= 3) { // Winter
      suggestions.add('How do cold medications interact with my prescriptions?');
    }

    return suggestions.take(6).toList();
  }
}
```

**Benefit:** Always relevant, personalized question prompts.

---

## **PHASE 5: SYMPTOM TRACKING** 🩺 MEDIUM PRIORITY
**Effort:** 5 days
**Impact:** MEDIUM - Added value feature

### 5.1 Symptom Logger
**Goal:** Track symptoms, correlate with medications

#### Implementation:
**File:** `lib/core/database/tables/symptom_table.dart` (NEW - ~90 lines)
```dart
@DataClassName('SymptomData')
class Symptoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get symptomName => text()();
  IntColumn get severityLevel => integer()(); // 1-10
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get notes => text().nullable()();
  TextColumn get potentialCause => text().nullable()(); // AI suggestion
  IntColumn get linkedMedicationId => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

**File:** `lib/features/chatbot/widgets/symptom_logger_dialog.dart` (NEW - ~200 lines)
```dart
class SymptomLoggerDialog extends StatefulWidget {
  // Quick symptom logging from chatbot
  // Shows common symptoms as chips
  // Allows severity rating
  // AI analyzes correlation with medications
}
```

#### Modified Files:
**File:** `lib/features/chatbot/screens/chatbot_screen.dart`
- Add "Log Symptom" quick action button
- Show symptom trends in chat
- AI references symptoms when giving advice

**File:** `lib/services/ai/gemini_service.dart`
- Include recent symptoms in context
- Prompt AI to analyze correlations

**Benefit:** Better health insights, can spot medication side effects.

---

### 5.2 Symptom-Medication Correlation
**Goal:** AI identifies patterns between symptoms and medications

#### Implementation:
**File:** `lib/services/ai/symptom_correlation_service.dart` (NEW - ~180 lines)
```dart
class SymptomCorrelationService {
  // Analyze symptoms vs medication timing
  Future<List<SymptomInsight>> analyzeCorrelations() async {
    final symptoms = await _database.getAllSymptoms();
    final doseHistory = await _database.getAllDoseHistory();

    List<SymptomInsight> insights = [];

    for (final symptom in symptoms) {
      // Find doses taken within 4 hours before symptom
      final recentDoses = doseHistory.where((dose) {
        return dose.actualTime != null &&
               symptom.occurredAt.difference(dose.actualTime!).inHours <= 4 &&
               symptom.occurredAt.isAfter(dose.actualTime!);
      }).toList();

      if (recentDoses.isNotEmpty) {
        insights.add(SymptomInsight(
          symptom: symptom,
          suspectedMedication: recentDoses.first.medicationId,
          confidence: _calculateConfidence(symptom, recentDoses),
          recommendation: 'Discuss with doctor if this pattern continues',
        ));
      }
    }

    return insights;
  }
}
```

**Benefit:** Early detection of side effects, better doctor communication.

---

## **PHASE 6: VOICE CAPABILITIES** 🎤 LOW PRIORITY
**Effort:** 3-4 days
**Impact:** MEDIUM - Accessibility

### 6.1 Voice Input
**Goal:** Speak to the AI instead of typing

#### Implementation:
- Install `speech_to_text: ^6.6.0` package
- Add microphone button in chat input
- Convert speech to text
- Send to Gemini

**File:** `lib/features/chatbot/screens/chatbot_screen.dart`
```dart
Future<void> _startVoiceInput() async {
  if (!_speechToText.isAvailable) {
    await _speechToText.initialize();
  }

  await _speechToText.listen(
    onResult: (result) {
      setState(() {
        _messageController.text = result.recognizedWords;
      });

      if (result.finalResult) {
        _handleSendMessage();
      }
    },
  );
}
```

---

### 6.2 Voice Output (Text-to-Speech)
**Goal:** AI reads responses aloud

#### Implementation:
- Install `flutter_tts: ^3.8.5` package
- Add speaker button next to AI messages
- Read response with natural voice

---

## **PHASE 7: ADVANCED NLP FEATURES** 🧠 LOW PRIORITY
**Effort:** 1 week
**Impact:** MEDIUM - Better AI understanding

### 7.1 Intent Recognition
**Goal:** Understand user intent, provide structured responses

#### Common Intents:
- `medication_info` - "Tell me about aspirin"
- `dosage_question` - "How much should I take?"
- `side_effects` - "What are the side effects?"
- `interaction_check` - "Can I take this with that?"
- `adherence_help` - "I keep forgetting my medication"
- `symptom_report` - "I'm experiencing headaches"
- `emergency` - "I took too much medication"

---

### 7.2 Structured Data Extraction
**Goal:** Extract actionable data from conversations

Example:
- User: "I've been getting headaches every afternoon around 2 PM"
- AI extracts: `{symptom: 'headache', time: '14:00', frequency: 'daily', severity: 'moderate'}`
- AI logs symptom automatically
- AI asks: "Should I log this symptom for you?"

---

## 📁 FILES TO CREATE (Summary)

### New Services (10 files)
1. `lib/services/ai/medication_context_service.dart` (~200 lines)
2. `lib/services/ai/prompt_templates.dart` (~150 lines)
3. `lib/services/ai/drug_interactions_db.dart` (~400 lines)
4. `lib/services/ai/interaction_monitor_service.dart` (~180 lines)
5. `lib/services/ai/proactive_ai_service.dart` (~250 lines)
6. `lib/services/ai/smart_suggestions_service.dart` (~150 lines)
7. `lib/services/ai/symptom_correlation_service.dart` (~180 lines)

### New Database Tables (2 files)
8. `lib/core/database/tables/chat_history_table.dart` (~80 lines)
9. `lib/core/database/tables/symptom_table.dart` (~90 lines)

### New Widgets (3 files)
10. `lib/features/chatbot/widgets/symptom_logger_dialog.dart` (~200 lines)
11. `lib/features/chatbot/widgets/interaction_warning_card.dart` (~150 lines)
12. `lib/features/chatbot/widgets/chat_history_viewer.dart` (~180 lines)

**Total: ~2,210 new lines of code**

---

## 📊 IMPLEMENTATION PRIORITY

### 🔴 **CRITICAL (Do First)**
1. ✅ **Phase 1**: Context-Aware AI (1 week)
2. ✅ **Phase 2**: Drug Interaction Checker (1 week)

**Impact:** Safety + Personalization = Must-have features

---

### 🟡 **HIGH VALUE (Do Next)**
3. ✅ **Phase 4**: Proactive Features (1 week)
4. ✅ **Phase 3**: Chat History (3-4 days)

**Impact:** Makes AI feel intelligent and helpful

---

### 🟢 **NICE TO HAVE (Optional)**
5. ⏸️ **Phase 5**: Symptom Tracking (5 days)
6. ⏸️ **Phase 6**: Voice Capabilities (3-4 days)
7. ⏸️ **Phase 7**: Advanced NLP (1 week)

**Impact:** Added value but not essential for launch

---

## 💰 COST CONSIDERATIONS

### Gemini API Costs:
- **Free Tier**: 60 requests/minute, 1500 requests/day
- **Typical Usage**: 10-20 messages per user per day
- **Context Size**: ~1000 tokens with full medication context
- **Cost**: FREE for most users, ~$0.10/day for power users

### Recommendations:
1. Use free tier initially
2. Cache AI responses for common questions
3. Implement request throttling (max 30 messages/day per user)
4. Consider premium feature: Unlimited AI chats

---

## ✅ SUCCESS METRICS

### Technical Metrics:
- ✅ Context awareness: AI mentions user's specific medications in 80%+ of responses
- ✅ Drug interaction detection: 100% accuracy for severe interactions
- ✅ Response time: <3 seconds average
- ✅ Error rate: <5% API failures
- ✅ Proactive messages: Sent daily to users with <80% adherence

### User Metrics:
- 📈 Engagement: 40%+ of users chat with AI weekly
- 📈 Retention: AI users have 25%+ higher retention
- 📈 Adherence: AI users show 10-15% adherence improvement
- 📈 Satisfaction: 4.5+ star rating for AI feature
- 📈 Safety: Zero reported adverse events from missed interactions

---

## 🚀 QUICK START (Minimal Viable AI)

**If you only have 1 week, do this:**

### Week 1: Core AI Enhancement
- **Days 1-2**: Medication Context Service (Phase 1.1)
- **Days 3-4**: Drug Interaction Database (Phase 2.1)
- **Days 5-6**: Enhanced System Prompts (Phase 1.2)
- **Day 7**: Testing & Polish

**Result:** AI that knows your medications and warns about interactions = HUGE VALUE!

---

## 📝 NOTES

1. **Privacy:** All AI conversations and health data stay local. Only anonymous queries sent to Gemini API.

2. **Medical Disclaimer:** Add clear disclaimer that AI is not a replacement for professional medical advice.

3. **Offline Mode:** Drug interaction checker works offline. Gemini chat requires internet.

4. **Localization:** AI responses in English initially. Add Arabic support in future.

5. **Testing:** Thoroughly test drug interaction database with pharmacist consultation.

---

**End of AI Enhancement Plan**
**Next Step:** Review priorities with user, then start Phase 1
**Estimated Total Time:** 3-4 weeks for Phases 1-4 (core features)
