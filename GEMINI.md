gem   # Scan Job - Flutter Core Architecture

This project is a boilerplate optimized for **multi-platform (Web, Desktop, Mobile)** and modern library versions (2025-2026).

## Environment and Constraints (Critical)

- **OS**: Cross-platform (Web, macOS, Windows, Linux, Android, iOS).
- **Windows-specific**: Be cautious with deep folder nesting due to path limits.

## UI & Design System

- **Primary Stack**: Material 3 + `flex_color_scheme` + `google_fonts`.
- **Theme**: Configured in `lib/app/view/app.dart` using `FlexScheme.greyLaw` for a professional SaaS-like aesthetic.
- **Typography**: Primary font is **Inter** (via `google_fonts`).
- **Aesthetics**: Modern look achieved by using a tight **8px border radius** for components (configured in global theme).
- **Guidelines**: Use standard Flutter widgets. Access theme colors via `Theme.of(context).colorScheme`.

## Localization (L10n)

Standalone localization is used to avoid virtual package issues in `.dart_tool` on Windows.

- **ARB Files**: Located in `lib/l10n/arb/`.
- **Generation**: Code MUST be generated into the physical folder `lib/l10n/generated/`.
- **Configuration**: `l10n.yaml` is set to `output-dir: lib/l10n/generated`.
- **Imports**: Use `import 'package:scan_job/l10n/l10n.dart';`. Do NOT import `package:flutter_gen`.
- **Command**: `flutter gen-l10n`

## Architecture and Feature Creation

The project follows Feature-Driven Design. Each feature resides in its own folder in `lib/`.

### Feature Structure (`lib/my_feature/`):
- `bloc/` or `cubit/`: State management files (`my_feature_bloc.dart`, `my_feature_event.dart`, `my_feature_state.dart`).
- `view/`: Screens (`my_feature_page.dart` and `my_feature_view.dart`).
- `widgets/`: Local components.
- `models/`: Feature-specific DTOs and domain models.

### Implementation Workflow:
1. **Repository**: Define data and create a repository in `lib/repositories/` if needed.
2. **Localization**: Add strings to `lib/l10n/arb/app_en.arb` and run `flutter gen-l10n`.
3. **BLoC/Cubit**: Implement logic in `bloc/`. Use `emit` for state updates.
4. **UI**:
   - `Page`: Provides `BlocProvider` and returns the `View`.
   - `View`: Uses `BlocBuilder`/`BlocListener` to build the interface.
5. **Tests**: Create matching structure in `test/my_feature/` for Cubit and View tests.

## State Management

- **Libraries**: `bloc` and `flutter_bloc` version 9.x.
- **Rule**: Prefer `StatelessWidget` + `BlocBuilder` over `StatefulWidget` when state can be managed in BLoC.

## Testing

- **Coverage**: Aim for 100%.
- **Tools**: `bloc_test`, `mocktail`.
- **Widget Tests**: Use `tester.pumpApp(Widget)` from `test/helpers/pump_app.dart` to include localization providers and base styles.
- **L10n & UI Validation**: 
  - All screens MUST be added to `pagesToTest` list in `test/app/view/app_test.dart`.
  - This automatically validates each screen across ALL supported locales (`en`, `ru`, etc.).
  - It checks for rendering errors and UI overflows on narrow screens (320x480).

## Essential Commands

- **Run (Dev)**: `flutter run --target lib/main_development.dart`
- **Tests**: `flutter test`
- **Update L10n**: `flutter gen-l10n`
- **Clean and Get Packages**: `flutter clean; flutter pub get`
