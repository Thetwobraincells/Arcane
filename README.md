# 💎 Medical Dashboard (Piltover Med)

> **"Science and Magic, united for better health."**

A futuristic, **Hextech-styled** medical report analysis platform built with Flutter. This project reimagines boring medical data into a visually stunning, easy-to-understand dashboard inspired by the aesthetics of *Arcane*.

Powered by **Google Gemini AI** for instant report interpretation.

---

### 🚀 Key Features

* **🧠 Multimodal AI Analyst**: Uses **Google Gemini Flash** to "see" and interpret complex medical report images, extracting data into structured JSON.
* **📚 Medical Codex**: A built-in "Arcane Knowledge" dictionary that explains medical terms (Hemoglobin, Lipids, etc.) with reference ranges for Adults, Children, and the Elderly.
* **🔮 Hextech UI**: A custom-built, glowing dark theme that makes data pop with "ink sparkle" shaders and glassmorphism.
* **📊 Health Insights**: Automatically calculates health scores and visualizes test status distribution (Normal vs. Critical).
* **🛡️ Privacy-First**: Features a "Guest Mode" with **Zero-Persistence** architecture. Reports are processed in memory and never stored on a backend server.
* **📂 Smart Upload**: Supports Gallery and Camera input for JPG, PNG, and PDF files with validation.

---

### 🛠️ Tech Stack

* **Framework**: [Flutter](https://flutter.dev/) (Dart)
* **AI Engine**: [Google Generative AI SDK](https://pub.dev/packages/google_generative_ai) (Gemini 1.5 Flash)
* **State Management**: `Provider` (Multi-provider setup)
* **UI/Fonts**: `Google Fonts` (Outfit/Inter), Custom Shaders
* **File Handling**: `file_picker`

---

### 📂 Architecture & Modules

* **`lib/services/gemini_service.dart`**: The "Brain" of the app. Handles the connection to Google Gemini, sending image byte data and receiving structured JSON with simplified explanations.
* **`lib/controllers/upload_controller.dart`**: Manages file picking, permission handling, and file type validation (JPG/PNG/PDF).
* **`lib/views/screens/`**:
    * `dashboard_screen.dart`: Main landing with quick stats.
    * `reports_screen.dart`: detailed breakdown of analyzed tests with AI warnings.
    * `stats_screen.dart` (Medical Codex): Searchable dictionary of medical terminology.
    * `settings_screen.dart`: App preferences, units, and privacy controls.

---

### ⚙️ How to Run

**Prerequisites:** Flutter SDK installed and a Google Gemini API Key.

1.  **Clone the Repo**
    ```bash
    git clone [https://github.com/Thetwobraincells/Arcane.git]
    cd Arcane
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Configure API Key**
    * Create a `lib/secrets.dart` file (this is git-ignored for security).
    * Add your key: `class Secrets { static const geminiApiKey = "YOUR_API_KEY"; }`

4.  **Run the App**
    ```bash
    flutter run
    ```

---

### 🤝 Contributing
Built for the **[Arcane - IEEE]**.
* **Team**: [CodeBlitz]
* **Status**: Prototype / MVP

### ⚠️ Disclaimer
This application is for **educational and demonstration purposes only**. The AI-generated insights should not be treated as medical advice. Always consult a qualified healthcare provider.

> *"Progress day is every day."*
