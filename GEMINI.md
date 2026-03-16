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

## ARCHITECTURE OVERVIEW

### Feature-Driven Design (`lib/feature_name/`)
- `bloc/` or `cubit/`: State management. Inject repositories via constructor.
- `view/`: UI split into `page.dart` (Entry point + BlocProvider) and `view.dart` (Layout + BlocBuilder).
- `widgets/`: Local components only. Global components go to `lib/widgets/` (if created).
- `models/`: DTOs and domain models.

### Data Layer (Repositories)
- **Location**: `lib/repositories/`.
- **Pattern**: Abstract class (interface) in `chat_repository.dart` + implementation in `chat_repository_impl.dart`.
- **Flow**: Cubit -> Repository -> Data Source (Dio/Hive/etc).

## DEVELOPMENT WORKFLOW
1. **Define Data**: Update repository interface and implementation.
2. **Add Strings**: Update ARB files -> `flutter gen-l10n`.
3. **Logic**: Implement Cubit/State. Use `emit` for state updates.
4. **UI**: Create View using `Theme.of(context).colorScheme`.
5. **Routes**: Register in `lib/router/app_router.dart`.
6. **Test**: Add to `pagesToTest` in `test/app/view/app_test.dart`.

## ESSENTIAL COMMANDS
- `flutter gen-l10n` - Update localization.
- `flutter test` - Run all tests (100% coverage target).
- `flutter run --target lib/main_development.dart` - Local dev.

**Remember**: You are building a professional SaaS tool. Keep the code as clean as the UI.
