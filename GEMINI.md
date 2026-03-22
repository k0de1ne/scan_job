# Scan Job - Flutter Core Architecture & Agent Guidelines

This project is a high-standard boilerplate optimized for **Scan Job** (Career/Professional AI Assistant), focusing on multi-platform support (Web, Desktop, Mobile) and strict architectural integrity.

## 🚨 CRITICAL DIRECTIVES FOR AGENTS

### 1. Branding & Identity
- **Project Name**: ALWAYS use **Scan Job**. 
- **NO GEMINI**: Never use "Gemini" in UI, strings, or asset names. If you see it, refactor it to "Scan Job".
- **Icons**: Use `ScanJobIcon` or icons from `lib/chat/widgets/scan_job_icon.dart`. Avoid Google/Gemini-specific sparkles or logos.

### 2. Design System & "No-Hardcode" Policy
- **NO HEX COLORS**: Strictly forbidden to use `Color(0xFF...)` or `Colors.someColor` inside `lib/features/` or `lib/chat/`.
- **Theme Tokens**: ONLY use `Theme.of(context).colorScheme`.
    - Backgrounds: `surface`, `surfaceContainerLow`, `surfaceContainer`.
    - Text: `onSurface`, `onSurfaceVariant`.
    - Primary Actions: `primary`, `onPrimary`.
- **Theme Location**: All global styling is defined in `lib/theme/app_theme.dart`. If a color is missing, add a `ThemeExtension`.
- **Border Radius**: Global default is **8px** (configured in theme). Do not hardcode custom radius unless it's a specific shape (like 24px for chat bubbles).

### 3. Localization (L10n)
- **ARB Files**: All strings MUST be in `lib/l10n/arb/app_en.arb` and `app_ru.arb`.
- **Generation**: After adding strings, ALWAYS run `flutter gen-l10n`.
- **Imports**: Use `import 'package:scan_job/l10n/l10n.dart';`.

## 🏗️ SYSTEM ARCHITECTURE & INTEGRATION

### 1. Flutter Core (Frontend)
- **Feature-Driven Design**: Logic, UI, and Models are grouped within feature folders in `lib/`.
- **State Management**: Cubit (via `flutter_bloc`) is preferred.
- **Background Processes**: `Workmanager` handles periodic resume updates every 4 hours on mobile.

### 2. Python Backends (Services)
- **HH Auth Server (`/server_auth_hh`)**: Uses **Playwright** to automate HeadHunter login. Necessary when standard OAuth is insufficient (e.g., phone/SMS verification automation).
- **LLM Proxy (`/server_llm_api`)**: FastAPI service that wraps LLM calls. Provides an OpenAI-compatible `/v1/chat/completions` endpoint.

### 3. Tool Execution Flow (LLM Tools)
- `HhTool.instance` (in `lib/tools/hh_tool.dart`) is the bridge between LLM and real-world actions.
- LLM triggers tools via function calling (e.g., `hh_get_my_resumes`, `hh_mass_apply`).
- Actions are executed locally in the app or via direct API calls to `api.hh.ru`.

## 🛡️ SECURITY & CONFIGURATION
- **Secrets**: Never hardcode `HH_CLIENT_ID` or `HH_CLIENT_SECRET`. Use `--dart-define` or `.env` for backend services.
- **Cookies**: HH cookies are sensitive. They are stored in `shared_preferences` and should never be logged or exposed.
- **Local Dev**: Use `10.0.2.2` to access localhost from Android emulators.

## 🚀 ESSENTIAL COMMANDS
- `flutter gen-l10n` - Update localization.
- `flutter test` - Run all tests (100% coverage target).
- `flutter run --target lib/main_development.dart` - Local dev.
- `pip install -r requirements.txt` - Setup Python backends.

**Remember**: You are building a professional SaaS tool. Keep the code as clean as the UI.
