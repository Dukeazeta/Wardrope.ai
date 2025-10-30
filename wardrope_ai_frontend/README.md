# Wardrope.ai Flutter App

A clean, modular Flutter application with an onboarding experience for AI-powered fashion recommendations.

## Project Structure

```
lib/
├── main.dart                    # App entry point and routing configuration
├── models/
│   └── onboarding_data.dart     # Onboarding data models and constants
├── screens/
│   ├── onboarding_screen.dart   # Main onboarding screen controller
│   └── home_screen.dart         # Home screen after onboarding
└── widgets/
    ├── onboarding_page.dart     # Individual onboarding page widget
    └── page_indicator.dart      # Page indicator dots widget
```

## Features

- **Modular Architecture**: Clean separation of concerns with dedicated folders for models, screens, and widgets
- **Modern UI**: Material Design 3 with custom color scheme
- **Smooth Animations**: Page transitions and interactive indicators
- **Type Safety**: Fully typed Dart code with null safety
- **Test Coverage**: Basic widget tests included

## Onboarding Flow

1. Welcome to Wardrope.ai
2. Smart Wardrobe Analysis
3. Plan Your Looks
4. Get Started

## Key Components

### OnboardingItem Model
- `title`: String - Page title
- `description`: String - Page description
- `icon`: IconData - Icon representation
- `color`: Color - Theme color for the page
- `imageAsset`: String? - Optional image asset

### Main Widgets

- **OnboardingScreen**: Main controller with PageView
- **OnboardingPageWidget**: Individual page content
- **PageIndicatorWidget**: Animated page indicators

## Running the App

```bash
flutter pub get
flutter run
```

## Testing

```bash
flutter test
flutter analyze
```

## Dependencies

- Flutter SDK
- Material Design 3
- No external dependencies required (uses built-in Flutter widgets)

## Design System

- **Primary Color**: #6C63FF (Deep Purple)
- **Typography**: SF Pro Display
- **Icons**: Material Icons
- **Spacing**: Consistent 24px/40px spacing system
