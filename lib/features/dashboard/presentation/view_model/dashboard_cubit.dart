import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/dashboard/domain/entity/dashboard_summary_entity.dart';
import 'package:mazr3a/features/dashboard/domain/use_cases/get_dashboard_summary_use_case.dart';

part 'dashboard_states.dart';

@lazySingleton
class DashboardCubit extends Cubit<DashboardStates> {
  DashboardCubit(
    this._getDashboardSummaryUseCase,
    this._changeNotifier,
  ) : super(const DashboardInit()) {
    _changeNotifier.addListener(_onDataChanged);
    unawaited(loadSummary());
  }

  final GetDashboardSummaryUseCase _getDashboardSummaryUseCase;
  final WarehouseChangeNotifier _changeNotifier;

  static DashboardCubit of(BuildContext context) =>
      context.read<DashboardCubit>();

  void _onDataChanged() {
    unawaited(loadSummary());
  }

  Future<void> loadSummary() async {
    emit(const DashboardLoading());
    final result = await _getDashboardSummaryUseCase();
    switch (result) {
      case ApiSuccess(:final data):
        emit(DashboardLoaded(summary: data));
      case ApiError(:final message):
        emit(DashboardError(message: message));
    }
  }

  @override
  Future<void> close() {
    _changeNotifier.removeListener(_onDataChanged);
    return super.close();
  }
}
