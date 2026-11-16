import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:mazr3a/core/helpers/receipt_calculator.dart';
import 'package:mazr3a/core/network/api_result.dart';
import 'package:mazr3a/features/inbound/domain/entity/inbound_receipt_entity.dart';
import 'package:mazr3a/features/inbound/domain/use_cases/add_inbound_receipt_use_case.dart';
import 'package:mazr3a/features/inbound/domain/use_cases/delete_inbound_receipt_use_case.dart';
import 'package:mazr3a/features/inbound/domain/use_cases/get_inbound_log_use_case.dart';

part 'inbound_states.dart';

@Injectable()
class InboundCubit extends Cubit<InboundStates> {
  InboundCubit(
    this._getInboundLogUseCase,
    this._addInboundReceiptUseCase,
    this._deleteInboundReceiptUseCase,
  ) : super(const InboundInit()) {
    unawaited(loadReceipts());
  }

  final GetInboundLogUseCase _getInboundLogUseCase;
  final AddInboundReceiptUseCase _addInboundReceiptUseCase;
  final DeleteInboundReceiptUseCase _deleteInboundReceiptUseCase;

  static InboundCubit of(BuildContext context) => context.read<InboundCubit>();

  void updateLiveTotal({
    required String quantity,
    required String unitPrice,
  }) {
    final total = ReceiptCalculator.calculateTotal(
      quantity: quantity,
      unitPrice: unitPrice,
    );
    emit(state.copyWith(liveTotal: total));
  }

  Future<void> loadReceipts() async {
    emit(const InboundLoading());
    final result = await _getInboundLogUseCase();
    switch (result) {
      case ApiSuccess(:final data):
        emit(
          InboundLoaded(
            allReceipts: data,
            filteredReceipts: data,
          ),
        );
      case ApiError(:final message):
        emit(InboundError(message: message));
    }
  }

  void setFilter(String filter) {
    if (state is! InboundLoaded) return;
    final currentState = state as InboundLoaded;
    final updated = _applyFilters(
      all: currentState.allReceipts,
      filter: filter,
      search: currentState.searchQuery,
    );
    emit(
      currentState.copyWith(
        activeFilter: filter,
        filteredReceipts: updated,
      ),
    );
  }

  void setSearch(String query) {
    if (state is! InboundLoaded) return;
    final currentState = state as InboundLoaded;
    final updated = _applyFilters(
      all: currentState.allReceipts,
      filter: currentState.activeFilter,
      search: query,
    );
    emit(
      currentState.copyWith(
        searchQuery: query,
        filteredReceipts: updated,
      ),
    );
  }

  Future<void> addReceipt(InboundReceiptEntity receipt) async {
    emit(const InboundSubmitting());
    final result = await _addInboundReceiptUseCase(receipt);
    switch (result) {
      case ApiSuccess(:final data):
        emit(InboundSubmitSuccess(receipt: data));
        unawaited(loadReceipts());
      case ApiError(:final message):
        emit(InboundError(message: message));
    }
  }

  Future<void> deleteRecord(String id) async {
    if (state is InboundLoaded) {
      emit((state as InboundLoaded).copyWith(deletingId: id));
    }
    final result = await _deleteInboundReceiptUseCase(id);
    switch (result) {
      case ApiSuccess():
        emit(const InboundDeleteSuccess(message: 'Record deleted successfully'));
        await loadReceipts();
      case ApiError(:final message):
        if (state is InboundLoaded) {
          emit((state as InboundLoaded).copyWith(deletingId: null));
        }
        emit(InboundError(message: message));
    }
  }

  List<InboundReceiptEntity> _applyFilters({
    required List<InboundReceiptEntity> all,
    required String filter,
    required String search,
  }) {
    var list = all;

    if (filter == 'Cash') {
      list = list.where((item) => item.payment.toLowerCase() == 'cash').toList();
    } else if (filter == 'Deferred') {
      list = list
          .where((item) => item.payment.toLowerCase() == 'deferred')
          .toList();
    }

    if (search.trim().isNotEmpty) {
      final query = search.trim().toLowerCase();
      list = list.where((item) {
        return item.item.toLowerCase().contains(query) ||
            item.supplier.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }
}
