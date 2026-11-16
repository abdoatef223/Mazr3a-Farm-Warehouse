import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/helpers/text_normalizer.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/features/export/data/helpers/excel_builder_helper.dart';
import 'package:mazr3a/features/export/data/helpers/file_path_normalizer.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/domain/repo/export_repo.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/repo/inbound_repo.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';
import 'package:mazr3a/features/inventory/domain/repo/inventory_repo.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/repo/outbound_repo.dart';

@Injectable(as: ExportRepo)
class ExportRepoImpl implements ExportRepo {
  const ExportRepoImpl(
    this._inboundRepo,
    this._outboundRepo,
    this._inventoryRepo,
  );

  final InboundRepo _inboundRepo;
  final OutboundRepo _outboundRepo;
  final InventoryRepo _inventoryRepo;

  @override
  FutureApiResult<String> exportToExcel(ExportParams params) async {
    try {
      final now = DateTime.now();
      final dateSuffix = DateFormat('yyyy-MM-dd').format(now);

      final ExcelExportInput input;
      final String defaultFileName;

      switch (params.scope) {
        case ExportScope.inbound:
          final inboundsResult = await _inboundRepo.getInboundLog();
          final List<InboundReceiptEntity> allInbounds;
          switch (inboundsResult) {
            case ApiSuccess(:final data):
              allInbounds = data;
            case ApiError(:final message):
              return ApiError(message: message);
          }

          final filteredInbounds = _filterInbounds(
            allInbounds,
            dateFrom: params.dateFrom,
            dateTo: params.dateTo,
            filter: params.activeFilter,
            search: params.searchQuery,
          );

          defaultFileName = 'mazr3a-inbound-$dateSuffix.xlsx';
          input = ExcelExportInput(
            scope: ExportScope.inbound,
            inbounds: filteredInbounds,
          );

        case ExportScope.outbound:
          final outboundsResult = await _outboundRepo.getOutboundLog();
          final List<OutboundShipmentEntity> allOutbounds;
          switch (outboundsResult) {
            case ApiSuccess(:final data):
              allOutbounds = data;
            case ApiError(:final message):
              return ApiError(message: message);
          }

          final filteredOutbounds = _filterOutbounds(
            allOutbounds,
            dateFrom: params.dateFrom,
            dateTo: params.dateTo,
            filter: params.activeFilter,
            search: params.searchQuery,
          );

          defaultFileName = 'mazr3a-outbound-$dateSuffix.xlsx';
          input = ExcelExportInput(
            scope: ExportScope.outbound,
            outbounds: filteredOutbounds,
          );

        case ExportScope.inventory:
          final levelsResult = await _inventoryRepo.getInventoryLevels();
          final List<InventoryItem> allLevels;
          switch (levelsResult) {
            case ApiSuccess(:final data):
              allLevels = data;
            case ApiError(:final message):
              return ApiError(message: message);
          }

          final movementsResult = await _inventoryRepo.getInventoryMovements();
          final List<InventoryMovement> allMovements;
          switch (movementsResult) {
            case ApiSuccess(:final data):
              allMovements = data;
            case ApiError(:final message):
              return ApiError(message: message);
          }

          var filteredLevels = allLevels;
          if (params.hideZeroStock) {
            filteredLevels =
                filteredLevels.where((i) => i.inStock != 0).toList();
          }
          if (params.searchQuery != null &&
              params.searchQuery!.trim().isNotEmpty) {
            final q = normalizeText(params.searchQuery!);
            filteredLevels = filteredLevels.where((i) {
              return i.normalizedKey.contains(q) ||
                  normalizeText(i.product).contains(q) ||
                  normalizeText(i.type).contains(q) ||
                  normalizeText(i.unit).contains(q);
            }).toList();
          }

          var filteredMovements = allMovements;
          if (params.activeFilter != null && params.activeFilter != 'All') {
            if (params.activeFilter == 'Inbound') {
              filteredMovements = filteredMovements
                  .where((m) => m.type == MovementType.inbound)
                  .toList();
            } else if (params.activeFilter == 'Outbound') {
              filteredMovements = filteredMovements
                  .where((m) => m.type == MovementType.outbound)
                  .toList();
            }
          }
          if (params.dateFrom != null) {
            final fromStr = DateFormat('yyyy-MM-dd').format(params.dateFrom!);
            filteredMovements = filteredMovements
                .where((m) => m.date.compareTo(fromStr) >= 0)
                .toList();
          }
          if (params.dateTo != null) {
            final toStr = DateFormat('yyyy-MM-dd').format(params.dateTo!);
            filteredMovements = filteredMovements
                .where((m) => m.date.compareTo(toStr) <= 0)
                .toList();
          }
          if (params.searchQuery != null &&
              params.searchQuery!.trim().isNotEmpty) {
            final q = normalizeText(params.searchQuery!);
            filteredMovements = filteredMovements.where((m) {
              return m.normalizedKey.contains(q) ||
                  normalizeText(m.product).contains(q) ||
                  normalizeText(m.itemType).contains(q) ||
                  normalizeText(m.unit).contains(q) ||
                  normalizeText(m.reference).contains(q);
            }).toList();
          }

          defaultFileName = 'mazr3a-inventory-$dateSuffix.xlsx';
          input = ExcelExportInput(
            scope: ExportScope.inventory,
            stockItems: filteredLevels,
            movements: filteredMovements,
          );
      }

      final saveLocation = await getSaveLocation(
        suggestedName: defaultFileName,
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Excel Workbook',
            extensions: ['xlsx'],
            mimeTypes: [
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
            ],
          ),
        ],
      );

      if (saveLocation == null) {
        return const ApiError(message: StringsManager.exportCancelled);
      }

      // Normalize user picked path (sanitize Windows characters, enforce .xlsx)
      final normalizedPath = normalizeExcelFilePath(
        saveLocation.path,
        defaultBaseName: defaultFileName.replaceAll('.xlsx', ''),
      );

      final bytes = await compute(buildExcelWorkbook, input);

      final file = File(normalizedPath);
      await file.writeAsBytes(bytes, flush: true);

      if (!await file.exists()) {
        return const ApiError(message: 'Failed to verify saved file.');
      }

      return ApiSuccess(data: normalizedPath);
    } on FileSystemException {
      return const ApiError(message: StringsManager.exportPermissionError);
    } on Exception catch (e) {
      return ApiError(message: e.toString());
    }
  }

  List<InboundReceiptEntity> _filterInbounds(
    List<InboundReceiptEntity> list, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? filter,
    String? search,
  }) {
    var filtered = list
        .where((i) => _isWithinRange(i.date, dateFrom, dateTo))
        .toList();

    if (filter != null && filter != 'All') {
      if (filter.toLowerCase() == 'cash') {
        filtered = filtered
            .where((item) => item.payment.toLowerCase() == 'cash')
            .toList();
      } else if (filter.toLowerCase() == 'deferred') {
        filtered = filtered
            .where((item) => item.payment.toLowerCase() == 'deferred')
            .toList();
      }
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.item.toLowerCase().contains(query) ||
            item.supplier.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.type.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) {
      final d = b.date.compareTo(a.date);
      return d != 0 ? d : b.id.compareTo(a.id);
    });

    return filtered;
  }

  List<OutboundShipmentEntity> _filterOutbounds(
    List<OutboundShipmentEntity> list, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? filter,
    String? search,
  }) {
    var filtered = list
        .where((o) => _isWithinRange(o.date, dateFrom, dateTo))
        .toList();

    if (filter != null && filter != 'All') {
      filtered = filtered
          .where((item) => item.type.toLowerCase() == filter.toLowerCase())
          .toList();
    }

    if (search != null && search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      filtered = filtered.where((item) {
        return item.product.toLowerCase().contains(query) ||
            item.type.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      }).toList();
    }

    filtered.sort((a, b) {
      final d = b.date.compareTo(a.date);
      return d != 0 ? d : b.id.compareTo(a.id);
    });

    return filtered;
  }

  bool _isWithinRange(String dateStr, DateTime? from, DateTime? to) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return true;

    if (from != null) {
      final fromDate = DateTime(from.year, from.month, from.day);
      if (dt.isBefore(fromDate)) return false;
    }

    if (to != null) {
      final toDate = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
      if (dt.isAfter(toDate)) return false;
    }

    return true;
  }
}
