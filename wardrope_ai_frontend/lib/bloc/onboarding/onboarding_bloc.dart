import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/onboarding_data.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted);
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingPreviousPage>(_onPreviousPage);
    on<OnboardingSkipped>(_onSkipped);
    on<OnboardingCompleted>(_onCompleted);
  }

  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(
      status: OnboardingStatus.inProgress,
      currentPage: 0,
      isLastPage: OnboardingData.items.length == 1,
    ));
  }

  void _onPageChanged(OnboardingPageChanged event, Emitter<OnboardingState> emit) {
    final totalPages = OnboardingData.items.length;
    final isLastPage = event.pageIndex == totalPages - 1;

    emit(state.copyWith(
      currentPage: event.pageIndex,
      isLastPage: isLastPage,
    ));
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    final totalPages = OnboardingData.items.length;
    final nextPage = state.currentPage + 1;

    if (nextPage < totalPages) {
      emit(state.copyWith(
        currentPage: nextPage,
        isLastPage: nextPage == totalPages - 1,
      ));
    }
  }

  void _onPreviousPage(OnboardingPreviousPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage > 0) {
      final prevPage = state.currentPage - 1;
      emit(state.copyWith(
        currentPage: prevPage,
        isLastPage: false,
      ));
    }
  }

  void _onSkipped(OnboardingSkipped event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(
      status: OnboardingStatus.skipped,
    ));
  }

  void _onCompleted(OnboardingCompleted event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(
      status: OnboardingStatus.completed,
      userData: event.userData,
    ));
  }
}