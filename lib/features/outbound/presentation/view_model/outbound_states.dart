part of 'outbound_cubit.dart';

sealed class OutboundStates {
  const OutboundStates({
    this.deletingId,
    this.liveTotal = 0.0,
    this.options = const [],
    this.selectedProduct,
    this.selectedType,
    this.unit,
    this.unitPrice,
    this.availableQuantity,
    this.quantityWarning,
  });

  final String? deletingId;
  final double liveTotal;
  final List<InboundProductOptionEntity> options;
  final String? selectedProduct;
  final String? selectedType;
  final String? unit;
  final double? unitPrice;
  final double? availableQuantity;
  final String? quantityWarning;

  OutboundStates copyWith({
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  });
}

class OutboundInit extends OutboundStates {
  const OutboundInit({
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  @override
  OutboundInit copyWith({
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundInit(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundLoading extends OutboundStates {
  const OutboundLoading({
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  @override
  OutboundLoading copyWith({
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundLoading(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundLoaded extends OutboundStates {
  const OutboundLoaded({
    required this.allShipments,
    required this.filteredShipments,
    this.activeFilter = 'All',
    this.searchQuery = '',
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  final List<OutboundShipmentEntity> allShipments;
  final List<OutboundShipmentEntity> filteredShipments;
  final String activeFilter;
  final String searchQuery;

  double get totalValue =>
      filteredShipments.fold(0, (sum, item) => sum + item.total);

  @override
  OutboundLoaded copyWith({
    List<OutboundShipmentEntity>? allShipments,
    List<OutboundShipmentEntity>? filteredShipments,
    String? activeFilter,
    String? searchQuery,
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundLoaded(
        allShipments: allShipments ?? this.allShipments,
        filteredShipments: filteredShipments ?? this.filteredShipments,
        activeFilter: activeFilter ?? this.activeFilter,
        searchQuery: searchQuery ?? this.searchQuery,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundSubmitting extends OutboundStates {
  const OutboundSubmitting({
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  @override
  OutboundSubmitting copyWith({
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundSubmitting(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundSubmitSuccess extends OutboundStates {
  const OutboundSubmitSuccess({
    required this.shipment,
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  final OutboundShipmentEntity shipment;

  @override
  OutboundSubmitSuccess copyWith({
    OutboundShipmentEntity? shipment,
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundSubmitSuccess(
        shipment: shipment ?? this.shipment,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundDeleteSuccess extends OutboundStates {
  const OutboundDeleteSuccess({
    required this.message,
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  final String message;

  @override
  OutboundDeleteSuccess copyWith({
    String? message,
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundDeleteSuccess(
        message: message ?? this.message,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}

class OutboundError extends OutboundStates {
  const OutboundError({
    required this.message,
    super.deletingId,
    super.liveTotal,
    super.options,
    super.selectedProduct,
    super.selectedType,
    super.unit,
    super.unitPrice,
    super.availableQuantity,
    super.quantityWarning,
  });

  final String message;

  @override
  OutboundError copyWith({
    String? message,
    String? deletingId,
    double? liveTotal,
    List<InboundProductOptionEntity>? options,
    String? selectedProduct,
    String? selectedType,
    String? unit,
    double? unitPrice,
    double? availableQuantity,
    String? quantityWarning,
    bool clearProduct = false,
    bool clearType = false,
    bool clearUnit = false,
    bool clearUnitPrice = false,
    bool clearAvailableQuantity = false,
    bool clearQuantityWarning = false,
  }) =>
      OutboundError(
        message: message ?? this.message,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
        options: options ?? this.options,
        selectedProduct:
            clearProduct ? null : (selectedProduct ?? this.selectedProduct),
        selectedType: clearType ? null : (selectedType ?? this.selectedType),
        unit: clearUnit ? null : (unit ?? this.unit),
        unitPrice: clearUnitPrice ? null : (unitPrice ?? this.unitPrice),
        availableQuantity: clearAvailableQuantity
            ? null
            : (availableQuantity ?? this.availableQuantity),
        quantityWarning: clearQuantityWarning
            ? null
            : (quantityWarning ?? this.quantityWarning),
      );
}
