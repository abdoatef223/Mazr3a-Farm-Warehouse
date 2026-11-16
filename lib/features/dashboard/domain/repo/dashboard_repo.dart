import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/dashboard/domain/entity/dashboard_summary_entity.dart';

abstract interface class DashboardRepo {
  FutureApiResult<DashboardSummaryEntity> getDashboardSummary({int limit = 10});
}
