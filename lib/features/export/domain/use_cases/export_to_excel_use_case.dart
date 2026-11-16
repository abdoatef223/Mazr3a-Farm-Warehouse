import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';
import 'package:mazr3a/features/export/domain/repo/export_repo.dart';

@singleton
class ExportToExcelUseCase {
  const ExportToExcelUseCase(this._exportRepo);

  final ExportRepo _exportRepo;

  FutureApiResult<String> call(ExportParams params) =>
      _exportRepo.exportToExcel(params);
}
