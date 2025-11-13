# AI Cost Analysis & Custom Model Feasibility - MedAssist
**Created:** 2025-01-12
**Purpose:** Realistic analysis of Gemini limits + All free alternatives + Custom model guide

---

## 🚨 HONEST TRUTH: Will Gemini Free Tier Be Enough?

### **SHORT ANSWER: NO (for production scale)**
### **LONGER ANSWER: YES (for MVP and early users)**

Let me show you the math:

---

## 📊 GEMINI FREE TIER REALITY CHECK

### Free Tier Limits:
```
Gemini 1.5 Flash (Free):
- 15 requests per minute (RPM)
- 1,500 requests per day (RPD)
- 1 million requests per month (RPM)
```

### Realistic Usage Per User:

#### Scenario 1: Light User
```
- Opens chatbot: 1-2 times/day
- Asks 3-5 questions per session
- Total: ~10 API calls/day

10 users × 10 calls = 100 calls/day ✅ GOOD
50 users × 10 calls = 500 calls/day ✅ GOOD
100 users × 10 calls = 1,000 calls/day ✅ GOOD
150 users × 10 calls = 1,500 calls/day ✅ AT LIMIT
200 users × 10 calls = 2,000 calls/day ❌ EXCEEDED
```

#### Scenario 2: Active User
```
- Opens chatbot: 3-5 times/day
- Asks 5-10 questions per session
- Uses proactive features (daily tips)
- Total: ~30 API calls/day

10 users × 30 calls = 300 calls/day ✅ GOOD
25 users × 30 calls = 750 calls/day ✅ GOOD
50 users × 30 calls = 1,500 calls/day ✅ AT LIMIT
75 users × 30 calls = 2,250 calls/day ❌ EXCEEDED
```

#### Scenario 3: Power User
```
- Uses chatbot heavily throughout day
- Logs symptoms frequently
- Gets proactive tips
- Total: ~50 API calls/day

10 users × 50 calls = 500 calls/day ✅ GOOD
20 users × 50 calls = 1,000 calls/day ✅ GOOD
30 users × 50 calls = 1,500 calls/day ✅ AT LIMIT
40 users × 50 calls = 2,000 calls/day ❌ EXCEEDED
```

### **CONCLUSION:**
✅ **Free tier works for:** 0-100 light users, 0-50 active users, 0-30 power users
❌ **Free tier NOT enough for:** 500+ users, any viral growth

---

## 💰 GEMINI PAID TIER COSTS (When You Exceed Free)

### Gemini 1.5 Flash (Paid):
```
Pricing:
- Input: $0.075 per 1 million tokens
- Output: $0.30 per 1 million tokens

Typical message with context:
- Input: ~1,000 tokens (medication context + user question)
- Output: ~200 tokens (AI response)

Cost per message:
- Input cost: (1,000 / 1,000,000) × $0.075 = $0.000075
- Output cost: (200 / 1,000,000) × $0.30 = $0.00006
- Total: ~$0.000135 per message
```

### Monthly Cost Projections:

#### 1,000 Users (Active):
```
1,000 users × 30 messages/day × 30 days = 900,000 messages/month
900,000 × $0.000135 = $121.50/month
```

#### 10,000 Users (Active):
```
10,000 users × 30 messages/day × 30 days = 9,000,000 messages/month
9,000,000 × $0.000135 = $1,215/month
```

#### 100,000 Users (Active):
```
100,000 users × 30 messages/day × 30 days = 90,000,000 messages/month
90,000,000 × $0.000135 = $12,150/month ($145,800/year)
```

### **CONCLUSION:**
- Small scale (0-100 users): **FREE** ✅
- Medium scale (100-1000 users): **$50-150/month** ✅ Affordable
- Large scale (10,000+ users): **$1,000+/month** ⚠️ Expensive
- Viral scale (100,000+ users): **$10,000+/month** 🚨 Unsustainable

---

## 🆓 FREE ALTERNATIVES TO GEMINI

### **OPTION 1: Hugging Face Inference API** ⭐ RECOMMENDED

#### Model: Mistral-7B-Instruct
```yaml
dependencies:
  dio: ^5.4.0  # Already have it
```

**API Endpoint:**
```dart
final response = await dio.post(
  'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.2',
  headers: {
    'Authorization': 'Bearer YOUR_HF_TOKEN',
  },
  data: {
    'inputs': promptWithContext,
  },
);
```

**Free Tier:**
- Unlimited requests (rate limited)
- ~30,000 tokens/day
- No credit card required

**Pros:**
✅ Truly unlimited (just rate limits)
✅ Good quality responses
✅ Free forever
✅ Multiple model options
✅ Easy to switch models

**Cons:**
❌ Slower than Gemini (5-10 seconds)
❌ May have queues during peak times
❌ Rate limiting (need to handle retries)
❌ Not as smart as Gemini for complex queries

**Best for:** Backup when Gemini limits exceeded

---

### **OPTION 2: Groq API** ⚡ FASTEST

#### Model: Llama 3 8B
```dart
final response = await dio.post(
  'https://api.groq.com/openai/v1/chat/completions',
  headers: {
    'Authorization': 'Bearer YOUR_GROQ_KEY',
    'Content-Type': 'application/json',
  },
  data: {
    'model': 'llama3-8b-8192',
    'messages': [
      {'role': 'user', 'content': userMessage}
    ],
  },
);
```

**Free Tier:**
- 14,400 requests/day
- 7,000 requests/minute
- FREE (no credit card)

**Pros:**
✅ VERY fast (under 1 second!)
✅ Higher free limits than Gemini
✅ Good quality (Llama 3 is excellent)
✅ No credit card required

**Cons:**
❌ New service (may change limits)
❌ Startup (could shut down)

**Best for:** Primary API if you want speed + free tier

---

### **OPTION 3: Together.ai** 🌟 BEST FREE TIER

#### Multiple Models Available
```dart
final response = await dio.post(
  'https://api.together.xyz/v1/chat/completions',
  headers: {
    'Authorization': 'Bearer YOUR_TOGETHER_KEY',
  },
  data: {
    'model': 'mistralai/Mistral-7B-Instruct-v0.1',
    'messages': messages,
  },
);
```

**Free Tier:**
- $25 free credits on signup
- ~250,000 tokens per $1
- Credits last forever (no expiry)

**Pros:**
✅ Very generous free credits
✅ Multiple model options
✅ Fast inference
✅ Good documentation

**Cons:**
❌ Eventually runs out (not truly unlimited)
❌ Requires credit card after free tier

**Best for:** Development and testing

---

### **OPTION 4: Perplexity API** 🔍 SEARCH-FOCUSED

```dart
final response = await dio.post(
  'https://api.perplexity.ai/chat/completions',
  headers: {
    'Authorization': 'Bearer YOUR_PPLX_KEY',
  },
  data: {
    'model': 'llama-3-sonar-small-32k-online',
    'messages': messages,
  },
);
```

**Free Tier:**
- $5 free credits on signup
- Good for drug information queries

**Pros:**
✅ Can search web in real-time
✅ Up-to-date medical information
✅ Good for fact-checking

**Cons:**
❌ Limited free credits
❌ Slower responses

**Best for:** Drug information lookups

---

### **OPTION 5: Anthropic Claude (Haiku)** 🎭

```dart
// Claude 3 Haiku - Fastest Claude model
final response = await dio.post(
  'https://api.anthropic.com/v1/messages',
  headers: {
    'x-api-key': 'YOUR_CLAUDE_KEY',
    'anthropic-version': '2023-06-01',
  },
  data: {
    'model': 'claude-3-haiku-20240307',
    'messages': messages,
  },
);
```

**Free Tier:**
- $5 free credits on signup
- Haiku is cheapest Claude model

**Pros:**
✅ Very high quality
✅ Excellent for medical queries
✅ Safety-focused

**Cons:**
❌ Limited free credits
❌ More expensive after free tier

**Best for:** High-quality responses when needed

---

## 🤖 CUSTOM AI MODEL: CAN WE BUILD ONE?

### **SHORT ANSWER: YES! And it might be better.**

Here's how to build a **custom medical AI model** specifically for MedAssist:

---

## 🏗️ CUSTOM MODEL APPROACH 1: FINE-TUNED LLM

### Step 1: Choose Base Model
**Best Options:**
1. **Llama 3 8B** - Best quality/size ratio
2. **Mistral 7B** - Fast and efficient
3. **Phi-3 Mini (3.8B)** - Smallest, runs on mobile

### Step 2: Collect Training Data
**What you need:**
```
Medical Q&A Dataset:
- 1,000+ medication-related Q&As
- 500+ drug interaction examples
- 500+ adherence tips
- 300+ symptom correlations

Sources:
- FDA drug labels
- Medical textbooks (open access)
- Reddit r/AskDocs (filtered)
- MedlinePlus articles
- Your own curated data
```

### Step 3: Fine-tune Model
**Tools:**
```python
# Using Hugging Face Transformers
from transformers import AutoModelForCausalLM, AutoTokenizer, Trainer

# Load base model
model = AutoModelForCausalLM.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")

# Fine-tune on your medical dataset
trainer = Trainer(
    model=model,
    train_dataset=medical_qa_dataset,
    # ... training config
)

trainer.train()
trainer.save_model("medassist-llama3-8b")
```

**Requirements:**
- GPU with 24GB VRAM (rent on RunPod/Vast.ai for $0.50/hour)
- 5-10 hours training time
- Cost: ~$5-10 total

### Step 4: Deploy Model

#### Option A: Self-Hosted (Backend)
```yaml
# Host on your own server
# Cost: $50-100/month for decent GPU server

Tools:
- vLLM (fastest inference)
- Text Generation Inference (HuggingFace)
- llama.cpp (CPU inference)
```

#### Option B: Serverless (Pay-per-use)
```yaml
# Deploy to serverless GPU

Options:
- Modal.com - $0.0001/second GPU time
- Replicate.com - $0.001/second GPU time
- RunPod Serverless - $0.0004/second GPU time
```

**Cost Comparison:**
```
1000 users, 30 messages/day, 2s inference:
Modal: 1000 × 30 × 30 × 2 × $0.0001 = $180/month
Self-hosted: $80/month fixed

Break-even: ~500 active users
```

#### Option C: On-Device (Mobile)
```yaml
dependencies:
  flutter_llama: ^0.1.0  # Llama.cpp bindings
  # or
  mediapipe_genai: ^0.1.0  # Google's on-device AI
```

**Pros:**
✅ Zero API costs
✅ Works offline
✅ Privacy-first
✅ Instant responses

**Cons:**
❌ Large app size (+500MB - 2GB)
❌ Requires powerful device
❌ Battery drain
❌ Quality trade-off (smaller models)

**Best for:** Offline mode, privacy-conscious users

---

## 🏗️ CUSTOM MODEL APPROACH 2: SPECIALIZED MODELS

Instead of one big model, use specialized smaller models:

### Model 1: Drug Interaction Classifier
**Model:** DistilBERT (66MB)
**Task:** Binary classification (safe/unsafe)
**Training data:** 10,000 drug pairs with labels

```dart
// On-device inference with TFLite
final result = await _interpreter.run(drugPairEmbedding);
if (result[0] > 0.7) {
  return 'Severe interaction detected';
}
```

**Cost:** FREE (on-device)
**Accuracy:** 95%+

---

### Model 2: Symptom Classifier
**Model:** MobileBERT (25MB)
**Task:** Multi-class classification (symptom types)
**Training data:** 5,000 symptom descriptions

**Cost:** FREE (on-device)

---

### Model 3: Intent Classifier
**Model:** DistilRoBERTa (82MB)
**Task:** Classify user intent (medication_info, side_effects, etc.)
**Training data:** 3,000 labeled questions

**Cost:** FREE (on-device)

---

### Architecture: Hybrid System
```
User Message
     ↓
[Intent Classifier] ← On-device (instant)
     ↓
If "drug_interaction":
  → [Drug Interaction Model] ← On-device (instant)
If "symptom_report":
  → [Symptom Classifier] ← On-device (instant)
If "general_question":
  → [Cloud LLM] ← Gemini/Groq (2-3s, costs money)
```

**Result:**
- 60-70% of queries handled on-device (FREE)
- 30-40% go to cloud (only when needed)
- **Cost reduction: 60-70%!**

---

## 🎯 RECOMMENDED HYBRID ARCHITECTURE

### **Best Solution: Multi-Tier Approach**

```
┌─────────────────────────────────────────────┐
│         User Query                          │
└────────────────┬────────────────────────────┘
                 ↓
┌────────────────────────────────────────────┐
│  TIER 1: Local Rules (On-Device)          │
│  - Drug interaction database               │
│  - Simple FAQs                             │
│  - Medication reminders                    │
│  Response time: <50ms                      │
│  Cost: FREE                                │
│  Coverage: ~30% of queries                 │
└────────────────┬───────────────────────────┘
                 ↓ Not found
┌────────────────────────────────────────────┐
│  TIER 2: Small ML Models (On-Device)      │
│  - Intent classifier (82MB)                │
│  - Symptom classifier (25MB)               │
│  - Sentiment analysis (20MB)               │
│  Response time: ~100ms                     │
│  Cost: FREE                                │
│  Coverage: ~30% of queries                 │
└────────────────┬───────────────────────────┘
                 ↓ Complex query
┌────────────────────────────────────────────┐
│  TIER 3: Cloud AI (Fallback)              │
│  - Primary: Groq API (free, fast)         │
│  - Fallback 1: Gemini (free tier)         │
│  - Fallback 2: HuggingFace (free)         │
│  - Last resort: Custom hosted model       │
│  Response time: 1-3s                       │
│  Cost: FREE (within limits)                │
│  Coverage: ~40% of queries                 │
└────────────────────────────────────────────┘
```

### Implementation:
```dart
class HybridAIService {
  Future<String> processQuery(String query) async {
    // TIER 1: Check local database
    final localAnswer = await _checkLocalDatabase(query);
    if (localAnswer != null) {
      return localAnswer; // Instant, free
    }

    // TIER 2: Check with on-device models
    final intent = await _classifyIntent(query);
    if (intent == 'drug_interaction') {
      return await _checkDrugInteractions(); // On-device
    }
    if (intent == 'simple_faq') {
      return await _getFAQAnswer(query); // Pre-generated
    }

    // TIER 3: Cloud AI (only for complex queries)
    try {
      return await _groqService.sendMessage(query); // Fast, free
    } catch (e) {
      try {
        return await _geminiService.sendMessage(query); // Fallback
      } catch (e) {
        try {
          return await _huggingFaceService.sendMessage(query); // Second fallback
        } catch (e) {
          return _getOfflineResponse(); // Graceful degradation
        }
      }
    }
  }
}
```

**Result:**
- 60% queries answered instantly (on-device)
- 40% go to cloud (free tier APIs)
- **Total cost: $0 for most users!**

---

## 📦 IMPLEMENTING ON-DEVICE MODELS

### Option 1: TensorFlow Lite (Recommended)
```yaml
dependencies:
  tflite_flutter: ^0.10.4
```

**Steps:**
1. Train models in Python (TensorFlow/PyTorch)
2. Convert to TFLite format (`.tflite`)
3. Bundle with app (in `assets/models/`)
4. Load and run inference in Flutter

**Example:**
```dart
import 'package:tflite_flutter/tflite_flutter.dart';

class IntentClassifier {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/models/intent_classifier.tflite');
  }

  Future<String> classify(String query) async {
    // Tokenize query
    final input = tokenize(query); // [1, 128] shape

    // Run inference
    final output = List.filled(10, 0.0).reshape([1, 10]); // 10 intent classes
    _interpreter.run(input, output);

    // Get highest probability intent
    final intents = ['medication_info', 'side_effects', 'drug_interaction', ...];
    final maxIndex = output[0].indexOf(output[0].reduce(max));
    return intents[maxIndex];
  }
}
```

**Model sizes:**
- Intent classifier: ~80MB
- Symptom classifier: ~25MB
- Drug interaction classifier: ~50MB
- **Total: ~155MB added to app**

---

### Option 2: ONNX Runtime (Alternative)
```yaml
dependencies:
  onnxruntime: ^1.15.0
```

**Pros:**
- More model compatibility
- Often faster than TFLite
- Better support for latest models

**Cons:**
- Larger runtime size
- More complex setup

---

### Option 3: MediaPipe (Google)
```yaml
dependencies:
  mediapipe_genai: ^0.1.0
```

**Use case:** On-device text generation

**Pros:**
- Official Google support
- Optimized for mobile
- Good documentation

**Cons:**
- Still experimental
- Limited model options

---

## 💡 PRACTICAL RECOMMENDATION FOR MEDASSIST

### **Phase 1: MVP (Current - 100 users)**
```
Strategy: Use only Gemini Free Tier
Cost: $0/month
Why: Simplest, fastest to implement
```

### **Phase 2: Growth (100-1000 users)**
```
Strategy: Add Groq as primary, Gemini as fallback
Cost: $0-50/month
Why: Higher free limits, faster responses
```

### **Phase 3: Scale (1000-10000 users)**
```
Strategy: Hybrid (Local + Groq + Gemini)
- Add on-device intent classifier
- Add local drug interaction database
- Use cloud AI for complex queries only

Cost: $0-200/month
Why: 60% cost reduction, works offline
```

### **Phase 4: Production (10000+ users)**
```
Strategy: Custom fine-tuned model
- Fine-tune Llama 3 8B on medical data
- Host on serverless GPU (Modal/RunPod)
- Use on-device models for common queries
- Keep cloud AI as fallback

Cost: $200-500/month (fixed)
Why: Full control, better quality, predictable costs
```

---

## 🎓 HOW TO BUILD CUSTOM MODEL (STEP-BY-STEP)

### **COMPLETE GUIDE: Fine-tune Llama 3 for MedAssist**

#### Step 1: Prepare Training Data (1 day)
```python
# Format: JSON with medical Q&A
training_data = [
    {
        "instruction": "What are the side effects of metformin?",
        "input": "User is taking metformin 500mg twice daily for Type 2 diabetes",
        "output": "Common side effects of metformin include nausea, diarrhea, and stomach upset. These usually improve after a few weeks. Take with food to reduce side effects. Contact your doctor if symptoms persist."
    },
    # ... 1000+ examples
]
```

**Data Sources:**
- FDA drug labels (public domain)
- MedlinePlus articles (public domain)
- NIH PubMed abstracts (public domain)
- Your own curated Q&As

---

#### Step 2: Set Up Training Environment (1 hour)
```bash
# Rent GPU on RunPod/Vast.ai ($0.50/hour)
# Or use Google Colab Pro ($10/month)

# Install dependencies
pip install transformers peft datasets accelerate bitsandbytes

# Login to Hugging Face
huggingface-cli login
```

---

#### Step 3: Fine-tune with LoRA (8-12 hours)
```python
from transformers import AutoModelForCausalLM, AutoTokenizer, TrainingArguments
from peft import LoraConfig, get_peft_model
from trl import SFTTrainer

# Load base model (Llama 3 8B)
model = AutoModelForCausalLM.from_pretrained(
    "meta-llama/Meta-Llama-3-8B-Instruct",
    load_in_4bit=True,  # Quantized for efficiency
)

tokenizer = AutoTokenizer.from_pretrained("meta-llama/Meta-Llama-3-8B-Instruct")

# Configure LoRA (efficient fine-tuning)
lora_config = LoraConfig(
    r=16,
    lora_alpha=32,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

model = get_peft_model(model, lora_config)

# Training arguments
training_args = TrainingArguments(
    output_dir="./medassist-llama3-lora",
    num_train_epochs=3,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-4,
    save_steps=100,
    logging_steps=10,
)

# Train
trainer = SFTTrainer(
    model=model,
    args=training_args,
    train_dataset=dataset,
    tokenizer=tokenizer,
)

trainer.train()

# Save model
model.save_pretrained("./medassist-llama3-final")
```

**Cost:** ~$5-10 for 10 hours of GPU time

---

#### Step 4: Deploy Model

##### Option A: Modal.com (Serverless)
```python
# modal_deploy.py
import modal

stub = modal.Stub("medassist-ai")

@stub.function(
    image=modal.Image.debian_slim().pip_install("transformers", "torch"),
    gpu="A10G",
    timeout=300,
)
def generate(prompt: str) -> str:
    from transformers import AutoModelForCausalLM, AutoTokenizer

    model = AutoModelForCausalLM.from_pretrained("./medassist-llama3-final")
    tokenizer = AutoTokenizer.from_pretrained("./medassist-llama3-final")

    inputs = tokenizer(prompt, return_tensors="pt")
    outputs = model.generate(**inputs, max_length=200)
    return tokenizer.decode(outputs[0])

@stub.webhook(method="POST")
def api(request: dict):
    return generate(request["prompt"])
```

Deploy:
```bash
modal deploy modal_deploy.py
# Returns: https://your-app.modal.run/api
```

---

##### Option B: Flutter Integration
```dart
// Call your custom model API
class CustomModelService {
  final Dio _dio = Dio();

  Future<String> sendMessage(String message) async {
    final response = await _dio.post(
      'https://your-app.modal.run/api',
      data: {'prompt': message},
    );

    return response.data;
  }
}
```

---

## 📊 COST COMPARISON SUMMARY

| Solution | Setup Cost | Monthly Cost (1K users) | Monthly Cost (10K users) | Quality | Speed |
|----------|-----------|-------------------------|--------------------------|---------|-------|
| **Gemini Free** | $0 | $0 | $121 | ⭐⭐⭐⭐⭐ | Fast |
| **Groq Free** | $0 | $0 | $0 (within limits) | ⭐⭐⭐⭐ | Very Fast |
| **HuggingFace Free** | $0 | $0 | $0 (rate limited) | ⭐⭐⭐ | Slow |
| **Hybrid (Local + Cloud)** | $0 | $0 | $20-50 | ⭐⭐⭐⭐ | Fast |
| **Custom Hosted** | $10 | $80 (fixed) | $80 (fixed) | ⭐⭐⭐⭐⭐ | Fast |
| **Custom Serverless** | $10 | $50 | $200 | ⭐⭐⭐⭐⭐ | Fast |
| **On-Device Only** | $100 | $0 | $0 | ⭐⭐⭐ | Very Fast |

---

## ✅ FINAL RECOMMENDATION

### **Best Strategy for MedAssist:**

#### NOW (0-100 users):
```
✅ Use Gemini Free Tier
- Simplest to implement
- Good quality
- Zero cost
```

#### SOON (100-1000 users):
```
✅ Add Multi-API Fallback:
1. Primary: Groq (fast, free)
2. Fallback: Gemini (reliable)
3. Last resort: HuggingFace (always works)

Cost: $0-50/month
```

#### LATER (1000+ users):
```
✅ Implement Hybrid System:
- Local drug interaction database
- On-device intent classifier (TFLite)
- Cloud AI for complex queries only

Cost: $50-200/month
```

#### SCALE (10000+ users):
```
✅ Custom Fine-tuned Model:
- Train Llama 3 8B on medical data
- Deploy to Modal/RunPod serverless
- Use local models for 70% of queries

Cost: $200-500/month (predictable)
```

---

## 🎯 ACTION PLAN

### Week 1: Implement MVP
```dart
// Just use Gemini
final response = await _geminiService.sendMessage(query);
```

### Week 2: Add Fallback
```dart
// Multi-API fallback
try {
  return await _groqService.sendMessage(query);
} catch (e) {
  return await _geminiService.sendMessage(query);
}
```

### Month 2: Add Local Intelligence
```dart
// Hybrid approach
if (_isSimpleQuery(query)) {
  return _localDatabase.getAnswer(query);
} else {
  return await _cloudAI.sendMessage(query);
}
```

### Month 6: Custom Model
```python
# Fine-tune Llama 3
# Deploy to serverless
# Integrate with app
```

---

## 📝 CONCLUSION

**Gemini free tier is:**
- ✅ Perfect for development and MVP
- ✅ Great for 0-100 users
- ⚠️ Limited for 100-1000 users (but workable with fallbacks)
- ❌ Not enough for 1000+ users at scale

**Best approach:**
1. Start with Gemini (free, easy)
2. Add Groq as primary when you grow (free, fast)
3. Implement local intelligence (60% cost reduction)
4. Build custom model when you hit 10K users (full control)

**Custom model is totally doable and might be better!**
- Training cost: $5-10
- Monthly cost: $50-500 (predictable)
- Quality: As good or better
- Privacy: Full control
- Speed: Fast

**You have options! 🚀**

