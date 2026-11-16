import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/dashboard/domain/entity/dashboard_summary_entity.dart';
import 'package:mazr3a/features/dashboard/domain/repo/dashboard_repo.dart';

@singleton
class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._dashboardRepo);

  final DashboardRepo _dashboardRepo;

  FutureApiResult<DashboardSummaryEntity> call({int limit = 10}) =>
      _dashboardRepo.getDashboardSummary(limit: limit);
}
