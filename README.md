# 💼 Scan Job — Professional AI Career Assistant

**Scan Job** is a high-performance, multi-platform AI assistant designed to revolutionize job searching and career management. It provides deep integration with major job boards (starting with HeadHunter), automated resume management, and intelligent market analysis.

---

## 🚀 Key Features

- **🤖 AI Career Chat**: Intelligent assistant that understands your professional background and helps you find the best opportunities.
- **🔄 Multi-Account HH Integration**: Connect and manage multiple HeadHunter accounts simultaneously.
- **📈 Market Analysis (ATS Score)**: Deep-dive into vacancies to understand how well your resume matches market demands.
- **⚡ Auto-Update**: Keep your resumes at the top of search results with automated background raising (every 4 hours on Mobile).
- **📝 Resume Management**: Create, edit, and optimize resumes directly from the app.
- **📡 Mass Application**: intelligent bulk application to vacancies with personalized cover letters.
- **🎨 Modern Design**: Built with Flutter and Material 3, featuring a fully adaptive UI for Web, Desktop, and Mobile.

---

## 🏗️ Project Architecture

The project follows a **Feature-Driven Design** with a strict separation of concerns.

### 📱 Flutter Application (`/lib`)
- **State Management**: BLoC / Cubit for predictable state transitions.
- **Routing**: `go_router` for deep linking and navigation.
- **Local Storage**: `hydrated_bloc` for state persistence and `shared_preferences` for tokens.
- **Background Tasks**: `Workmanager` for periodic resume updates.
- **UI Architecture**: Features are split into `page`, `view`, `cubit`, and `widgets`.

### 🐍 Backend Services
1.  **HH Auth Server (`/server_auth_hh`)**: Python + Playwright service for automated login flows (Phone/SMS/Captcha) that bypass standard OAuth limitations.
2.  **LLM API Server (`/server_llm_api`)**: FastAPI proxy for LLM interactions, providing a unified OpenAI-compatible interface.

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Python 3.10+ (for backends)

### Frontend Setup
1.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
2.  **Generate localization**:
    ```bash
    flutter gen-l10n
    ```
3.  **Run the app**:
    ```bash
    # For development
    flutter run --target lib/main_development.dart
    ```

### Backend Setup (Optional but recommended)
1.  **HH Auth Server**:
    ```bash
    cd server_auth_hh
    pip install -r requirements.txt
    playwright install chromium
    python main.py
    ```
2.  **LLM API Server**:
    ```bash
    cd server_llm_api
    pip install -r requirements.txt
    # Configure .env with your API keys
    python main.py
    ```

---

## 📦 Project Structure

```text
lib/
├── app/          # App entry point & global config
├── chat/         # AI Chat feature (the core)
├── dashboard/    # User metrics & activity
├── home/         # Dashboard / Landing
├── repositories/ # Data layer (API clients, impl)
├── tools/        # External tool integrations (HH.ru)
└── theme/        # App branding & tokens
```

---

## 🛡️ Guidelines for Contributors

- **Branding**: Always refer to the project as **Scan Job**.
- **Colors**: No hardcoded hex values. Use `Theme.of(context).colorScheme`.
- **Strings**: All text must be in `.arb` files for localization.
- **Testing**: Maintain high coverage with `flutter test`.

For more detailed technical rules, see [GEMINI.md](./GEMINI.md).

---

## 📄 License
This project is proprietary. All rights reserved.
