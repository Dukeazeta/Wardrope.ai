part of 'navigation_bloc.dart';

class NavigationState extends Equatable {
  final int currentIndex;
  final int previousIndex;

  const NavigationState({
    this.currentIndex = 0,
    this.previousIndex = 0,
  });

  NavigationState copyWith({
    int? currentIndex,
    int? previousIndex,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      previousIndex: previousIndex ?? this.previousIndex,
    );
  }

  @override
  List<Object> get props => [currentIndex, previousIndex];
}