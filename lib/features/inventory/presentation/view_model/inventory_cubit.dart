import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

import 'package:mazr3a/core/helpers/text_normalizer.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_item.dart';
import 'package:mazr3a/features/inventory/domain/entity/inventory_movement.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_levels_use_case.dart';
import 'package:mazr3a/features/inventory/domain/use_cases/get_inventory_movements_use_case.dart';

part 'inventory_states.dart';

@Injectable()
class InventoryCubit extends Cubit<InventoryStates> {
  InventoryCubit(
    this._getInventoryLevelsUseCase,
    this._getInventoryMovementsUseCase,
    this._changeNotifier,
  ) : super(const InventoryInit()) {
    _changeNotifier.addListener(_onWarehouseChanged);
    unawaited(loadInventory());
  }

  final GetInventoryLevelsUseCase _getInventoryLevelsUseCase;
  final GetInventoryMovementsUseCase _getInventoryMovementsUseCase;
  final WarehouseChangeNotifier _changeNotifier;

  static InventoryCubit of(BuildContext context) =>
      context.read<InventoryCubit>();

  void _onWarehouseChanged() {
    unawaited(loadInventory());
  }

  Future<void> loadInventory() async {
    final levelsResult = await _getInventoryLevelsUseCase();
    final movementsResult = await _getInventoryMovementsUseCase();

    final List<InventoryItem> allItems;
    switch (levelsResult) {
      case ApiSuccess(:final data):
        allItems = data;
      case ApiError(:final message):
        emit(
          InventoryError(
            message: message,
            selectedTab: state.selectedTab,
            stockSearchQuery: state.stockSearchQuery,
            hideZeroStock: state.hideZeroStock,
            sortColumn: state.sortColumn,
            sortAscending: state.sortAscending,
            movementSearchQuery: state.movementSearchQuery,
            movementTypeFilter: state.movementTypeFilter,
            movementDateFrom: state.movementDateFrom,
            movementDateTo: state.movementDateTo,
            movementsPage: state.movementsPage,
          ),
        );
        return;
    }

    final List<InventoryMovement> allMovements;
    switch (movementsResult) {
      case ApiSuccess(:final data):
        allMovements = data;
      case ApiError(:final message):
        emit(
          InventoryError(
            message: message,
            selectedTab: state.selectedTab,
            stockSearchQuery: state.stockSearchQuery,
            hideZeroStock: state.hideZeroStock,
            sortColumn: state.sortColumn,
            sortAscending: state.sortAscending,
            movementSearchQuery: state.movementSearchQuery,
            movementTypeFilter: state.movementTypeFilter,
            movementDateFrom: state.movementDateFrom,
            movementDateTo: state.movementDateTo,
            movementsPage: state.movementsPage,
          ),
        );
        return;
    }

    final filteredStock = _filterAndSortStock(
      all: allItems,
      search: state.stockSearchQuery,
      hideZero: state.hideZeroStock,
      column: state.sortColumn,
      ascending: state.sortAscending,
    );

    final filteredMovements = _filterMovements(
      all: allMovements,
      search: state.movementSearchQuery,
      typeFilter: state.movementTypeFilter,
      from: state.movementDateFrom,
      to: state.movementDateTo,
    );

    emit(
      InventoryLoaded(
        allStockItems: allItems,
        filteredStockItems: filteredStock,
        allMovements: allMovements,
        filteredMovements: filteredMovements,
        selectedTab: state.selectedTab,
        stockSearchQuery: state.stockSearchQuery,
        hideZeroStock: state.hideZeroStock,
        sortColumn: state.sortColumn,
        sortAscending: state.sortAscending,
        movementSearchQuery: state.movementSearchQuery,
        movementTypeFilter: state.movementTypeFilter,
        movementDateFrom: state.movementDateFrom,
        movementDateTo: state.movementDateTo,
        movementsPage: state.movementsPage,
      ),
    );
  }

  void setTab(int tabIndex) {
    emit(state.copyWith(selectedTab: tabIndex));
  }

  void setStockSearch(String query) {
    if (state is! InventoryLoaded) {
      emit(state.copyWith(stockSearchQuery: query));
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterAndSortStock(
      all: loaded.allStockItems,
      search: query,
      hideZero: loaded.hideZeroStock,
      column: loaded.sortColumn,
      ascending: loaded.sortAscending,
    );
    emit(
      loaded.copyWith(
        stockSearchQuery: query,
        filteredStockItems: updated,
      ),
    );
  }

  void toggleHideZeroStock() {
    final next = !state.hideZeroStock;
    if (state is! InventoryLoaded) {
      emit(state.copyWith(hideZeroStock: next));
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterAndSortStock(
      all: loaded.allStockItems,
      search: loaded.stockSearchQuery,
      hideZero: next,
      column: loaded.sortColumn,
      ascending: loaded.sortAscending,
    );
    emit(
      loaded.copyWith(
        hideZeroStock: next,
        filteredStockItems: updated,
      ),
    );
  }

  void setSort(String column) {
    final isSameColumn = state.sortColumn == column;
    final newAscending = isSameColumn ? !state.sortAscending : true;

    if (state is! InventoryLoaded) {
      emit(
        state.copyWith(
          sortColumn: column,
          sortAscending: newAscending,
        ),
      );
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterAndSortStock(
      all: loaded.allStockItems,
      search: loaded.stockSearchQuery,
      hideZero: loaded.hideZeroStock,
      column: column,
      ascending: newAscending,
    );
    emit(
      loaded.copyWith(
        sortColumn: column,
        sortAscending: newAscending,
        filteredStockItems: updated,
      ),
    );
  }

  void setMovementSearch(String query) {
    if (state is! InventoryLoaded) {
      emit(state.copyWith(movementSearchQuery: query, movementsPage: 1));
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterMovements(
      all: loaded.allMovements,
      search: query,
      typeFilter: loaded.movementTypeFilter,
      from: loaded.movementDateFrom,
      to: loaded.movementDateTo,
    );
    emit(
      loaded.copyWith(
        movementSearchQuery: query,
        filteredMovements: updated,
        movementsPage: 1,
      ),
    );
  }

  void setMovementTypeFilter(String filter) {
    if (state is! InventoryLoaded) {
      emit(state.copyWith(movementTypeFilter: filter, movementsPage: 1));
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterMovements(
      all: loaded.allMovements,
      search: loaded.movementSearchQuery,
      typeFilter: filter,
      from: loaded.movementDateFrom,
      to: loaded.movementDateTo,
    );
    emit(
      loaded.copyWith(
        movementTypeFilter: filter,
        filteredMovements: updated,
        movementsPage: 1,
      ),
    );
  }

  void setMovementDateRange(DateTime? from, DateTime? to) {
    if (state is! InventoryLoaded) {
      emit(
        state.copyWith(
          movementDateFrom: from,
          movementDateTo: to,
          movementsPage: 1,
        ),
      );
      return;
    }
    final loaded = state as InventoryLoaded;
    final updated = _filterMovements(
      all: loaded.allMovements,
      search: loaded.movementSearchQuery,
      typeFilter: loaded.movementTypeFilter,
      from: from,
      to: to,
    );
    emit(
      loaded.copyWith(
        movementDateFrom: from,
        movementDateTo: to,
        filteredMovements: updated,
        movementsPage: 1,
      ),
    );
  }

  void clearMovementDateRange() {
    setMovementDateRange(null, null);
  }

  void setMovementsPage(int page) {
    emit(state.copyWith(movementsPage: page));
  }

  List<InventoryItem> _filterAndSortStock({
    required List<InventoryItem> all,
    required String search,
    required bool hideZero,
    required String column,
    required bool ascending,
  }) {
    var list = all;

    if (hideZero) {
      list = list.where((i) => i.inStock != 0).toList();
    }

    if (search.trim().isNotEmpty) {
      final normQuery = normalizeText(search);
      list = list.where((i) {
        return i.normalizedKey.contains(normQuery) ||
            normalizeText(i.product).contains(normQuery) ||
            normalizeText(i.type).contains(normQuery) ||
            normalizeText(i.unit).contains(normQuery);
      }).toList();
    }

    final sorted = List<InventoryItem>.from(list);
    sorted.sort((a, b) {
      final int comparison;
      switch (column) {
        case 'product':
          comparison = a.product
              .toLowerCase()
              .compareTo(b.product.toLowerCase());
        case 'type':
          comparison = a.type.toLowerCase().compareTo(b.type.toLowerCase());
        case 'unit':
          comparison = a.unit.toLowerCase().compareTo(b.unit.toLowerCase());
        case 'totalIn':
          comparison = a.totalIn.compareTo(b.totalIn);
        case 'totalOut':
          comparison = a.totalOut.compareTo(b.totalOut);
        case 'inStock':
          comparison = a.inStock.compareTo(b.inStock);
        case 'lastPrice':
          comparison = a.lastPrice.compareTo(b.lastPrice);
        case 'stockValue':
          comparison = a.stockValue.compareTo(b.stockValue);
        default:
          comparison = a.product
              .toLowerCase()
              .compareTo(b.product.toLowerCase());
      }
      return ascending ? comparison : -comparison;
    });

    return sorted;
  }

  List<InventoryMovement> _filterMovements({
    required List<InventoryMovement> all,
    required String search,
    required String typeFilter,
    required DateTime? from,
    required DateTime? to,
  }) {
    var list = all;

    if (typeFilter == 'Inbound') {
      list = list.where((m) => m.type == MovementType.inbound).toList();
    } else if (typeFilter == 'Outbound') {
      list = list.where((m) => m.type == MovementType.outbound).toList();
    }

    if (from != null) {
      final fromStr = DateFormat('yyyy-MM-dd').format(from);
      list = list.where((m) => m.date.compareTo(fromStr) >= 0).toList();
    }

    if (to != null) {
      final toStr = DateFormat('yyyy-MM-dd').format(to);
      list = list.where((m) => m.date.compareTo(toStr) <= 0).toList();
    }

    if (search.trim().isNotEmpty) {
      final normQuery = normalizeText(search);
      list = list.where((m) {
        return m.normalizedKey.contains(normQuery) ||
            normalizeText(m.product).contains(normQuery) ||
            normalizeText(m.itemType).contains(normQuery) ||
            normalizeText(m.unit).contains(normQuery) ||
            normalizeText(m.reference).contains(normQuery);
      }).toList();
    }

    return list;
  }

  @override
  Future<void> close() {
    _changeNotifier.removeListener(_onWarehouseChanged);
    return super.close();
  }
}
