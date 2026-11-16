import 'package:excel/excel.dart';

import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

class ExcelExportInput {
  const ExcelExportInput({
    required this.scope,
    this.inbounds = const [],
    this.outbounds = const [],
    this.stockItems = const [],
    this.movements = const [],
  });

  final ExportScope scope;
  final List<InboundReceiptEntity> inbounds;
  final List<OutboundShipmentEntity> outbounds;
  final List<InventoryItem> stockItems;
  final List<InventoryMovement> movements;
}

List<int> buildExcelWorkbook(ExcelExportInput input) {
  final excel = Excel.createExcel();
  final defaultSheet = excel.getDefaultSheet();

  final headerStyle = CellStyle(
    backgroundColorHex: ExcelColor.fromHexString('#1B4D3E'),
    fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
    bold: true,
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  final totalRowStyle = CellStyle(
    bold: true,
    backgroundColorHex: ExcelColor.fromHexString('#F0F4F2'),
    horizontalAlign: HorizontalAlign.Right,
    verticalAlign: VerticalAlign.Center,
  );

  final boldStyle = CellStyle(bold: true);

  switch (input.scope) {
    case ExportScope.inbound:
      _buildInboundSheet(
        excel: excel,
        inbounds: input.inbounds,
        headerStyle: headerStyle,
        totalRowStyle: totalRowStyle,
        boldStyle: boldStyle,
      );
      if (defaultSheet != null && defaultSheet != 'Inbound') {
        excel.delete(defaultSheet);
      }
      excel.setDefaultSheet('Inbound');

    case ExportScope.outbound:
      _buildOutboundSheet(
        excel: excel,
        outbounds: input.outbounds,
        headerStyle: headerStyle,
        totalRowStyle: totalRowStyle,
        boldStyle: boldStyle,
      );
      if (defaultSheet != null && defaultSheet != 'Outbound') {
        excel.delete(defaultSheet);
      }
      excel.setDefaultSheet('Outbound');

    case ExportScope.inventory:
      _buildStockLevelsSheet(
        excel: excel,
        items: input.stockItems,
        headerStyle: headerStyle,
        totalRowStyle: totalRowStyle,
        boldStyle: boldStyle,
      );
      _buildMovementsSheet(
        excel: excel,
        movements: input.movements,
        headerStyle: headerStyle,
        totalRowStyle: totalRowStyle,
        boldStyle: boldStyle,
      );
      if (defaultSheet != null &&
          defaultSheet != 'Stock Levels' &&
          defaultSheet != 'Movements') {
        excel.delete(defaultSheet);
      }
      excel.setDefaultSheet('Stock Levels');
  }

  final bytes = excel.save();
  return bytes ?? <int>[];
}

void _buildInboundSheet({
  required Excel excel,
  required List<InboundReceiptEntity> inbounds,
  required CellStyle headerStyle,
  required CellStyle totalRowStyle,
  required CellStyle boldStyle,
}) {
  final sheet = excel['Inbound'];
  const inboundHeaders = [
    'Date',
    'Category',
    'Type',
    'Supplier',
    'Quantity',
    'Unit Price',
    'Total',
    'Payment Type',
  ];

  for (var col = 0; col < inboundHeaders.length; col++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
      ..value = TextCellValue(inboundHeaders[col])
      ..cellStyle = headerStyle;
  }

  if (inbounds.isEmpty) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('No inbound records found for the selected range')
      ..cellStyle = boldStyle;
  } else {
    for (var i = 0; i < inbounds.length; i++) {
      final r = inbounds[i];
      final rowIndex = 1 + i;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(r.date);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(r.category);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(r.type);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(r.supplier);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(r.quantity);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = DoubleCellValue(r.pricePerUnit);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(r.total);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue(r.payment);
    }

    // Totals row using real Excel SUM formulas
    final lastDataRowNumber = 1 + inbounds.length; // 1-based row in Excel
    final totalsRowIndex = 1 + inbounds.length;

    for (var col = 0; col < inboundHeaders.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: totalsRowIndex))
          .cellStyle = totalRowStyle;
    }

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: totalsRowIndex))
      ..value = TextCellValue('Total')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 4, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(E2:E$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 6, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(G2:G$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;
  }

  _autoFitColumns(sheet,
      maxCols: inboundHeaders.length, maxRows: inbounds.length + 3);
}

void _buildOutboundSheet({
  required Excel excel,
  required List<OutboundShipmentEntity> outbounds,
  required CellStyle headerStyle,
  required CellStyle totalRowStyle,
  required CellStyle boldStyle,
}) {
  final sheet = excel['Outbound'];
  const outboundHeaders = [
    'Date',
    'Product',
    'Type',
    'Field',
    'Quantity',
    'Unit Price',
    'Total',
    'Payment Type',
  ];

  for (var col = 0; col < outboundHeaders.length; col++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
      ..value = TextCellValue(outboundHeaders[col])
      ..cellStyle = headerStyle;
  }

  if (outbounds.isEmpty) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value =
          TextCellValue('No outbound records found for the selected range')
      ..cellStyle = boldStyle;
  } else {
    for (var i = 0; i < outbounds.length; i++) {
      final s = outbounds[i];
      final rowIndex = 1 + i;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(s.date);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(s.product);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(s.type);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(s.field ?? '-');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(s.quantity);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = DoubleCellValue(s.unitPrice);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(s.total);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue('-');
    }

    // Totals row using real Excel SUM formulas
    final lastDataRowNumber = 1 + outbounds.length;
    final totalsRowIndex = 1 + outbounds.length;

    for (var col = 0; col < outboundHeaders.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: totalsRowIndex))
          .cellStyle = totalRowStyle;
    }

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: totalsRowIndex))
      ..value = TextCellValue('Total')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 4, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(E2:E$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 6, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(G2:G$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;
  }

  _autoFitColumns(sheet,
      maxCols: outboundHeaders.length, maxRows: outbounds.length + 3);
}

void _buildStockLevelsSheet({
  required Excel excel,
  required List<InventoryItem> items,
  required CellStyle headerStyle,
  required CellStyle totalRowStyle,
  required CellStyle boldStyle,
}) {
  final sheet = excel['Stock Levels'];
  const headers = [
    'Product',
    'Type',
    'Unit',
    'Total In',
    'Total Out',
    'In Stock',
    'Last Price',
    'Stock Value',
  ];

  for (var col = 0; col < headers.length; col++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
      ..value = TextCellValue(headers[col])
      ..cellStyle = headerStyle;
  }

  if (items.isEmpty) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('No inventory records found')
      ..cellStyle = boldStyle;
  } else {
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final rowIndex = 1 + i;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(item.product);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(item.type);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(item.unit);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = DoubleCellValue(item.totalIn);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = DoubleCellValue(item.totalOut);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = DoubleCellValue(item.inStock);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(item.lastPrice);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = DoubleCellValue(item.stockValue);
    }

    // Totals row using real Excel SUM formulas
    final lastDataRowNumber = 1 + items.length;
    final totalsRowIndex = 1 + items.length;

    for (var col = 0; col < headers.length; col++) {
      sheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: col, rowIndex: totalsRowIndex))
          .cellStyle = totalRowStyle;
    }

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 0, rowIndex: totalsRowIndex))
      ..value = TextCellValue('Total')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 3, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(D2:D$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 4, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(E2:E$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 5, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(F2:F$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;

    sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 7, rowIndex: totalsRowIndex))
      ..value = FormulaCellValue('SUM(H2:H$lastDataRowNumber)')
      ..cellStyle = totalRowStyle;
  }

  _autoFitColumns(sheet, maxCols: headers.length, maxRows: items.length + 3);
}

void _buildMovementsSheet({
  required Excel excel,
  required List<InventoryMovement> movements,
  required CellStyle headerStyle,
  required CellStyle totalRowStyle,
  required CellStyle boldStyle,
}) {
  final sheet = excel['Movements'];
  const headers = [
    'Date',
    'Movement',
    'Product',
    'Type',
    'Unit',
    'Quantity',
    'Running Balance',
    'Reference',
  ];

  for (var col = 0; col < headers.length; col++) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
      ..value = TextCellValue(headers[col])
      ..cellStyle = headerStyle;
  }

  if (movements.isEmpty) {
    sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
      ..value = TextCellValue('No movement records found')
      ..cellStyle = boldStyle;
  } else {
    for (var i = 0; i < movements.length; i++) {
      final m = movements[i];
      final rowIndex = 1 + i;

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
          .value = TextCellValue(m.date);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
          .value = TextCellValue(
              m.type == MovementType.inbound ? 'Inbound' : 'Outbound');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .value = TextCellValue(m.product);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
          .value = TextCellValue(m.itemType);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
          .value = TextCellValue(m.unit);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
          .value = DoubleCellValue(m.quantity);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .value = DoubleCellValue(m.runningBalance);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
          .value = TextCellValue(m.reference);
    }
  }

  _autoFitColumns(sheet, maxCols: headers.length, maxRows: movements.length + 3);
}

void _autoFitColumns(Sheet sheet,
    {required int maxCols, required int maxRows}) {
  for (var col = 0; col < maxCols; col++) {
    var maxLen = 10;
    for (var row = 0; row < maxRows; row++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
      final val = cell.value;
      if (val != null) {
        final len = val.toString().length;
        if (len > maxLen) {
          maxLen = len;
        }
      }
    }
    final width = (maxLen + 4).clamp(12, 35).toDouble();
    sheet.setColumnWidth(col, width);
  }
}
