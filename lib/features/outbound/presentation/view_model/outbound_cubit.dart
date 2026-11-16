import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/receipt_calculator.dart';
import 'package:mazr3a/core/helpers/warehouse_change_notifier.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/core/resources/strings_manager.dart';
import 'package:mazr3a/features/outbound/domain/entity/inbound_product_option_entity.dart';
import 'package:mazr3a/features/outbound/domain/entity/outbound_shipment_entity.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/add_outbound_shipment_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/delete_outbound_shipment_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_inbound_product_options_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_outbound_log_use_case.dart';
import 'package:mazr3a/features/outbound/domain/use_cases/get_stock_level_use_case.dart';

part 'outbound_states.dart';

@Injectable()
class OutboundCubit extends Cubit<OutboundStates> {
  OutboundCubit(
    this._getOutboundLogUseCase,
    this._addOutboundShipmentUseCase,
    this._deleteOutboundShipmentUseCase,
    this._getInboundProductOptionsUseCase,
    this._getStockLevelUseCase,
    this._changeNotifier,
  ) : super(const OutboundInit()) {
    _changeNotifier.addListener(_onWarehouseChanged);
    unawaited(loadShipments());
    unawaited(loadProductOptions());
  }

  final GetOutboundLogUseCase _getOutboundLogUseCase;
  final AddOutboundShipmentUseCase _addOutboundShipmentUseCase;
  final DeleteOutboundShipmentUseCase _deleteOutboundShipmentUseCase;
  final GetInboundProductOptionsUseCase _getInboundProductOptionsUseCase;
  final GetStockLevelUseCase _getStockLevelUseCase;
  final WarehouseChangeNotifier _changeNotifier;

  static OutboundCubit of(BuildContext context) =>
      context.read<OutboundCubit>();

  void _onWarehouseChanged() {
    unawaited(loadProductOptions());
    unawaited(loadShipments());
  }

  Future<void> loadProductOptions() async {
    final result = await _getInboundProductOptionsUseCase();
    switch (result) {
      case ApiSuccess(:final data):
        emit(state.copyWith(options: data));
        if (state.selectedProduct != null &&
            state.selectedType != null &&
            data.any((o) => o.product == state.selectedProduct)) {
          unawaited(
            selectType(
              state.selectedType,
              productOverride: state.selectedProduct,
            ),
          );
        }
      case ApiError():
        break;
    }
  }

  void selectProduct(String? product) {
    emit(
      state.copyWith(
        selectedProduct: product,
        clearType: true,
        clearUnit: true,
        clearUnitPrice: true,
        clearAvailableQuantity: true,
        clearQuantityWarning: true,
        liveTotal: 0.0,
      ),
    );
  }

  Future<void> selectType(
    String? type, {
    String? currentQuantity,
    String? productOverride,
  }) async {
    final product = productOverride ?? state.selectedProduct;
    if (type == null || product == null || product.isEmpty) {
      emit(
        state.copyWith(
          clearType: true,
          clearUnit: true,
          clearUnitPrice: true,
          clearAvailableQuantity: true,
          clearQuantityWarning: true,
          liveTotal: 0.0,
        ),
      );
      return;
    }

    final result = await _getStockLevelUseCase(
      product: product,
      type: type,
    );

    switch (result) {
      case ApiSuccess(:final data):
        final qty = double.tryParse((currentQuantity ?? '').trim());
        final hasWarning =
            qty != null && qty > 0 && qty > data.availableQuantity;
        final warning = hasWarning ? StringsManager.overStockWarning : null;
        final total = ReceiptCalculator.calculateTotal(
          quantity: currentQuantity ?? '0',
          unitPrice: data.latestPrice.toString(),
        );

        emit(
          state.copyWith(
            selectedProduct: product,
            selectedType: type,
            unit: data.unit,
            unitPrice: data.latestPrice,
            availableQuantity: data.availableQuantity,
            quantityWarning: warning,
            clearQuantityWarning: warning == null,
            liveTotal: total,
          ),
        );
      case ApiError():
        emit(
          state.copyWith(
            selectedProduct: product,
            selectedType: type,
            clearUnit: true,
            clearUnitPrice: true,
            clearAvailableQuantity: true,
            clearQuantityWarning: true,
          ),
        );
    }
  }

  void updateQuantity({
    required String quantity,
    String? unitPrice,
  }) {
    final qty = double.tryParse(quantity.trim());
    final available = state.availableQuantity;
    final hasWarning =
        qty != null && qty > 0 && available != null && qty > available;
    final warning = hasWarning ? StringsManager.overStockWarning : null;

    final price = unitPrice ??
        (state.unitPrice != null ? state.unitPrice.toString() : '0');
    final total = ReceiptCalculator.calculateTotal(
      quantity: quantity,
      unitPrice: price,
    );

    emit(
      state.copyWith(
        quantityWarning: warning,
        clearQuantityWarning: warning == null,
        liveTotal: total,
      ),
    );
  }

  void updateUnitPrice({
    required String unitPrice,
    String? quantity,
  }) {
    final parsed = double.tryParse(unitPrice.trim());
    final qty = quantity ?? '0';
    final total = ReceiptCalculator.calculateTotal(
      quantity: qty,
      unitPrice: unitPrice,
    );

    emit(
      state.copyWith(
        unitPrice: parsed,
        liveTotal: total,
      ),
    );
  }

  Future<void> loadShipments() async {
    emit(state.copyWith());
    final result = await _getOutboundLogUseCase();
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          OutboundLoaded(
            allShipments: data,
            filteredShipments: data,
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
      case ApiError(:final message):
        emit(
          OutboundError(
            message: message,
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
    }
  }

  void setFilter(String filter) {
    if (state is! OutboundLoaded) return;
    final currentState = state as OutboundLoaded;
    final updated = _applyFilters(
      all: currentState.allShipments,
      filter: filter,
      search: currentState.searchQuery,
    );
    emit(
      currentState.copyWith(
        activeFilter: filter,
        filteredShipments: updated,
      ),
    );
  }

  void setSearch(String query) {
    if (state is! OutboundLoaded) return;
    final currentState = state as OutboundLoaded;
    final updated = _applyFilters(
      all: currentState.allShipments,
      filter: currentState.activeFilter,
      search: query,
    );
    emit(
      currentState.copyWith(
        searchQuery: query,
        filteredShipments: updated,
      ),
    );
  }

  Future<void> addShipment(OutboundShipmentEntity shipment) async {
    emit(
      OutboundSubmitting(
        options: state.options,
        selectedProduct: state.selectedProduct,
        selectedType: state.selectedType,
        unit: state.unit,
        unitPrice: state.unitPrice,
        availableQuantity: state.availableQuantity,
        quantityWarning: state.quantityWarning,
        liveTotal: state.liveTotal,
      ),
    );
    final result = await _addOutboundShipmentUseCase(shipment);
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          OutboundSubmitSuccess(
            shipment: data,
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
        unawaited(loadShipments());
      case ApiError(:final message):
        emit(
          OutboundError(
            message: message,
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
    }
  }

  Future<void> deleteRecord(String id) async {
    if (state is OutboundLoaded) {
      emit((state as OutboundLoaded).copyWith(deletingId: id));
    }
    final result = await _deleteOutboundShipmentUseCase(id);
    switch (result) {
      case ApiSuccess():
        emit(
          OutboundDeleteSuccess(
            message: 'Record deleted successfully',
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
        await loadShipments();
      case ApiError(:final message):
        if (state is OutboundLoaded) {
          emit((state as OutboundLoaded).copyWith(deletingId: null));
        }
        emit(
          OutboundError(
            message: message,
            options: state.options,
            selectedProduct: state.selectedProduct,
            selectedType: state.selectedType,
            unit: state.unit,
            unitPrice: state.unitPrice,
            availableQuantity: state.availableQuantity,
            quantityWarning: state.quantityWarning,
            liveTotal: state.liveTotal,
          ),
        );
    }
  }

  List<OutboundShipmentEntity> _applyFilters({
    required List<OutboundShipmentEntity> all,
    required String filter,
    required String search,
  }) {
    var list = all;

    if (filter != 'All') {
      list = list
          .where(
            (item) => item.type.toLowerCase() == filter.toLowerCase(),
          )
          .toList();
    }

    if (search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      list = list.where((item) {
        return item.product.toLowerCase().contains(query) ||
            item.type.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
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
