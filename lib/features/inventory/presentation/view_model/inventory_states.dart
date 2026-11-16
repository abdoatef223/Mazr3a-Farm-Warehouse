part of 'inventory_cubit.dart';

sealed class InventoryStates {
  const InventoryStates({
    this.selectedTab = 0,
    this.stockSearchQuery = '',
    this.hideZeroStock = false,
    this.sortColumn = 'product',
    this.sortAscending = true,
    this.movementSearchQuery = '',
    this.movementTypeFilter = 'All',
    this.movementDateFrom,
    this.movementDateTo,
    this.movementsPage = 1,
  });

  final int selectedTab;
  final String stockSearchQuery;
  final bool hideZeroStock;
  final String sortColumn;
  final bool sortAscending;

  final String movementSearchQuery;
  final String movementTypeFilter;
  final DateTime? movementDateFrom;
  final DateTime? movementDateTo;
  final int movementsPage;

  InventoryStates copyWith({
    int? selectedTab,
    String? stockSearchQuery,
    bool? hideZeroStock,
    String? sortColumn,
    bool? sortAscending,
    String? movementSearchQuery,
    String? movementTypeFilter,
    DateTime? movementDateFrom,
    DateTime? movementDateTo,
    bool clearDateRange,
    int? movementsPage,
  });
}

class InventoryInit extends InventoryStates {
  const InventoryInit({
    super.selectedTab,
    super.stockSearchQuery,
    super.hideZeroStock,
    super.sortColumn,
    super.sortAscending,
    super.movementSearchQuery,
    super.movementTypeFilter,
    super.movementDateFrom,
    super.movementDateTo,
    super.movementsPage,
  });

  @override
  InventoryInit copyWith({
    int? selectedTab,
    String? stockSearchQuery,
    bool? hideZeroStock,
    String? sortColumn,
    bool? sortAscending,
    String? movementSearchQuery,
    String? movementTypeFilter,
    DateTime? movementDateFrom,
    DateTime? movementDateTo,
    bool clearDateRange = false,
    int? movementsPage,
  }) =>
      InventoryInit(
        selectedTab: selectedTab ?? this.selectedTab,
        stockSearchQuery: stockSearchQuery ?? this.stockSearchQuery,
        hideZeroStock: hideZeroStock ?? this.hideZeroStock,
        sortColumn: sortColumn ?? this.sortColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        movementSearchQuery: movementSearchQuery ?? this.movementSearchQuery,
        movementTypeFilter: movementTypeFilter ?? this.movementTypeFilter,
        movementDateFrom:
            clearDateRange ? null : (movementDateFrom ?? this.movementDateFrom),
        movementDateTo:
            clearDateRange ? null : (movementDateTo ?? this.movementDateTo),
        movementsPage: movementsPage ?? this.movementsPage,
      );
}

class InventoryLoading extends InventoryStates {
  const InventoryLoading({
    super.selectedTab,
    super.stockSearchQuery,
    super.hideZeroStock,
    super.sortColumn,
    super.sortAscending,
    super.movementSearchQuery,
    super.movementTypeFilter,
    super.movementDateFrom,
    super.movementDateTo,
    super.movementsPage,
  });

  @override
  InventoryLoading copyWith({
    int? selectedTab,
    String? stockSearchQuery,
    bool? hideZeroStock,
    String? sortColumn,
    bool? sortAscending,
    String? movementSearchQuery,
    String? movementTypeFilter,
    DateTime? movementDateFrom,
    DateTime? movementDateTo,
    bool clearDateRange = false,
    int? movementsPage,
  }) =>
      InventoryLoading(
        selectedTab: selectedTab ?? this.selectedTab,
        stockSearchQuery: stockSearchQuery ?? this.stockSearchQuery,
        hideZeroStock: hideZeroStock ?? this.hideZeroStock,
        sortColumn: sortColumn ?? this.sortColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        movementSearchQuery: movementSearchQuery ?? this.movementSearchQuery,
        movementTypeFilter: movementTypeFilter ?? this.movementTypeFilter,
        movementDateFrom:
            clearDateRange ? null : (movementDateFrom ?? this.movementDateFrom),
        movementDateTo:
            clearDateRange ? null : (movementDateTo ?? this.movementDateTo),
        movementsPage: movementsPage ?? this.movementsPage,
      );
}

class InventoryLoaded extends InventoryStates {
  const InventoryLoaded({
    required this.allStockItems,
    required this.filteredStockItems,
    required this.allMovements,
    required this.filteredMovements,
    super.selectedTab,
    super.stockSearchQuery,
    super.hideZeroStock,
    super.sortColumn,
    super.sortAscending,
    super.movementSearchQuery,
    super.movementTypeFilter,
    super.movementDateFrom,
    super.movementDateTo,
    super.movementsPage,
  });

  final List<InventoryItem> allStockItems;
  final List<InventoryItem> filteredStockItems;
  final List<InventoryMovement> allMovements;
  final List<InventoryMovement> filteredMovements;

  double get totalStockValue => filteredStockItems.fold<double>(
        0.0,
        (sum, item) => sum + item.stockValue,
      );

  bool get isEmptyWarehouse => allStockItems.isEmpty && allMovements.isEmpty;

  static const int pageSize = 50;

  int get totalMovementPages {
    if (filteredMovements.isEmpty) return 1;
    return (filteredMovements.length / pageSize).ceil();
  }

  List<InventoryMovement> get pagedMovements {
    final start = (movementsPage - 1) * pageSize;
    if (start >= filteredMovements.length) return const [];
    final end = (start + pageSize) < filteredMovements.length
        ? (start + pageSize)
        : filteredMovements.length;
    return filteredMovements.sublist(start, end);
  }

  @override
  InventoryLoaded copyWith({
    List<InventoryItem>? allStockItems,
    List<InventoryItem>? filteredStockItems,
    List<InventoryMovement>? allMovements,
    List<InventoryMovement>? filteredMovements,
    int? selectedTab,
    String? stockSearchQuery,
    bool? hideZeroStock,
    String? sortColumn,
    bool? sortAscending,
    String? movementSearchQuery,
    String? movementTypeFilter,
    DateTime? movementDateFrom,
    DateTime? movementDateTo,
    bool clearDateRange = false,
    int? movementsPage,
  }) =>
      InventoryLoaded(
        allStockItems: allStockItems ?? this.allStockItems,
        filteredStockItems: filteredStockItems ?? this.filteredStockItems,
        allMovements: allMovements ?? this.allMovements,
        filteredMovements: filteredMovements ?? this.filteredMovements,
        selectedTab: selectedTab ?? this.selectedTab,
        stockSearchQuery: stockSearchQuery ?? this.stockSearchQuery,
        hideZeroStock: hideZeroStock ?? this.hideZeroStock,
        sortColumn: sortColumn ?? this.sortColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        movementSearchQuery: movementSearchQuery ?? this.movementSearchQuery,
        movementTypeFilter: movementTypeFilter ?? this.movementTypeFilter,
        movementDateFrom:
            clearDateRange ? null : (movementDateFrom ?? this.movementDateFrom),
        movementDateTo:
            clearDateRange ? null : (movementDateTo ?? this.movementDateTo),
        movementsPage: movementsPage ?? this.movementsPage,
      );
}

class InventoryError extends InventoryStates {
  const InventoryError({
    required this.message,
    super.selectedTab,
    super.stockSearchQuery,
    super.hideZeroStock,
    super.sortColumn,
    super.sortAscending,
    super.movementSearchQuery,
    super.movementTypeFilter,
    super.movementDateFrom,
    super.movementDateTo,
    super.movementsPage,
  });

  final String message;

  @override
  InventoryError copyWith({
    String? message,
    int? selectedTab,
    String? stockSearchQuery,
    bool? hideZeroStock,
    String? sortColumn,
    bool? sortAscending,
    String? movementSearchQuery,
    String? movementTypeFilter,
    DateTime? movementDateFrom,
    DateTime? movementDateTo,
    bool clearDateRange = false,
    int? movementsPage,
  }) =>
      InventoryError(
        message: message ?? this.message,
        selectedTab: selectedTab ?? this.selectedTab,
        stockSearchQuery: stockSearchQuery ?? this.stockSearchQuery,
        hideZeroStock: hideZeroStock ?? this.hideZeroStock,
        sortColumn: sortColumn ?? this.sortColumn,
        sortAscending: sortAscending ?? this.sortAscending,
        movementSearchQuery: movementSearchQuery ?? this.movementSearchQuery,
        movementTypeFilter: movementTypeFilter ?? this.movementTypeFilter,
        movementDateFrom:
            clearDateRange ? null : (movementDateFrom ?? this.movementDateFrom),
        movementDateTo:
            clearDateRange ? null : (movementDateTo ?? this.movementDateTo),
        movementsPage: movementsPage ?? this.movementsPage,
      );
}
