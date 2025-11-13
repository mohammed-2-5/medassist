# AI Models & Packages Guide - MedAssist
**Created:** 2025-01-12
**Purpose:** Technical specification of AI/ML components for all planned features

---

## 🎯 OVERVIEW

This document details every AI model, package, and technology needed to implement the AI Enhancement Plan for MedAssist.

---

## 📦 CURRENTLY INSTALLED PACKAGES

### AI & ML:
✅ **google_generative_ai: ^0.4.6** - Official Gemini SDK
✅ **dio: ^5.4.0** - HTTP client for REST APIs
✅ **google_mlkit_text_recognition: ^0.15.0** - On-device OCR

### Status:
- **Currently using:** Custom REST API implementation with Dio (in `gemini_service.dart`)
- **Alternative available:** Official `google_generative_ai` SDK (already installed but not used)

---

## 🤖 PRIMARY AI MODEL: GOOGLE GEMINI

### Current Implementation:
**Model:** `gemini-1.5-flash`
**API:** REST API via Dio
**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent`

### Why Gemini 1.5 Flash?
✅ **Fast responses** - <2 seconds average
✅ **Free tier** - 60 requests/min, 1500/day
✅ **Long context** - Up to 1M tokens (perfect for medication history)
✅ **Multimodal** - Can process text, images (future: medication photos)
✅ **Smart** - Handles medical queries well
✅ **Affordable** - $0.075 per 1M input tokens, $0.30 per 1M output

### Alternative Models to Consider:

#### Option 1: Gemini 1.5 Pro (Upgrade)
```yaml
# No package change needed
# Just change model name in API call
```
**Pros:**
- More accurate for complex medical queries
- Better reasoning capabilities
- Same API, easy to switch

**Cons:**
- More expensive ($3.50/$7.00 per 1M tokens)
- Slower responses (3-5 seconds)
- Not needed for our use case

**Recommendation:** ❌ Stick with Flash, Pro is overkill

---

#### Option 2: Gemini Nano (On-Device)
```yaml
# Future Flutter plugin (not available yet)
# Google is working on flutter_gemini_nano plugin
```
**Pros:**
- Completely offline
- Zero API costs
- Privacy-first
- Ultra-fast responses

**Cons:**
- Not available yet (coming in 2025)
- Requires Android 14+ or iOS 17+
- Limited model size (~1.8B parameters)
- May not be as accurate

**Recommendation:** ⏸️ Wait for official release, consider for v2.0

---

#### Option 3: OpenAI GPT-4 (Alternative)
```yaml
dependencies:
  chat_gpt_sdk: ^3.1.2
  # or
  dart_openai: ^5.1.0
```
**Pros:**
- Excellent medical knowledge
- Very accurate responses
- Well-documented API

**Cons:**
- Expensive ($30/$60 per 1M tokens)
- No free tier
- Requires separate API key
- OpenAI privacy concerns

**Recommendation:** ❌ Too expensive for our use case

---

#### Option 4: Llama 3.1 (Open Source)
```yaml
dependencies:
  llama_cpp_dart: ^0.2.0  # On-device inference
  # or host on own server
```
**Pros:**
- Completely free
- Can run on-device or self-hosted
- No API limits
- Full privacy control

**Cons:**
- Complex setup
- Large app size (+2GB for model)
- Requires powerful device
- Slower inference on mobile

**Recommendation:** ❌ Not practical for mobile app

---

## 📦 PACKAGES NEEDED BY FEATURE

## **PHASE 1: Context-Aware AI**

### Required: NONE (No new packages)
Just better prompt engineering with existing Gemini API

### Optional: Switch to Official SDK
```yaml
# Option A: Keep current Dio implementation ✅ RECOMMENDED
# - Already working
# - More control over requests
# - Easier error handling

# Option B: Switch to official SDK
dependencies:
  google_generative_ai: ^0.4.6  # Already installed!
```

#### Migration to Official SDK (if desired):
```dart
// OLD: Custom Dio implementation
final response = await _dio.post(
  '/models/gemini-1.5-flash:generateContent',
  data: {'contents': contents},
);

// NEW: Official SDK
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-1.5-flash',
  apiKey: ApiConstants.geminiApiKey,
);

final response = await model.generateContent([
  Content.text(userMessage),
]);
```

**Recommendation:** ✅ Keep Dio (more control), or migrate to SDK (cleaner code) - both work fine

---

## **PHASE 2: Drug Interaction Checker**

### Approach 1: Rule-Based Database ✅ RECOMMENDED
**Required:** NONE (No packages needed)

**Implementation:**
- Curated JSON/Dart database of 100-200 common interactions
- Fuzzy string matching algorithm (Levenshtein distance)
- Works 100% offline
- Zero API costs
- Instant results

**Example:**
```dart
// Pure Dart implementation
class DrugInteractionDatabase {
  static final List<DrugInteraction> interactions = [
    DrugInteraction(
      drug1: 'warfarin',
      drug2: 'aspirin',
      severity: 'severe',
      description: '...',
    ),
    // ... 200 interactions
  ];
}
```

**Pros:**
✅ Completely offline
✅ Instant (<50ms)
✅ Deterministic results
✅ Easy to update
✅ No API costs
✅ Privacy-safe

**Cons:**
❌ Limited to curated interactions (100-200 most common)
❌ Manual maintenance required
❌ Won't catch rare interactions

**Recommendation:** ✅ Start with this, covers 95% of cases

---

### Approach 2: AI-Powered Checker (Hybrid)
**Required:**
- Existing Gemini API (already have it)

**Implementation:**
- Use Gemini to analyze uncommon drug combinations
- Only call API for interactions NOT in local database
- AI provides reasoning and sources

**Example:**
```dart
Future<List<DrugInteraction>> checkInteractions(List<String> meds) async {
  // First: Check local database
  final localResults = DrugInteractionDatabase.checkInteractions(meds);

  if (localResults.isNotEmpty) {
    return localResults; // Found in database, instant result
  }

  // Second: Ask Gemini for rare combinations
  final prompt = '''Analyze potential interactions between: ${meds.join(', ')}
  Provide severity, description, and clinical significance.''';

  final aiResult = await _geminiService.sendMessage(prompt);
  return _parseInteractionResponse(aiResult);
}
```

**Pros:**
✅ Covers rare interactions
✅ Always up-to-date
✅ Provides reasoning

**Cons:**
❌ Requires internet
❌ Slower (2-3 seconds)
❌ API costs

**Recommendation:** ✅ Use hybrid approach (local first, AI fallback)

---

### Approach 3: Medical API Services
**Options:**

#### FDA Drug Interaction API
```yaml
dependencies:
  dio: ^5.4.0  # Already have it!
```
**Endpoint:** `https://api.fda.gov/drug/label.json`

**Pros:**
- Official government data
- Free, no API key needed
- Comprehensive

**Cons:**
- Complex response format
- Slow (3-5 seconds)
- Requires parsing

---

#### Drugs.com API (Commercial)
```yaml
# Requires paid subscription ($500/month)
# Not recommended for indie app
```

---

#### RxNorm API (NLM)
```yaml
# Free, but drug names only (no interactions)
# Not useful for our case
```

**Recommendation:** ❌ Not needed, local database + Gemini is better

---

## **PHASE 3: Persistent Chat History**

### Required: NONE (No new packages)
Use existing **Drift** database (already installed)

**Implementation:**
```dart
// Add new table to existing database
@DataClassName('ChatHistoryData')
class ChatHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get message => text()();
  BoolColumn get isUser => boolean()();
  DateTimeColumn get timestamp => dateTime()();
}
```

**Recommendation:** ✅ Perfect, no new dependencies

---

## **PHASE 4: Proactive Features**

### Required: NONE (No new packages)
Use existing:
- ✅ Gemini API (for generating messages)
- ✅ flutter_local_notifications (for proactive tips)
- ✅ workmanager (for daily check-ins)

**Implementation:**
- Daily WorkManager task checks adherence
- Generates personalized message via Gemini
- Shows as notification
- Logs to chat history

**Recommendation:** ✅ All packages already installed

---

## **PHASE 5: Symptom Tracking**

### Required: NONE (No new packages)
Use existing Drift database

### Optional: ML for Pattern Detection
```yaml
dependencies:
  tflite_flutter: ^0.10.4  # TensorFlow Lite
```

**Use case:** Train model to detect symptom-medication correlations

**Example:**
```dart
// Train simple classifier
class SymptomCorrelationModel {
  // Input: [medication_id, hour_taken, symptom_severity]
  // Output: [correlation_score]

  Future<double> predictCorrelation(Symptom symptom, DoseHistory dose) async {
    final input = [
      dose.medicationId.toDouble(),
      dose.scheduledHour.toDouble(),
      symptom.severityLevel.toDouble(),
    ];

    final output = await _interpreter.run(input);
    return output[0];
  }
}
```

**Pros:**
✅ On-device ML
✅ Fast predictions
✅ Privacy-safe

**Cons:**
❌ Need training data
❌ Complex setup
❌ Overkill for simple correlations

**Recommendation:** ❌ Not needed, simple time-based correlation is enough

---

## **PHASE 6: Voice Capabilities**

### Required Packages:

#### Voice Input (Speech-to-Text)
```yaml
dependencies:
  speech_to_text: ^7.0.0
```

**Features:**
- Real-time speech recognition
- Multiple language support (English, Arabic)
- On-device processing (Android 5+, iOS 10+)
- Works offline with downloaded language packs

**Implementation:**
```dart
import 'package:speech_to_text/speech_to_text.dart';

final speech = SpeechToText();
await speech.initialize();

await speech.listen(
  onResult: (result) {
    setState(() {
      _messageController.text = result.recognizedWords;
    });
  },
  localeId: 'en_US', // or 'ar_SA' for Arabic
);
```

**Cost:** FREE (uses device APIs)

---

#### Voice Output (Text-to-Speech)
```yaml
dependencies:
  flutter_tts: ^4.2.0
```

**Features:**
- Natural voice synthesis
- 50+ languages
- Voice/pitch/speed control
- On-device processing

**Implementation:**
```dart
import 'package:flutter_tts/flutter_tts.dart';

final tts = FlutterTts();
await tts.setLanguage('en-US'); // or 'ar-SA'
await tts.setPitch(1.0);
await tts.setSpeechRate(0.5);
await tts.speak('Your medication reminder is ready');
```

**Cost:** FREE (uses device APIs)

---

### Alternative: Google Cloud Speech/TTS
```yaml
dependencies:
  google_speech: ^2.2.0
```

**Pros:**
- Better quality
- More natural voices
- Neural TTS

**Cons:**
- Requires API key
- Costs money ($4 per 1M characters)
- Requires internet

**Recommendation:** ✅ Use free on-device packages (speech_to_text + flutter_tts)

---

## **PHASE 7: Advanced NLP**

### Option 1: Gemini API (Recommended)
**Required:** NONE (already have it)

Gemini already handles:
- Intent recognition
- Entity extraction
- Sentiment analysis
- Context understanding

**Example:**
```dart
final prompt = '''Extract structured data from: "$userMessage"
Return JSON with: intent, entities, sentiment
Example: "I'm having headaches at 2pm daily"
Output: {"intent": "symptom_report", "symptom": "headache", "time": "14:00", "frequency": "daily"}
''';

final response = await _geminiService.sendMessage(prompt);
final data = jsonDecode(response);
```

**Recommendation:** ✅ Use Gemini, no new packages needed

---

### Option 2: On-Device NLP (TensorFlow Lite)
```yaml
dependencies:
  tflite_flutter: ^0.10.4
  # + download pre-trained models
```

**Use cases:**
- Intent classification
- Named entity recognition (NER)
- Sentiment analysis

**Example Models:**
- MobileBERT (50MB) - Intent classification
- DistilBERT (250MB) - NER
- TinyBERT (20MB) - Sentiment

**Pros:**
✅ Works offline
✅ Fast inference (<100ms)
✅ Privacy-safe
✅ No API costs

**Cons:**
❌ Large app size (+50-250MB)
❌ Limited accuracy vs cloud models
❌ Requires model management
❌ Complex setup

**Recommendation:** ❌ Not needed, Gemini handles this better

---

### Option 3: Flutter NLP Packages
```yaml
dependencies:
  flutter_langdetect: ^0.0.2      # Language detection
  string_similarity: ^2.0.0        # Fuzzy matching
  porter_stemmer_2: ^2.0.1        # Word stemming
```

**Use cases:**
- Detect if user is writing in English or Arabic
- Match user input to known intents
- Normalize text before processing

**Recommendation:** ✅ Useful for preprocessing, but not essential

---

## 🎯 RECOMMENDED PACKAGE ADDITIONS

Based on all phases, here are the ONLY new packages you need:

### **CRITICAL (Must Add):**
```yaml
dependencies:
  # Voice capabilities (Phase 6)
  speech_to_text: ^7.0.0         # Voice input
  flutter_tts: ^4.2.0             # Voice output
```

### **OPTIONAL (Nice to Have):**
```yaml
dependencies:
  # Enhanced string matching for drug names
  string_similarity: ^2.0.0       # Fuzzy matching

  # Language detection (if supporting multiple languages)
  flutter_langdetect: ^0.0.2
```

### **NOT NEEDED:**
❌ TensorFlow Lite - Gemini is better
❌ Additional AI APIs - Gemini is sufficient
❌ On-device ML models - Too complex, not needed
❌ Commercial APIs - Too expensive

---

## 💰 COST ANALYSIS

### Current Setup (Gemini Flash):
- **Free tier:** 1,500 requests/day
- **Typical usage:** 20 requests/user/day
- **Users supported:** 75 free users/day
- **Cost per user:** $0.00 (within free tier)

### If Exceeding Free Tier:
- **Gemini Flash:** $0.075 per 1M input tokens
- **Average message:** 1,000 tokens (with context)
- **Cost per message:** $0.000075
- **20 messages/day:** $0.0015/day = $0.045/month per user
- **1000 users:** $45/month

### Voice APIs (On-Device):
- **Speech-to-Text:** FREE
- **Text-to-Speech:** FREE
- No cloud costs!

### Total AI Cost Estimate:
- **0-1000 users:** $0-50/month
- **1000-10000 users:** $50-500/month
- **10000+ users:** Consider paid Gemini tier or optimize

---

## 🏗️ ARCHITECTURE DECISION

### Recommended Stack:

```yaml
dependencies:
  # AI Core (Already installed)
  google_generative_ai: ^0.4.6    # Gemini SDK
  dio: ^5.4.0                      # For custom API calls

  # Database (Already installed)
  drift: ^2.28.2                   # Chat history, symptoms

  # Voice (NEW)
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.0

  # Utils (Already installed)
  intl: ^0.20.2                    # Date formatting
  shared_preferences: ^2.2.2       # Settings
```

### Architecture Diagram:

```
┌─────────────────────────────────────────┐
│           MedAssist App                 │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │   UI Layer (Flutter)            │   │
│  │   - ChatbotScreen               │   │
│  │   - Voice Input Button          │   │
│  │   - Symptom Logger              │   │
│  └──────────┬──────────────────────┘   │
│             │                           │
│  ┌──────────▼──────────────────────┐   │
│  │   Service Layer                 │   │
│  │   - GeminiService               │   │
│  │   - SpeechToText               │   │
│  │   - FlutterTts                  │   │
│  │   - DrugInteractionDB           │   │
│  └──────────┬──────────────────────┘   │
│             │                           │
│  ┌──────────▼──────────────────────┐   │
│  │   Data Layer (Drift)            │   │
│  │   - Medications                 │   │
│  │   - ChatHistory                 │   │
│  │   - Symptoms                    │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
             │
             │ HTTPS
             ▼
┌─────────────────────────────────────────┐
│   Google Gemini API (Cloud)             │
│   - gemini-1.5-flash                    │
│   - Context-aware responses             │
│   - Structured output                   │
└─────────────────────────────────────────┘
```

---

## 🔒 PRIVACY & SECURITY

### Data Flow:

**Local (On-Device):**
- ✅ All medication data
- ✅ All dose history
- ✅ All symptoms
- ✅ Chat history
- ✅ Drug interaction checks
- ✅ Voice transcription (Android/iOS APIs)
- ✅ TTS synthesis

**Sent to Cloud (Gemini API):**
- ❌ Medication names (only in context, not stored by Google)
- ❌ User questions (not stored, per Google's policy)
- ✅ Responses are not used for training (Gemini policy)

**Privacy Best Practices:**
1. Anonymous API calls (no user identifiers)
2. No PII sent to Gemini
3. Local-first architecture
4. Can work offline (except chatbot)
5. User controls all data

---

## ✅ FINAL RECOMMENDATIONS

### **Phase-by-Phase Package Plan:**

**Phase 1-2 (Weeks 1-2):**
```yaml
# No new packages needed!
# Use existing:
# - google_generative_ai (or Dio)
# - drift
```

**Phase 3-4 (Weeks 3-4):**
```yaml
# No new packages needed!
# Use existing packages
```

**Phase 5 (Week 5, Optional):**
```yaml
# No new packages needed!
# Use existing Drift database
```

**Phase 6 (Week 6, Optional):**
```yaml
dependencies:
  speech_to_text: ^7.0.0
  flutter_tts: ^4.2.0
```

**Phase 7 (Week 7, Optional):**
```yaml
# No new packages needed!
# Use Gemini for NLP
```

---

## 🎯 SUMMARY

### What You Already Have:
✅ Google Gemini API (perfect for AI chatbot)
✅ Drift database (perfect for chat history)
✅ Dio (perfect for API calls)
✅ All infrastructure ready!

### What You Need to Add:
1. **speech_to_text** (voice input)
2. **flutter_tts** (voice output)

**That's it!** Just 2 new packages for full AI enhancement.

### What You DON'T Need:
❌ TensorFlow Lite
❌ OpenAI GPT
❌ Commercial APIs
❌ On-device models
❌ Additional SDKs

### Cost:
- **Phases 1-5:** $0-50/month (within Gemini free tier)
- **Phase 6:** $0 (on-device voice)
- **Phase 7:** $0 (uses Gemini)

**Total additional cost: $0-50/month** 🎉

---

## 📝 MIGRATION STEPS

If you want to switch from Dio to official SDK:

### Step 1: Update GeminiService
```dart
// Replace custom Dio implementation with SDK
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  void initialize() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: ApiConstants.geminiApiKey,
    );
  }

  Future<String> sendMessage(String message) async {
    final content = [Content.text(message)];
    final response = await _model.generateContent(content);
    return response.text ?? '';
  }
}
```

### Step 2: Test
```bash
flutter test
flutter run
```

### Step 3: Verify
- Check API calls are working
- Verify chat history preserved
- Test error handling

---

**End of AI Models & Packages Guide**

**TL;DR:**
- Keep using Gemini 1.5 Flash ✅
- Add only 2 packages for voice (speech_to_text + flutter_tts)
- Everything else uses existing infrastructure
- Total cost: $0-50/month
- 95% of features work offline

