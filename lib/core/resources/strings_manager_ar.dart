abstract final class StringsManagerAr {
  // Brand & Shell
  static const String logo = 'مزرعة';
  static const String farmWarehouse = 'مستودع المزرعة';
  static const String versionFooter = 'الإصدار 1.0 · موسم 2026';

  // Navigation
  static const String overView = 'نظرة عامة';
  static const String navDashboard = 'لوحة التحكم';
  static const String inBound = 'الوارد';
  static const String newReceipt = 'إيصال جديد';
  static const String inboundLog = 'سجل الوارد';
  static const String outBound = 'الصادر';
  static const String newShipment = 'شحنة جديدة';
  static const String outBoundLog = 'سجل الصادر';

  // Dashboard Screen
  static const String wareHouseOverView = 'نظرة عامة على المستودع';
  static const String dashboardSubtitle = 'موسم 2026 · آخر تحديث اليوم';
  static const String totalInboundValue = 'إجمالي قيمة الوارد';
  static const String totalOutboundValue = 'إجمالي قيمة الصادر';
  static const String cashReceipts = 'إيصالات نقدية';
  static const String netInventoryValue = 'صافي قيمة المخزون';
  static const String recentInbound = 'الوارد الأخير';
  static const String recentOutbound = 'الصادر الأخير';
  static const String viewAll = 'عرض الكل ←';
  static const String plusNew = '+ جديد';

  // Table Columns & Labels
  static const String colId = 'المعرف';
  static const String colDate = 'التاريخ';
  static const String colItem = 'الصنف';
  static const String colCategory = 'التصنيف';
  static const String colType = 'النوع';
  static const String colQuantity = 'الكمية';
  static const String colPriceUnit = 'السعر/الوحدة';
  static const String colUnitPrice = 'سعر الوحدة';
  static const String colTotal = 'الإجمالي';
  static const String colSupplier = 'المورد';
  static const String colPayment = 'طريقة الدفع';
  static const String colProduct = 'المنتج';
  static const String colField = 'الحقل';

  // Inbound Form
  static const String newInboundTitle = 'إيصال توريد جديد';
  static const String newInboundSubtitle = 'تسجيل البضائع الواردة إلى المستودع';
  static const String sectionReceiptDetails = 'تفاصيل الإيصال';
  static const String sectionQuantityPricing = 'الكمية والتسعير';
  static const String sectionSupplierPayment = 'المورد والدفع';
  static const String labelDate = 'التاريخ';
  static const String labelItemName = 'اسم الصنف';
  static const String labelCategory = 'التصنيف';
  static const String labelType = 'النوع';
  static const String labelQuantity = 'الكمية';
  static const String labelUnit = 'الوحدة';
  static const String labelPricePerUnit = 'السعر / الوحدة';
  static const String labelSupplier = 'المورد';
  static const String labelPaymentType = 'طريقة الدفع';
  static const String labelTotal = 'الإجمالي';
  static const String saveReceipt = 'حفظ الإيصال';
  static const String selectDateHint = 'YYYY-MM-DD';
  static const String selectDropdownHint = 'اختر';
  static const String enterItemNameHint = 'مثال: قمح، طماطم';
  static const String enterCategoryHint = 'مثال: حبوب، خضروات';
  static const String enterTypeHint = 'مثال: طازج، جاف، مجمد';
  static const String enterSupplierHint = 'مثال: حصاد سيناء';
  static const String enterQuantityHint = '0';
  static const String enterPriceHint = '0.00';

  // Outbound Form
  static const String newOutboundTitle = 'شحنة صادر جديدة';
  static const String newOutboundSubtitle = 'تسجيل المنتجات الصادرة من المستودع';
  static const String sectionShipmentDetails = 'تفاصيل الشحنة';
  static const String labelProductType = 'المنتج';
  static const String labelField = 'الحقل';
  static const String enterProductHint = 'مثال: طماطم، قمح';
  static const String enterFieldHint = 'مثال: الحقل 51، الحوش الشمالي';
  static const String enterUnitPriceHint = '0.00';
  static const String saveShipment = 'حفظ الشحنة';
  static const String plusNewReceipt = '+ إيصال جديد';
  static const String plusNewShipment = '+ شحنة جديدة';

  // Validations
  static const String dateRequired = 'التاريخ مطلوب';
  static const String itemNameRequired = 'اسم الصنف مطلوب';
  static const String categoryRequired = 'التصنيف مطلوب';
  static const String typeRequired = 'النوع مطلوب';
  static const String quantityRequired = 'الكمية مطلوبة';
  static const String invalidQuantity = 'أدخل كمية صحيحة موجبة';
  static const String unitRequired = 'الوحدة مطلوبة';
  static const String priceRequired = 'السعر مطلوب';
  static const String unitPriceRequired = 'سعر الوحدة مطلوب';
  static const String invalidUnitPrice = 'أدخل سعراً صحيحاً موجباً';
  static const String supplierRequired = 'المورد مطلوب';
  static const String paymentTypeRequired = 'طريقة الدفع مطلوبة';
  static const String productRequired = 'المنتج مطلوب';
  static const String overStockWarning = 'الكمية تتجاوز المخزون المتاح';
  static const String addInboundFirst = 'أضف إيصال وارد أولاً';
  static const String availableStock = 'المتاح:';

  // Logs & Filters
  static const String searchHint = 'بحث في السجلات...';
  static const String filterAll = 'الكل';
  static const String filterCash = 'نقدي';
  static const String filterDeferred = 'آجل';
  static const String filterExport = 'تصدير';
  static const String filterLocal = 'محلي';
  static const String filterWholesale = 'جملة';
  static const String paymentCash = 'نقدي';
  static const String paymentDeferred = 'آجل';
  static const String currencyEgp = 'ج.م';

  // Export to Excel
  static const String exportToExcel = 'تصدير إلى إكسيل';
  static const String exporting = 'جاري التصدير...';
  static const String exportDialogTitle = 'تصدير بيانات المستودع';
  static const String exportDialogSubtitle =
      'اختر النطاق الزمني لتصدير السجلات إلى مصنف إكسيل (.xlsx)';
  static const String allTime = 'كل الأوقات';
  static const String thisMonth = 'هذا الشهر';
  static const String customRange = 'مخصص';
  static const String startDate = 'تاريخ البدء';
  static const String endDate = 'تاريخ الانتهاء';
  static const String exportSaved = 'تم حفظ التصدير بنجاح';
  static const String openFolder = 'فتح المجلد';
  static const String exportCancelled = 'تم إلغاء التصدير';
  static const String exportPermissionError =
      'تعذر حفظ الملف. قد يكون مفتوحاً في برنامج إكسيل أو لا توجد صلاحيات كافية.';
  static const String noDataFound = 'لا توجد سجلات للنطاق الزمني المحدد';
  static const String summarySheetName = 'الملخص';
  static const String inboundSheetName = 'الوارد';
  static const String outboundSheetName = 'الصادر';

  // Navigation
  static const String navInventory = 'المخزون';

  // Inventory
  static const String inventoryTitle = 'المخزون';
  static const String inventorySubtitle =
      'متابعة حية لمستويات المخزون وسجل الحركات';
  static const String tabStockLevels = 'مستويات المخزون';
  static const String tabMovements = 'حركة المخزون';
  static const String colTotalIn = 'إجمالي الوارد';
  static const String colTotalOut = 'إجمالي المنصرف';
  static const String colInStock = 'في المخزن';
  static const String colLastPrice = 'آخر سعر';
  static const String colStockValue = 'قيمة المخزون';
  static const String colMovementType = 'نوع الحركة';
  static const String colRunningBalance = 'الرصيد التراكمي';
  static const String colReference = 'المرجع';
  static const String searchInventoryHint = 'بحث بالمنتج أو النوع أو الوحدة...';
  static const String hideZeroStock = 'إخفاء المخزون الصفري';
  static const String filterAllMovements = 'الكل';
  static const String filterInboundMovement = 'الوارد';
  static const String filterOutboundMovement = 'المنصرف';
  static const String movementInboundBadge = 'وارد';
  static const String movementOutboundBadge = 'منصرف';
  static const String shipmentReference = 'شحنة';
  static const String negativeStockTooltip = 'تم صرف كمية أكبر من الوارد';
  static const String totalStockValueLabel = 'إجمالي قيمة المخزون';
  static const String emptyInventoryPrompt =
      'لا يوجد مخزون حالياً. أضف إيصال وارد أولاً';
  static const String recordsCount = 'سجلات';
  static const String recordSingular = 'سجل';
  static const String recordPlural = 'سجلات';
  static String recordsCountPlural(int count) {
    if (count == 0) return '0 سجل';
    if (count == 1) return 'سجل واحد';
    if (count == 2) return 'سجلان';
    if (count >= 3 && count <= 10) return '$count سجلات';
    return '$count سجلاً';
  }
  static const String stockLevelsSheetName = 'مستويات المخزون';
  static const String movementsSheetName = 'حركة المخزون';
}
