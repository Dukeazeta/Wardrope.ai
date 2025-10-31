import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigationTabChanged>(_onTabChanged);
    on<NavigationItemTapped>(_onItemTapped);
  }

  void _onTabChanged(NavigationTabChanged event, Emitter<NavigationState> emit) {
    emit(state.copyWith(
      previousIndex: state.currentIndex,
      currentIndex: event.newIndex,
    ));
  }

  void _onItemTapped(NavigationItemTapped event, Emitter<NavigationState> emit) {
    int newIndex = state.currentIndex;

    switch (event.item) {
      case 'wardrobe':
        newIndex = 0;
        break;
      case 'model':
        newIndex = 1;
        break;
      case 'ai_stylist':
        newIndex = 2;
        break;
      case 'profile':
        newIndex = 3;
        break;
    }

    if (newIndex != state.currentIndex) {
      emit(state.copyWith(
        previousIndex: state.currentIndex,
        currentIndex: newIndex,
      ));
    }
  }
}