import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/export/data/helpers/excel_builder_helper.dart';
import 'package:mazr3a/features/export/data/helpers/file_path_normalizer.dart';
import 'package:mazr3a/features/export/domain/model/export_params.dart';
import 'package:mazr3a/features/export/domain/model/export_scope.dart';
import 'package:mazr3a/features/export/domain/repo/export_repo.dart';
import 'package:mazr3a/features/export/domain/use_cases/export_to_excel_use_case.dart';
import 'package:mazr3a/features/export/presentation/view_model/export_cubit.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';

class _FakeExportRepo implements ExportRepo {
  _FakeExportRepo({this.filePath = 'C:/exports/mazr3a-inbound.xlsx', this.error});

  final String filePath;
  final String? error;

  @override
  FutureApiResult<String> exportToExcel(ExportParams params) async {
    await Future<void>.delayed(Duration.zero);
    if (error != null) {
      return ApiError(message: error!);
    }
    return ApiSuccess(data: filePath);
  }
}

double _numVal(CellValue? cell) {
  if (cell is DoubleCellValue) return cell.value;
  if (cell is IntCellValue) return cell.value.toDouble();
  if (cell != null) return double.parse(cell.toString());
  return 0.0;
}

void main() {
  group('Excel Workbook Builder - Scope-based generation', () {
    test('Inbound only scope generates workbook with ONLY Inbound sheet', () {
      final inbounds = [
        const InboundReceiptEntity(
          id: 'rec-1',
          date: '2026-10-09',
          item: 'NPK Fertilizer',
          category: 'Fertilizers',
          type: 'NPK 20-20-20',
          supplier: 'AgriCorp',
          quantity: 50.0,
          unit: 'Bag',
          pricePerUnit: 120.0,
          total: 6000.0,
          payment: 'Cash',
        ),
      ];

      final input = ExcelExportInput(
        scope: ExportScope.inbound,
        inbounds: inbounds,
      );

      final bytes = buildExcelWorkbook(input);
      expect(bytes, isNotEmpty);

      final excel = Excel.decodeBytes(bytes);

      // Verify ONLY Inbound sheet exists, NO Summary, NO Outbound
      expect(excel.tables.keys, contains('Inbound'));
      expect(excel.tables.keys, isNot(contains('Summary')));
      expect(excel.tables.keys, isNot(contains('Outbound')));

      final sheet = excel.tables['Inbound']!;
      // Header row
      expect(sheet.rows[0].map((c) => c?.value.toString()).toList(), [
        'Date',
        'Category',
        'Type',
        'Supplier',
        'Quantity',
        'Unit Price',
        'Total',
        'Payment Type',
      ]);

      // Data row
      expect(sheet.rows[1][0]?.value.toString(), equals('2026-10-09'));
      expect(sheet.rows[1][1]?.value.toString(), equals('Fertilizers'));
      expect(sheet.rows[1][2]?.value.toString(), equals('NPK 20-20-20'));
      expect(sheet.rows[1][3]?.value.toString(), equals('AgriCorp'));
      expect(_numVal(sheet.rows[1][4]?.value), equals(50.0));
      expect(_numVal(sheet.rows[1][5]?.value), equals(120.0));
      expect(_numVal(sheet.rows[1][6]?.value), equals(6000.0));
      expect(sheet.rows[1][7]?.value.toString(), equals('Cash'));

      // Totals row with SUM formula
      expect(sheet.rows[2][0]?.value.toString(), equals('Total'));
      expect((sheet.rows[2][4]?.value as FormulaCellValue).formula,
          equals('SUM(E2:E2)'));
      expect((sheet.rows[2][6]?.value as FormulaCellValue).formula,
          equals('SUM(G2:G2)'));
    });

    test('Outbound only scope generates workbook with ONLY Outbound sheet', () {
      final outbounds = [
        const OutboundShipmentEntity(
          id: 'ship-1',
          date: '2026-10-09',
          product: 'Wheat',
          type: 'Giza 171',
          field: 'North Lot',
          quantity: 80.0,
          unit: 'Kg',
          unitPrice: 50.0,
          total: 4000.0,
        ),
      ];

      final input = ExcelExportInput(
        scope: ExportScope.outbound,
        outbounds: outbounds,
      );

      final bytes = buildExcelWorkbook(input);
      expect(bytes, isNotEmpty);

      final excel = Excel.decodeBytes(bytes);

      // Verify ONLY Outbound sheet exists, NO Summary, NO Inbound
      expect(excel.tables.keys, contains('Outbound'));
      expect(excel.tables.keys, isNot(contains('Summary')));
      expect(excel.tables.keys, isNot(contains('Inbound')));

      final sheet = excel.tables['Outbound']!;
      // Header row
      expect(sheet.rows[0].map((c) => c?.value.toString()).toList(), [
        'Date',
        'Product',
        'Type',
        'Field',
        'Quantity',
        'Unit Price',
        'Total',
        'Payment Type',
      ]);

      // Data row
      expect(sheet.rows[1][0]?.value.toString(), equals('2026-10-09'));
      expect(sheet.rows[1][1]?.value.toString(), equals('Wheat'));
      expect(sheet.rows[1][2]?.value.toString(), equals('Giza 171'));
      expect(sheet.rows[1][3]?.value.toString(), equals('North Lot'));
      expect(_numVal(sheet.rows[1][4]?.value), equals(80.0));
      expect(_numVal(sheet.rows[1][5]?.value), equals(50.0));
      expect(_numVal(sheet.rows[1][6]?.value), equals(4000.0));
      expect(sheet.rows[1][7]?.value.toString(), equals('-'));

      // Totals row with SUM formula
      expect(sheet.rows[2][0]?.value.toString(), equals('Total'));
      expect((sheet.rows[2][4]?.value as FormulaCellValue).formula,
          equals('SUM(E2:E2)'));
      expect((sheet.rows[2][6]?.value as FormulaCellValue).formula,
          equals('SUM(G2:G2)'));
    });

    test('Empty list exports headers and empty note row without data rows', () {
      // Inbound empty
      const inInput = ExcelExportInput(
        scope: ExportScope.inbound,
        inbounds: [],
      );
      final inExcel = Excel.decodeBytes(buildExcelWorkbook(inInput));
      expect(inExcel.tables.keys, contains('Inbound'));
      final inSheet = inExcel.tables['Inbound']!;
      expect(inSheet.rows[1][0]?.value.toString(),
          equals('No inbound records found for the selected range'));

      // Outbound empty
      const outInput = ExcelExportInput(
        scope: ExportScope.outbound,
        outbounds: [],
      );
      final outExcel = Excel.decodeBytes(buildExcelWorkbook(outInput));
      expect(outExcel.tables.keys, contains('Outbound'));
      final outSheet = outExcel.tables['Outbound']!;
      expect(outSheet.rows[1][0]?.value.toString(),
          equals('No outbound records found for the selected range'));
    });

    test('Arabic text is preserved in UTF-8 in scope export', () {
      final inbounds = [
        const InboundReceiptEntity(
          id: 'rec-ar-1',
          date: '2026-10-09',
          item: 'سماد نترات نشادر',
          category: 'أسمدة ومخصبات',
          type: 'سماد نترات نشادر',
          supplier: 'شركة النيل للتوريدات الزراعية',
          quantity: 25.0,
          unit: 'شيكارة',
          pricePerUnit: 350.5,
          total: 8762.5,
          payment: 'نقدي',
        ),
      ];

      final input = ExcelExportInput(
        scope: ExportScope.inbound,
        inbounds: inbounds,
      );

      final bytes = buildExcelWorkbook(input);
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables['Inbound']!;

      expect(sheet.rows[1][1]?.value.toString(), equals('أسمدة ومخصبات'));
      expect(sheet.rows[1][2]?.value.toString(), equals('سماد نترات نشادر'));
      expect(sheet.rows[1][3]?.value.toString(),
          equals('شركة النيل للتوريدات الزراعية'));
      expect(sheet.rows[1][7]?.value.toString(), equals('نقدي'));
    });
  });

  group('File Name Normalization', () {
    test('normalizes name without extension', () {
      expect(normalizeExcelFilePath('name'), equals('name.xlsx'));
      expect(normalizeExcelFilePath(r'C:\Users\Reports\name'),
          equals(r'C:\Users\Reports\name.xlsx'));
    });

    test('normalizes name with .xlsx and preserves .xlsx', () {
      expect(normalizeExcelFilePath('name.xlsx'), equals('name.xlsx'));
    });

    test('normalizes case-insensitive .XLSX to lowercase .xlsx', () {
      expect(normalizeExcelFilePath('name.XLSX'), equals('name.xlsx'));
      expect(normalizeExcelFilePath('report.Xlsx'), equals('report.xlsx'));
    });

    test('replaces other extensions like .xls and .txt with .xlsx', () {
      expect(normalizeExcelFilePath('name.xls'), equals('name.xlsx'));
      expect(normalizeExcelFilePath('name.txt'), equals('name.xlsx'));
      expect(normalizeExcelFilePath('report.csv'), equals('report.xlsx'));
    });

    test('normalizes trailing dot "name."', () {
      expect(normalizeExcelFilePath('name.'), equals('name.xlsx'));
      expect(normalizeExcelFilePath('name...'), equals('name.xlsx'));
    });

    test('sanitizes invalid Windows file name characters (< > : " / \\ | ? *)', () {
      expect(
        normalizeExcelFilePath('name with invalid < > : " / \\ | ? *'),
        equals('name with invalid _ _ _ _ _ _ _ _ _.xlsx'),
      );
    });

    test('handles path with directories correctly', () {
      expect(
        normalizeExcelFilePath(r'C:\Mazr3a\Exports\my:report?.xls'),
        equals(r'C:\Mazr3a\Exports\my_report_.xlsx'),
      );
    });
  });

  group('Date Range Filtering Logic', () {
    bool isWithinRange(String dateStr, DateTime? from, DateTime? to) {
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

    test('correctly filters records within date range', () {
      final from = DateTime(2026, 10, 5);
      final to = DateTime(2026, 10, 9);

      expect(isWithinRange('2026-10-04', from, to), isFalse);
      expect(isWithinRange('2026-10-05', from, to), isTrue);
      expect(isWithinRange('2026-10-07', from, to), isTrue);
      expect(isWithinRange('2026-10-09', from, to), isTrue);
      expect(isWithinRange('2026-10-10', from, to), isFalse);
    });

    test('open-ended date ranges include matching records', () {
      final from = DateTime(2026, 10, 5);
      expect(isWithinRange('2026-10-04', from, null), isFalse);
      expect(isWithinRange('2026-10-10', from, null), isTrue);

      final to = DateTime(2026, 10, 9);
      expect(isWithinRange('2026-10-01', null, to), isTrue);
      expect(isWithinRange('2026-10-10', null, to), isFalse);
    });
  });

  group('ExportToExcelUseCase & ExportCubit', () {
    test('UseCase delegates with scope to ExportRepo', () async {
      final fakeRepo = _FakeExportRepo(filePath: 'C:/exports/test.xlsx');
      final useCase = ExportToExcelUseCase(fakeRepo);

      final result =
          await useCase(const ExportParams(scope: ExportScope.inbound));
      expect(result, isA<ApiSuccess<String>>());
      expect((result as ApiSuccess<String>).data, equals('C:/exports/test.xlsx'));
    });

    test('ExportCubit emits ExportLoading then ExportSuccess on successful export',
        () async {
      final fakeRepo = _FakeExportRepo(filePath: 'C:/exports/test.xlsx');
      final useCase = ExportToExcelUseCase(fakeRepo);
      final cubit = ExportCubit(useCase);

      expect(cubit.state, isA<ExportIdle>());

      final future = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ExportLoading>(),
          isA<ExportSuccess>()
              .having((s) => s.filePath, 'filePath', 'C:/exports/test.xlsx'),
        ]),
      );

      await cubit.export(scope: ExportScope.inbound);
      await future;

      cubit.reset();
      expect(cubit.state, isA<ExportIdle>());
    });

    test('ExportCubit emits ExportLoading then ExportError on failure', () async {
      final fakeRepo = _FakeExportRepo(error: 'File is locked by Excel');
      final useCase = ExportToExcelUseCase(fakeRepo);
      final cubit = ExportCubit(useCase);

      final future = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<ExportLoading>(),
          isA<ExportError>()
              .having((s) => s.message, 'message', 'File is locked by Excel'),
        ]),
      );

      await cubit.export(scope: ExportScope.outbound);
      await future;
    });
  });
}
