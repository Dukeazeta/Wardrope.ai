# BLoC State Management Implementation

This document outlines the BLoC (Business Logic Component) state management implementation for the Wardrope.ai Flutter application.

## Overview

The application uses the BLoC pattern to manage state across different features, providing a predictable and scalable state management solution.

## BLoC Architecture

### 1. Authentication BLoC (`auth/`)
- **Purpose**: Manages user authentication state
- **Events**:
  - `AuthStarted`: Initialize authentication check
  - `AuthLoggedIn`: User successfully logged in
  - `AuthLoggedOut`: User logged out
  - `AuthRegistrationCompleted`: User registration completed
- **State**: Contains authentication status, user ID, email, and error messages

### 2. Wardrobe BLoC (`wardrobe/`)
- **Purpose**: Manages clothing items and wardrobe operations
- **Events**:
  - `WardrobeLoadItems`: Load clothing items from storage/API
  - `WardrobeAddItem`: Add new clothing item
  - `WardrobeRemoveItem`: Remove clothing item
  - `WardrobeUpdateItem`: Update existing clothing item
  - `WardrobeFilterByCategory`: Filter items by category
  - `WardrobeSearchItems`: Search items by query
  - `WardrobeSelectItem`: Select specific item
- **State**: Contains items list, filtered items, selected category, search state

### 3. Onboarding BLoC (`onboarding/`)
- **Purpose**: Manages onboarding flow and user progress
- **Events**:
  - `OnboardingStarted`: Initialize onboarding
  - `OnboardingPageChanged`: Navigate to specific page
  - `OnboardingNextPage`: Move to next page
  - `OnboardingPreviousPage`: Move to previous page
  - `OnboardingSkipped`: Skip onboarding
  - `OnboardingCompleted`: Complete onboarding
- **State**: Contains current page, completion status, user data

### 4. Navigation BLoC (`navigation/`)
- **Purpose**: Manages bottom navigation and page transitions
- **Events**:
  - `NavigationTabChanged`: Change bottom navigation tab
  - `NavigationItemTapped`: Handle specific navigation item
- **State**: Contains current and previous navigation indices

## File Structure

```
lib/bloc/
├── app_bloc.dart              # Main BLoC provider configuration
├── auth/
│   ├── auth_bloc.dart         # Authentication BLoC
│   ├── auth_event.dart        # Authentication events
│   └── auth_state.dart        # Authentication states
├── wardrobe/
│   ├── wardrobe_bloc.dart     # Wardrobe BLoC
│   ├── wardrobe_event.dart    # Wardrobe events
│   └── wardrobe_state.dart    # Wardrobe states
├── onboarding/
│   ├── onboarding_bloc.dart   # Onboarding BLoC
│   ├── onboarding_event.dart  # Onboarding events
│   └── onboarding_state.dart  # Onboarding states
└── navigation/
    ├── navigation_bloc.dart   # Navigation BLoC
    ├── navigation_event.dart  # Navigation events
    └── navigation_state.dart  # Navigation states
```

## Integration with Screens

### Main App Integration
- `main.dart` sets up `MultiBlocProvider` with all BLoCs
- Global listeners handle authentication and onboarding state changes
- Navigation logic triggered by BLoC state changes

### Screen-Level Integration
- **OnboardingScreen**: Uses `OnboardingBloc` for flow management
- **WardrobeScreen**: Uses `WardrobeBloc` for item management
- **MainContainer**: Uses `NavigationBloc` for tab management

## Benefits of BLoC Implementation

1. **Separation of Concerns**: Business logic separated from UI
2. **Predictable State**: Unidirectional data flow
3. **Testability**: Easy to unit test BLoCs
4. **Reactive UI**: UI automatically responds to state changes
5. **Scalability**: Easy to add new features and states

## Usage Examples

### Adding a Clothing Item
```dart
context.read<WardrobeBloc>().add(
  WardrobeAddItem(clothingItem),
);
```

### Filtering by Category
```dart
context.read<WardrobeBloc>().add(
  WardrobeFilterByCategory('Shirts'),
);
```

### Handling Navigation
```dart
context.read<NavigationBloc>().add(
  NavigationTabChanged(1),
);
```

## Dependencies

- `flutter_bloc: ^8.1.6` - Main BLoC library
- `equatable: ^2.0.5` - Value equality for states and events

## Future Enhancements

1. **Persistence**: Add local storage integration (SharedPreferences, Hive)
2. **API Integration**: Connect to backend services
3. **Advanced Filtering**: Implement more sophisticated filtering options
4. **Offline Support**: Add offline state management
5. **State Hydration**: Restore state on app restart

## Best Practices

1. **Events as Immutable**: All events should be immutable
2. **State Equality**: Use Equatable for proper state comparison
3. **Error Handling**: Include error states in all BLoCs
4. **Loading States**: Provide loading indicators for async operations
5. **BLoC Scope**: Keep BLoCs focused on single responsibilities