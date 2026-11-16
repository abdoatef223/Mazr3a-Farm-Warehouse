abstract final class StringsManager {
  // Brand & Shell
  static const String logo = 'Mazr3a';
  static const String farmWarehouse = 'Farm Warehouse';
  static const String versionFooter = 'v1.0 · Season 2026';

  // Navigation
  static const String overView = 'OVERVIEW';
  static const String navDashboard = 'Dashboard';
  static const String inBound = 'INBOUND';
  static const String newReceipt = 'New Receipt';
  static const String inboundLog = 'Inbound Log';
  static const String outBound = 'OUTBOUND';
  static const String newShipment = 'New Shipment';
  static const String outBoundLog = 'Outbound Log';

  // Dashboard Screen
  static const String wareHouseOverView = 'Warehouse Overview';
  static const String dashboardSubtitle = 'Season 2026 · Last updated today';
  static const String totalInboundValue = 'Total Inbound Value';
  static const String totalInboundDetail = '4 receipts';
  static const String totalOutboundValue = 'Total Outbound Value';
  static const String totalOutboundDetail = '3 shipments';
  static const String cashReceipts = 'Cash Receipts';
  static const String cashReceiptsDetail = '2 deferred';
  static const String netInventoryValue = 'Net Inventory Value';
  static const String netInventoryDetail = 'inbound − outbound';
  static const String recentInbound = 'Recent Inbound';
  static const String recentOutbound = 'Recent Outbound';
  static const String viewAll = 'View all →';
  static const String plusNew = '+ New';

  // Table Columns
  static const String colId = 'ID';
  static const String colDate = 'Date';
  static const String colItem = 'Item';
  static const String colCategory = 'Category';
  static const String colType = 'Type';
  static const String colQuantity = 'Quantity';
  static const String colPriceUnit = 'Price/Unit';
  static const String colUnitPrice = 'Unit Price';
  static const String colTotal = 'Total';
  static const String colSupplier = 'Supplier';
  static const String colPayment = 'Payment';
  static const String colProduct = 'Product';
  static const String colField = 'Field';

  // Inbound Form
  static const String newInboundTitle = 'New Inbound Receipt';
  static const String newInboundSubtitle = 'Record incoming goods to the warehouse';
  static const String sectionReceiptDetails = 'RECEIPT DETAILS';
  static const String sectionQuantityPricing = 'QUANTITY & PRICING';
  static const String sectionSupplierPayment = 'SUPPLIER & PAYMENT';
  static const String labelDate = 'Date';
  static const String labelItemName = 'Item Name';
  static const String labelCategory = 'Category';
  static const String labelType = 'Type';
  static const String labelQuantity = 'Quantity';
  static const String labelUnit = 'Unit';
  static const String labelPricePerUnit = 'Price / Unit';
  static const String labelSupplier = 'Supplier';
  static const String labelPaymentType = 'Payment Type';
  static const String labelTotal = 'Total';
  static const String saveReceipt = 'Save Receipt';
  static const String selectDateHint = 'YYYY-MM-DD';
  static const String selectDropdownHint = 'Select';
  static const String enterItemNameHint = 'e.g. Wheat, Tomatoes';
  static const String enterCategoryHint = 'e.g. Grains, Vegetables';
  static const String enterTypeHint = 'e.g. Fresh, Dry, Frozen';
  static const String enterSupplierHint = 'e.g. Sinai Harvest';
  static const String enterQuantityHint = '0';
  static const String enterPriceHint = '0.00';

  // Outbound Form
  static const String newOutboundTitle = 'New Outbound Shipment';
  static const String newOutboundSubtitle = 'Record outgoing products from warehouse';
  static const String sectionShipmentDetails = 'SHIPMENT DETAILS';
  static const String labelProductType = 'Product';
  static const String labelField = 'Field';
  static const String enterProductHint = 'e.g. Tomato, Wheat';
  static const String enterFieldHint = 'e.g. Area 51, North Lot';
  static const String enterUnitPriceHint = '0.00';
  static const String selectProductToSeePrice = 'Select a product to see price';
  static const String saveShipment = 'Save Shipment';
  static const String plusNewReceipt = '+ New Receipt';
  static const String plusNewShipment = '+ New Shipment';

  // Validations
  static const String dateRequired = 'Date is required';
  static const String itemNameRequired = 'Item name is required';
  static const String categoryRequired = 'Category is required';
  static const String typeRequired = 'Type is required';
  static const String quantityRequired = 'Quantity is required';
  static const String invalidQuantity = 'Enter valid positive quantity';
  static const String unitRequired = 'Unit is required';
  static const String priceRequired = 'Price is required';
  static const String unitPriceRequired = 'Unit price is required';
  static const String invalidUnitPrice = 'Enter valid positive price';
  static const String supplierRequired = 'Supplier is required';
  static const String paymentTypeRequired = 'Payment type is required';
  static const String productRequired = 'Product is required';
  static const String overStockWarning = 'Quantity exceeds available stock';
  static const String addInboundFirst = 'Add an inbound receipt first';
  static const String availableStock = 'Available:';

  // Logs & Filters
  static const String searchHint = 'Search records...';
  static const String filterAll = 'All';
  static const String filterCash = 'Cash';
  static const String filterDeferred = 'Deferred';
  static const String filterExport = 'Export';
  static const String filterLocal = 'Local';
  static const String filterWholesale = 'Wholesale';
  static const String paymentCash = 'cash';
  static const String paymentDeferred = 'deferred';
  static const String currencyEgp = 'EGP';

  // Export to Excel
  static const String exportToExcel = 'Export to Excel';
  static const String exporting = 'Exporting...';
  static const String exportDialogTitle = 'Export Warehouse Data';
  static const String exportDialogSubtitle =
      'Select date range to export records to an Excel workbook (.xlsx)';
  static const String allTime = 'All time';
  static const String thisMonth = 'This month';
  static const String customRange = 'Custom';
  static const String startDate = 'Start Date';
  static const String endDate = 'End Date';
  static const String exportSaved = 'Export saved successfully';
  static const String openFolder = 'Open folder';
  static const String exportCancelled = 'Export cancelled';
  static const String exportPermissionError =
      'Cannot save file. It may be currently open in Excel or access is denied.';
  static const String noDataFound = 'No records found for the selected range';
  static const String summarySheetName = 'Summary';
  static const String inboundSheetName = 'Inbound';
  static const String outboundSheetName = 'Outbound';

  // Inventory
  static const String navInventory = 'Inventory';
  static const String inventoryTitle = 'Inventory';
  static const String inventorySubtitle =
      'Real-time stock levels & warehouse ledger movements';
  static const String tabStockLevels = 'Stock Levels';
  static const String tabMovements = 'Movements';
  static const String colTotalIn = 'Total In';
  static const String colTotalOut = 'Total Out';
  static const String colInStock = 'In Stock';
  static const String colLastPrice = 'Last Price';
  static const String colStockValue = 'Stock Value';
  static const String colMovementType = 'Movement';
  static const String colRunningBalance = 'Running Balance';
  static const String colReference = 'Reference';
  static const String searchInventoryHint = 'Search product, type or unit...';
  static const String hideZeroStock = 'Hide zero stock';
  static const String filterAllMovements = 'All';
  static const String filterInboundMovement = 'Inbound';
  static const String filterOutboundMovement = 'Outbound';
  static const String movementInboundBadge = 'Inbound';
  static const String movementOutboundBadge = 'Outbound';
  static const String shipmentReference = 'Shipment';
  static const String negativeStockTooltip = 'More was shipped than received';
  static const String totalStockValueLabel = 'Total Stock Value';
  static const String emptyInventoryPrompt =
      'No inventory yet. Add an inbound receipt first';
  static const String recordsCount = 'records';
  static const String recordSingular = 'record';
  static const String recordPlural = 'records';
  static String recordsCountPlural(int count) =>
      count == 1 ? '1 record' : '$count records';
  static const String stockLevelsSheetName = 'Stock Levels';
  static const String movementsSheetName = 'Movements';
}
