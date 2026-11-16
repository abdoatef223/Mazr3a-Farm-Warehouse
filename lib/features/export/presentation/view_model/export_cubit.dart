import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/domain/use_cases/export_to_excel_use_case.dart';

part 'export_states.dart';

@Injectable()
class ExportCubit extends Cubit<ExportStates> {
  ExportCubit(this._exportToExcelUseCase) : super(const ExportIdle());

  final ExportToExcelUseCase _exportToExcelUseCase;

  Future<void> export({
    required ExportScope scope,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
    String? activeFilter,
    bool hideZeroStock = false,
  }) async {
    emit(const ExportLoading());
    final result = await _exportToExcelUseCase(
      ExportParams(
        scope: scope,
        dateFrom: dateFrom,
        dateTo: dateTo,
        searchQuery: searchQuery,
        activeFilter: activeFilter,
        hideZeroStock: hideZeroStock,
      ),
    );
    switch (result) {
      case ApiSuccess(:final data):
        emit(ExportSuccess(filePath: data));
      case ApiError(:final message):
        emit(ExportError(message: message));
    }
  }

  void reset() {
    emit(const ExportIdle());
  }
}
