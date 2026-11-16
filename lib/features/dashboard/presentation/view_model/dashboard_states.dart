part of 'dashboard_cubit.dart';

sealed class DashboardStates {
  const DashboardStates();

  DashboardStates copyWith();
}

class DashboardInit extends DashboardStates {
  const DashboardInit();

  @override
  DashboardInit copyWith() => const DashboardInit();
}

class DashboardLoading extends DashboardStates {
  const DashboardLoading();

  @override
  DashboardLoading copyWith() => const DashboardLoading();
}

class DashboardLoaded extends DashboardStates {
  const DashboardLoaded({required this.summary});

  final DashboardSummaryEntity summary;

  @override
  DashboardLoaded copyWith({DashboardSummaryEntity? summary}) =>
      DashboardLoaded(summary: summary ?? this.summary);
}

class DashboardError extends DashboardStates {
  const DashboardError({required this.message});

  final String message;

  @override
  DashboardError copyWith({String? message}) =>
      DashboardError(message: message ?? this.message);
}
