# 🩺 MediLens — Your Health Data, Decoded

> **Information, not Diagnosis. Clarity, not Confusion.**

### 🏆 Hackathon Pitch (30-Second Read)
Medical lab reports are written for doctors — not patients.  
**MediLens** is a **privacy-first** application that instantly translates complex medical reports into **clear, human-readable health insights**, helping users understand *what’s normal, what’s not, and what needs attention* — without storing or leaking sensitive medical data.

---

## ❓ The Problem
- Lab reports are **dense, jargon-heavy, and anxiety-inducing**
- Patients struggle to interpret values like *LDL, HbA1c, SGPT*
- Existing solutions:
  - Upload data to the cloud
  - Store medical history permanently
  - Offer generic or alarming explanations

---

## 💡 Our Solution
**MediLens** bridges the gap between **clinical data** and **patient understanding** by:
- Processing reports **entirely on-device**
- Highlighting abnormal values **instantly**
- Explaining results in **plain, reassuring English**
- Ensuring **zero data persistence** after session end

## 🚀 Key Features

### 🛡️ Edge-First Privacy
- Session-based architecture
- No cloud storage of reports
- Medical data is wiped from memory once the app closes

### 🧠 Hybrid Intelligence Engine
- **Google ML Kit** → Deterministic, on-device OCR (facts)
- **Gemini 3.0 Flash** → Contextual reasoning & empathetic summaries

### 🚦 Instant Visual Triage
- Traffic-light system for test results:
  - 🟢 Green — Normal
  - 🟠 Amber — Needs attention
  - 🔴 Red — Critical / Out of range

### 📂 Multi-Source Report Ingestion
- PDF lab reports
- Gallery images
- Live camera scanning

### 🗣️ Plain-English Health Translator
- Converts medical jargon into:
  - Simple explanations
  - What the value means
  - When to consult a doctor (without diagnosing)

## 🏆 Why MediLens Stands Out

✅ **Privacy-by-Design** — No data hoarding, no cloud leaks  
✅ **Real-World Impact** — Reduces health anxiety & confusion  
✅ **On-Device AI** — Fast, offline-friendly, scalable  
✅ **Clear Separation of Concerns** — Clean architecture  
✅ **Ethical AI Use** — Information, not diagnosis  

> MediLens doesn’t replace doctors — it prepares patients.

## 🛠️ Tech Stack (Google Ecosystem)

| Layer | Technology |
|-----|-----------|
| UI Framework | Flutter (Dart 3.0+) — Material 3 |
| OCR | Google ML Kit (On-Device Text Recognition v2) |
| AI Reasoning | Google Generative AI SDK (Gemini 3.0 Flash) |
| Medical Standards | Firebase Firestore (Reference Ranges) |
| State Management | Provider |
| Architecture | Clean Architecture (Logic / Services / UI) |

## ⚙️ Installation & Setup

Follow these steps to run **MediLens** locally.

---

### 1️⃣ Prerequisites

* **Flutter SDK**
* **Android Studio**

  * Ensure **Android SDK Command-line Tools** are installed
    (`Android Studio > SDK Manager`)
* **Git**

---

### 2️⃣ Clone the Repository

```bash
git clone https://github.com/YourUsername/MediLens.git
cd MediLens
```

---

### 3️⃣ Install Dependencies

```bash
flutter pub get
```

---

### 4️⃣ 🔐 Configure API Keys (Required)

> API keys are intentionally excluded from version control.

#### A. Google Gemini API Setup

1. Go to **Google AI Studio** → *Get API Key*
2. Create the file:

```
lib/secrets.dart
```

3. Paste the following code:

```dart
class Secrets {
  static const String geminiApiKey = "AIzaSyYourKeyHere...";
}
```

---

#### B. Firebase Setup (Android)

1. Open **Firebase Console**
2. Create a project named **MediLens**
3. Add an **Android App** with the package name:

```
com.example.arcane_medical_app
```

4. Download `google-services.json`
5. Move it to:

```
android/app/google-services.json
```

> *For iOS, place `GoogleService-Info.plist` in `ios/Runner/` (not covered here).*

---

### 5️⃣ Run the Application

Connect a physical Android device (USB debugging enabled)
or start an Android Emulator.

```bash
flutter run
```

---

## 📂 Architecture & Modules

```
lib/
├── services/
│   ├── gemini_service.dart      # AI reasoning & summarization
│   ├── standards_service.dart   # Medical reference validation
│   └── user_service.dart        # Session handling
│
├── utils/
│   ├── report_parser.dart       # OCR + Regex extraction
│   └── constants.dart
│
├── controllers/
│   ├── upload_controller.dart   # File input & permissions
│   └── report_controller.dart   # Active report state
│
└── views/
    ├── screens/
    │   ├── dashboard_screen.dart
    │   └── reports_screen.dart
    └── widgets/
```

---

## 🤝 Contributing

1. Fork the project
2. Create your feature branch:

```bash
git checkout -b feature/AmazingFeature
```

3. Commit your changes:

```bash
git commit -m "Add AmazingFeature"
```

4. Push to your branch:

```bash
git push origin feature/AmazingFeature
```

5. Open a Pull Request

Project Made For: [TechSprint - GDG]
Team: [CodeBlitz]
Project Status: [MVP]

---

## ⚠️ Medical Disclaimer

**MediLens is a prototype built for educational and demonstration purposes only.**

* Not a medical diagnostic tool
* AI interpretations may contain errors
* OCR inaccuracies are possible
* Do not make medical decisions based solely on this app

Always consult a licensed healthcare professional.

> *Technology should explain health — not complicate it.*
