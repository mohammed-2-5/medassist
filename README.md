<div align="center">

# 💊 Med Assist

### Your Personal Medication Management Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

**Never miss a dose again!** Med Assist helps you manage your medications with smart reminders, AI-powered insights, and comprehensive tracking.

[Features](#-features) • [Screenshots](#-screenshots) • [Installation](#-installation) • [Usage](#-usage) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 🎯 Core Features
- **📅 Smart Medication Reminders** - Never miss a dose with intelligent notifications
- **🤖 AI Health Assistant** - Get medication insights powered by Gemini, Groq, and HuggingFace AI
- **⚠️ Drug Interaction Warnings** - Real-time safety checks for dangerous medication combinations
- **📊 Adherence Tracking** - Monitor your medication compliance with detailed analytics
- **🏥 Expiration Alerts** - Get notified before your medications expire
- **📦 Inventory Management** - Track your medication stock levels
- **🌍 Multi-language Support** - Available in English and Arabic

### 🚀 Advanced Features
- **💬 Context-Aware Chatbot** - Ask questions about your medications
- **📈 Analytics Dashboard** - Visualize your medication adherence patterns
- **🌓 Dark/Light Mode** - Beautiful Material Design 3 UI
- **🔔 Background Notifications** - Reliable reminders even when the app is closed
- **📱 Offline First** - All data stored locally with SQLite
- **🔒 Privacy Focused** - Your health data never leaves your device

### 🎨 UI/UX Highlights
- Quick action cards for common tasks
- Timeline view for daily medication schedule
- Notification badges for alerts
- Smooth animations and transitions
- Empty states with helpful guidance
- Professional gradient designs

---

## 📸 Screenshots

<div align="center">

| Home Screen | Medications List | AI Chatbot |
|:-----------:|:----------------:|:----------:|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

| Analytics | Add Medication | Drug Interactions |
|:---------:|:--------------:|:-----------------:|
| *Coming Soon* | *Coming Soon* | *Coming Soon* |

</div>

---

## 🏗️ Architecture

Med Assist follows Clean Architecture principles with a feature-first folder structure:

```
lib/
├── core/                 # Core functionality
│   ├── constants/       # App constants
│   ├── database/        # Drift database
│   ├── navigation/      # GoRouter navigation
│   └── widgets/         # Reusable widgets
├── features/            # Feature modules
│   ├── home/           # Home dashboard
│   ├── medications/    # Medication CRUD
│   ├── reminders/      # Reminder system
│   ├── analytics/      # Stats & reports
│   └── chatbot/        # AI assistant
└── services/           # Business logic
    ├── ai/            # AI integrations
    ├── health/        # Drug interactions
    └── notification/  # Local notifications
```

---

## 🛠️ Tech Stack

| Category | Technologies |
|----------|-------------|
| **Framework** | Flutter 3.24.3, Dart 3.9.2 |
| **State Management** | Riverpod 3.0 |
| **Database** | Drift (SQLite) |
| **Navigation** | GoRouter |
| **AI Services** | Google Gemini, Groq, HuggingFace |
| **Notifications** | Flutter Local Notifications |
| **Background Tasks** | WorkManager |
| **UI Components** | Material Design 3, FL Chart, Lottie |
| **Testing** | 267 tests (unit, widget, integration, E2E) |

---

## 📋 Requirements

- **Flutter SDK**: 3.24.3 or higher
- **Dart SDK**: 3.9.2 or higher
- **Minimum Android SDK**: 21 (Android 5.0)
- **Minimum iOS Version**: 12.0

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/mohammed-2-5/medassist.git
cd medassist
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API Keys

Med Assist uses AI services for the chatbot feature. You'll need to get free API keys:

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Get your API keys:**
   - **Gemini AI**: [Get key](https://makersuite.google.com/app/apikey) (Google)
   - **Groq**: [Get key](https://console.groq.com/keys) (14,400 requests/day free)
   - **HuggingFace**: [Get token](https://huggingface.co/settings/tokens) (Unlimited, rate-limited)

3. **Add keys to `.env` file:**
   ```env
   GEMINI_API_KEY=your_gemini_api_key_here
   GROQ_API_KEY=your_groq_api_key_here
   HUGGINGFACE_API_KEY=your_huggingface_api_key_here
   ```

### 4. Run the App

```bash
# Development mode
flutter run

# Release mode (Android)
flutter build apk --release

# Release mode (iOS)
flutter build ios --release
```

---

## 🧪 Testing

Med Assist has comprehensive test coverage:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test suites
flutter test test/unit
flutter test test/widget
flutter test test/integration
flutter test test/e2e
```

**Test Statistics:**
- ✅ 267 passing tests
- 🎯 100% pass rate
- 📊 High code coverage

---

## 📱 Usage

### Adding a Medication

1. Tap the **"Add Medicine"** button on the home screen
2. Fill in medication details (name, dosage, frequency)
3. Set reminder times
4. Add optional notes and expiration date
5. Tap **"Save"**

### Taking a Dose

1. When a reminder arrives, tap the notification
2. Mark as **"Taken"**, **"Skipped"**, or **"Snooze"**
3. View your adherence streak on the home screen

### Using the AI Chatbot

1. Tap the **"Ask AI"** quick action
2. Ask questions about your medications
3. Get instant, context-aware responses
4. Use quick suggestions for common queries

### Checking Drug Interactions

1. Navigate to the **Medications** tab
2. View warnings if dangerous combinations are detected
3. Tap on warnings for detailed information
4. Follow clinical recommendations

---

## 🎨 Customization

### Changing Theme

The app automatically follows your system theme preference (dark/light mode).

### Language Settings

1. Go to **Settings**
2. Select **Language**
3. Choose between English and Arabic

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Run tests: `flutter test`
5. Commit with conventional commits: `git commit -m "feat: add amazing feature"`
6. Push to your fork: `git push origin feature/amazing-feature`
7. Open a Pull Request

### Code Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Run `flutter analyze` before committing
- Format code with `dart format .`
- Write tests for new features

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👨‍💻 Author

**Eng. Mohammed Yasser**

- GitHub: [@mohammed-2-5](https://github.com/mohammed-2-5)
- Project Link: [https://github.com/mohammed-2-5/medassist](https://github.com/mohammed-2-5/medassist)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google for Gemini AI
- Groq for blazing-fast AI inference
- HuggingFace for open-source AI models
- All contributors who help improve Med Assist

---

## 📞 Support

If you encounter any issues or have questions:

- 🐛 [Open an issue](https://github.com/mohammed-2-5/medassist/issues)
- 💬 [Start a discussion](https://github.com/mohammed-2-5/medassist/discussions)
- 📧 Contact the maintainers

---

## 🗺️ Roadmap

### ✅ Phase 1: Foundation (Completed)
- [x] Core medication CRUD
- [x] Reminder system
- [x] Local database
- [x] 267 tests

### ✅ Phase 2: Enhancements (Completed)
- [x] Expiry date tracking
- [x] Medication context service
- [x] Code quality improvements

### ✅ Phase 3A: Quick Wins (Completed)
- [x] Enhanced AI chatbot
- [x] Drug interaction warnings
- [x] Quick action cards
- [x] Notification badges

### 🚧 Phase 3B: UI Polish (In Progress)
- [ ] Enhanced animations
- [ ] Step progress indicators
- [ ] Haptic feedback
- [ ] Enhanced empty states

### 📅 Future Features
- [ ] Advanced analytics with charts
- [ ] OCR prescription scanning
- [ ] Export reports (PDF/CSV)
- [ ] Cloud sync (optional)
- [ ] Medication price tracking
- [ ] Pharmacy locator

---

## ⚠️ Disclaimer

**Med Assist is a medication tracking tool and does not provide medical advice.**

- Always consult with healthcare professionals about your medications
- Drug interaction warnings are informational - not a substitute for professional medical advice
- Verify all medication information with your doctor or pharmacist
- In case of medical emergencies, contact emergency services immediately

---

<div align="center">

**Made with ❤️ and Flutter**

⭐ Star this repo if you find it helpful!

</div>
