<div align="center">

# 📚 GraamaShaale
### ಗ್ರಾಮಶಾಲೆ — Bringing Quality Education to Rural Karnataka

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=for-the-badge&logo=firebase)](https://firebase.google.com)
[![Groq AI](https://img.shields.io/badge/Groq-AI%20Powered-F55036?style=for-the-badge)](https://console.groq.com)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Release](https://img.shields.io/badge/Release-v1.0.0-blue?style=for-the-badge)](https://github.com/Eshwarmp/Graamashaale/releases/tag/v1.0.0)

[![Download APK](https://img.shields.io/badge/⬇️%20Download%20APK-v1.0.0%20•%2026MB-brightgreen?style=for-the-badge)](https://github.com/Eshwarmp/Graamashaale/releases/download/v1.0.0/app-arm64-v8a-release.apk)

</div>

---

## 🎯 Problem Statement

Rural students in Karnataka lack access to quality educational resources, qualified teachers, and consistent internet connectivity. GraamaShaale bridges this gap with an **offline-first** mobile learning platform built for Class 8–10 students following the KSEEB syllabus.

---

## ✨ Features

| Feature | Description |
|---|---|
| 📖 **Offline Textbooks** | KSEEB PDF books for Class 8, 9, 10 — Math, Science, Social, Kannada, Hindi, English |
| 🤖 **AI Quizzes** | Auto-generated MCQs using Groq AI (LLaMA 3.3) per lesson, fresh every session |
| 👩‍🏫 **Teacher Dashboard** | Subject-wise student progress, quiz results, doubt management |
| 📊 **Question Breakdown** | See exactly which questions each student got right/wrong with correct answers shown |
| 🌐 **Bilingual UI** | Full English + ಕನ್ನಡ interface throughout the app |
| 🔔 **Announcements** | Teachers post announcements via Firebase, students see them in real time |
| 👥 **Multi-Student** | Multiple students can use the same device with completely separate progress tracking |
| 🌙 **Dark Mode** | Full dark/light theme support |
| 📶 **Offline First** | Works without internet after first load — perfect for rural areas |

---

## 📸 Screenshots

### Student Side
| Login | Student Setup | Home |
|---|---|---|
| ![Login](screenshots/01_login.png) | ![Student Setup](screenshots/02_student_setup.png) | ![Home](screenshots/03_home.png) |

| PDF Download | AI Quiz Generation | Quiz Result |
|---|---|---|
| ![PDF Download](screenshots/04_pdf_download.png) | ![AI Generating](screenshots/05_ai_generating.png) | ![Quiz Result](screenshots/06_quiz_result.png) |

| Doubt Corner | Profile | Progress |
|---|---|---|
| ![Doubt Corner](screenshots/07_doubt_corner.png) | ![Profile](screenshots/08_profile.png) | ![Progress](screenshots/09_progress.png) |

| Settings | Announcements |
|---|---|
| ![Settings](screenshots/10_settings.png) | ![Announcements](screenshots/11_announcements.png) |

### Teacher Side
| Dashboard | Subject Detail | Question Breakdown |
|---|---|---|
| ![Teacher Dashboard](screenshots/12_teacher_dashboard.png) | ![Subject Detail](screenshots/16_subject_detail.png) | ![Question Breakdown](screenshots/17_question_breakdown.png) |

| Students List | Pending Doubts | Answered Doubts |
|---|---|---|
| ![Students](screenshots/15_teacher_students.png) | ![Pending Doubts](screenshots/13_teacher_doubts_pending.png) | ![Answered Doubts](screenshots/14_teacher_doubts_answered.png) |

| New Announcement | Teacher Profile |
|---|---|
| ![Announcement](screenshots/18_teacher_announcement.png) | ![Teacher Profile](screenshots/19_teacher_profile.png) |

---

## 📱 Download & Install

> Works on all modern Android phones (Android 6.0+)

[![Download APK](https://img.shields.io/badge/⬇️%20Download%20APK-26MB-brightgreen?style=for-the-badge)](https://github.com/Eshwarmp/Graamashaale/releases/download/v1.0.0/app-arm64-v8a-release.apk)

1. Click the button above to download the APK
2. On your Android phone → Settings → Allow installation from unknown sources
3. Open the downloaded APK and install
4. Launch GraamaShaale 🎉

---

## 🛠 Tech Stack

| Technology | Usage |
|---|---|
| **Flutter (Dart)** | Cross-platform mobile framework |
| **Firebase Firestore** | Cloud sync for students, announcements |
| **SQLite (sqflite)** | Local database for lessons, progress, doubts, quiz answers |
| **Hive** | Lightweight key-value storage for settings & student history |
| **Groq AI API** | LLaMA 3.3-based quiz question generation |
| **Riverpod** | State management for dark/light theme |
| **flutter_pdfview** | In-app PDF textbook viewer |
| **dio** | PDF download manager with progress tracking |

---

## 🏗 Project Structure

```
lib/
├── app/
│   ├── app.dart                    # App entry with theme provider
│   └── main_screen.dart            # Bottom navigation wrapper
├── core/
│   ├── database/
│   │   ├── database_helper.dart    # SQLite setup & all tables
│   │   ├── database_repository.dart# All DB operations
│   │   ├── lesson_model.dart
│   │   ├── question_model.dart
│   │   ├── progress_model.dart
│   │   └── doubt_model.dart
│   ├── sync/
│   │   ├── ai_service.dart         # Groq AI integration
│   │   ├── sync_service.dart       # Firebase sync & connectivity
│   │   └── secrets.example.dart   # API key template
│   └── theme/
│       └── app_theme.dart
└── features/
    ├── lessons/screens/
    │   ├── splash_screen.dart
    │   ├── onboarding_screen.dart
    │   ├── login_screen.dart       # Role selection + student setup
    │   ├── home_screen.dart
    │   ├── lessons_screen.dart
    │   ├── pdf_viewer_screen.dart
    │   ├── announcements_screen.dart
    │   ├── teacher_home_screen.dart
    │   ├── teacher_register_screen.dart
    │   └── teacher_profile_screen.dart
    ├── practice/screens/
    │   ├── quiz_screen.dart        # AI quiz with per-question tracking
    │   └── score_screen.dart
    ├── progress/screens/
    │   ├── progress_screen.dart
    │   ├── profile_screen.dart
    │   └── settings_screen.dart
    └── doubt/screens/
        └── doubt_screen.dart
```

---

## 🚀 Getting Started (For Developers)

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Firebase account
- Groq API key (free at [console.groq.com](https://console.groq.com))

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/Eshwarmp/Graamashaale.git
cd Graamashaale

# 2. Install dependencies
flutter pub get

# 3. Set up Groq API key
cp lib/core/sync/secrets.example.dart lib/core/sync/secrets.dart
# Open secrets.dart and add your Groq API key

# 4. Add Firebase config
# Download google-services.json from Firebase Console
# Place it at android/app/google-services.json

# 5. Run the app
flutter run
```

### Build Release APK
```bash
flutter build apk --release --split-per-abi
# Your APK: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## 🔑 API Keys Setup

**Groq AI (for quiz generation):**
1. Get a free key at [console.groq.com](https://console.groq.com)
2. Copy the example file:
   ```bash
   cp lib/core/sync/secrets.example.dart lib/core/sync/secrets.dart
   ```
3. Paste your key inside `secrets.dart`

**Firebase (for cloud sync):**
1. Create a project at [Firebase Console](https://console.firebase.google.com)
2. Add Android app with package `com.example.graamashaale`
3. Download `google-services.json` → place in `android/app/`
4. Enable Firestore Database in Firebase console

---

## 🗄 Database Schema

The app uses SQLite with these tables:

| Table | Purpose |
|---|---|
| `lessons` | All KSEEB textbooks metadata and PDF URLs |
| `questions` | AI-generated MCQs per lesson |
| `progress` | Per-student quiz attempt scores |
| `progress_answers` | Per-question answers for detailed breakdown |
| `completions` | Per-student textbook completion tracking |
| `doubts` | Student doubts with teacher replies |

---

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs via [Issues](https://github.com/Eshwarmp/Graamashaale/issues)
- Submit pull requests
- Suggest new features for rural education

---

## 👨‍💻 Developer

**Eshwar MP**
- 🎓 Student at NMIT, Bangalore
- 💡 Built as a social-impact project for rural education in Karnataka

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=flat&logo=linkedin)](https://www.linkedin.com/in/eshwar-m-p-2487102a5/)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?style=flat&logo=github)](https://github.com/Eshwarmp)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>Made with ❤️ for rural Karnataka students</p>
  <p>⭐ Star this repo if you found it helpful!</p>
</div>