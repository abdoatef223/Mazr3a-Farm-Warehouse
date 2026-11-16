import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';

abstract interface class ExportRepo {
  FutureApiResult<String> exportToExcel(ExportParams params);
}
