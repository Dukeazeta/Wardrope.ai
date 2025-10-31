part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, inProgress, completed, skipped }

class OnboardingState extends Equatable {
  final OnboardingStatus status;
  final int currentPage;
  final bool isLastPage;
  final Map<String, dynamic>? userData;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.currentPage = 0,
    this.isLastPage = false,
    this.userData,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    int? currentPage,
    bool? isLastPage,
    Map<String, dynamic>? userData,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      isLastPage: isLastPage ?? this.isLastPage,
      userData: userData ?? this.userData,
    );
  }

  @override
  List<Object?> get props => [status, currentPage, isLastPage, userData];
}