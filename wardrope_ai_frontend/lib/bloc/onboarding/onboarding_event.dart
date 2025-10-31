part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class OnboardingStarted extends OnboardingEvent {}

class OnboardingPageChanged extends OnboardingEvent {
  final int pageIndex;

  const OnboardingPageChanged(this.pageIndex);

  @override
  List<Object> get props => [pageIndex];
}

class OnboardingNextPage extends OnboardingEvent {}

class OnboardingPreviousPage extends OnboardingEvent {}

class OnboardingSkipped extends OnboardingEvent {}

class OnboardingCompleted extends OnboardingEvent {
  final Map<String, dynamic>? userData;

  const OnboardingCompleted({this.userData});

  @override
  List<Object> get props => userData != null ? [userData!] : [];
}