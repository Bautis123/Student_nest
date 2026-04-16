# Student Nest Codebase Refactor Guide

This document explains the current modular structure after the UI refactor and how to keep the codebase maintainable with low coupling.

## Goals

- Keep screens as orchestration layers only.
- Move business/filter logic out of UI files.
- Move reusable UI blocks into focused widget modules.
- Keep feature folders cohesive and easy to navigate.

## Core Principles

- Single responsibility per file.
- Feature-first organization over giant shared files.
- Prefer pure functions/services for logic, widgets for presentation.
- Keep screen state local unless it is truly shared.
- Avoid cross-feature imports where possible.

## Current High-Level Structure

- `lib/screens/...`: Feature entry points and composition.
- `lib/screens/<feature>/<subfeature>/...`: Feature-local widgets/logic.
- `lib/widgets/...`: Shared, generic app widgets.
- `lib/services/...`: API and external service integration.
- `lib/utils/...`: Theme, constants, and app-level helpers.

## Refactored Areas

### 1) Browse Feature

Files:

- `lib/screens/student/browse_screen.dart`
- `lib/screens/student/browse/browse_filters.dart`
- `lib/screens/student/browse/browse_filters_sheet.dart`
- `lib/screens/student/browse/browse_controls.dart`
- `lib/screens/student/browse/browse_empty_state.dart`
- `lib/screens/student/browse/browse_error_state.dart`

Responsibilities:

- `browse_screen.dart`
  - Owns screen state and lifecycle.
  - Coordinates data loading, location label, and sliver composition.
- `browse_filters.dart`
  - Owns filter enum and filtering/sorting engine (`BrowseFilterEngine`).
  - Contains pure logic for applying selected filters.
- `browse_filters_sheet.dart`
  - Owns popup filter selection UI and apply/reset behavior.
- `browse_controls.dart`
  - Owns small reusable controls (`BrowseFilterButton`, `BrowseCountPill`).
- `browse_empty_state.dart`, `browse_error_state.dart`
  - Own static state visuals.

### 2) Property Detail Feature

Files:

- `lib/screens/student/property_detail_screen.dart`
- `lib/screens/student/property_detail/property_detail_sections.dart`
- `lib/screens/student/property_detail/property_route_actions.dart`
- Existing detail widgets under `lib/screens/student/property_detail/...`

Responsibilities:

- `property_detail_screen.dart`
  - Owns loading state and section composition.
  - Triggers action handlers for maps/call/photo flows.
- `property_detail_sections.dart`
  - Owns amenities and rooms section widgets.
- `property_route_actions.dart`
  - Owns map/yango launch behavior and route-opening side effects.
  - Handles platform-specific URL launch logic.

### 3) Landlord Auth Screens

Files:

- `lib/screens/landlord/login_screen.dart`
- `lib/screens/landlord/register_screen.dart`
- `lib/screens/landlord/widgets/login_screen_content.dart`
- `lib/screens/landlord/widgets/register_screen_content.dart`

Responsibilities:

- `login_screen.dart`, `register_screen.dart`
  - Own form state, validation, and API calls.
  - Delegate rendering to content widgets.
- `login_screen_content.dart`, `register_screen_content.dart`
  - Own UI layout and callbacks only.

## Suggested File Pattern for New Features

For a feature named `example`:

- `lib/screens/example/example_screen.dart` (state + composition)
- `lib/screens/example/example_state.dart` (optional, if state object helps)
- `lib/screens/example/example_actions.dart` (side-effect actions)
- `lib/screens/example/widgets/...` (feature-local UI pieces)
- `lib/screens/example/example_logic.dart` (pure logic only)

## Rules for Keeping Low Coupling

- Do not place heavy logic directly inside large screen `build` methods.
- Move sorting/filtering/calculation logic into pure modules.
- Keep side-effect logic in action/service files, not UI widgets.
- Pass data through constructor parameters instead of global reach-in.
- Avoid importing one feature screen into another feature’s internals.

## Practical Refactor Checklist

When a file grows too large:

1. Split visual sections into widgets.
2. Extract pure logic into a non-widget module.
3. Extract external side effects into an actions/service module.
4. Keep screen file focused on lifecycle + composition.
5. Run `dart format` and `dart analyze` on touched files.

## Validation Commands

Use these after refactors:

```powershell
dart format lib
dart analyze
flutter test
```

For targeted checks:

```powershell
dart analyze <file1> <file2> ...
```

## Notes

- The project currently includes both older and newer code styles in different areas.
- Continue applying the same modular style incrementally to remaining large files (`add_listing_screen.dart`, `property_card.dart`, `payment_record_dialog.dart`, etc.) for consistency.
