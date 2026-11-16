import 'package:mazr3a/features/export/domain/model/export_scope.dart';

class ExportParams {
  const ExportParams({
    required this.scope,
    this.dateFrom,
    this.dateTo,
    this.searchQuery,
    this.activeFilter,
    this.hideZeroStock = false,
  });

  final ExportScope scope;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? searchQuery;
  final String? activeFilter;
  final bool hideZeroStock;
}
