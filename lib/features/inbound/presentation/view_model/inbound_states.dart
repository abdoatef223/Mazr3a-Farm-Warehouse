part of 'inbound_cubit.dart';

sealed class InboundStates {
  const InboundStates({
    this.deletingId,
    this.liveTotal = 0.0,
  });

  final String? deletingId;
  final double liveTotal;

  InboundStates copyWith({
    String? deletingId,
    double? liveTotal,
  });
}

class InboundInit extends InboundStates {
  const InboundInit({
    super.deletingId,
    super.liveTotal,
  });

  @override
  InboundInit copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundInit(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundLoading extends InboundStates {
  const InboundLoading({
    super.deletingId,
    super.liveTotal,
  });

  @override
  InboundLoading copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundLoading(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundLoaded extends InboundStates {
  const InboundLoaded({
    required this.allReceipts,
    required this.filteredReceipts,
    this.activeFilter = 'All',
    this.searchQuery = '',
    super.deletingId,
    super.liveTotal,
  });

  final List<InboundReceiptEntity> allReceipts;
  final List<InboundReceiptEntity> filteredReceipts;
  final String activeFilter;
  final String searchQuery;

  double get totalValue =>
      filteredReceipts.fold(0, (sum, item) => sum + item.total);

  @override
  InboundLoaded copyWith({
    List<InboundReceiptEntity>? allReceipts,
    List<InboundReceiptEntity>? filteredReceipts,
    String? activeFilter,
    String? searchQuery,
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundLoaded(
        allReceipts: allReceipts ?? this.allReceipts,
        filteredReceipts: filteredReceipts ?? this.filteredReceipts,
        activeFilter: activeFilter ?? this.activeFilter,
        searchQuery: searchQuery ?? this.searchQuery,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundSubmitting extends InboundStates {
  const InboundSubmitting({
    super.deletingId,
    super.liveTotal,
  });

  @override
  InboundSubmitting copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundSubmitting(
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundSubmitSuccess extends InboundStates {
  const InboundSubmitSuccess({
    required this.receipt,
    super.deletingId,
    super.liveTotal,
  });

  final InboundReceiptEntity receipt;

  @override
  InboundSubmitSuccess copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundSubmitSuccess(
        receipt: receipt,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundDeleteSuccess extends InboundStates {
  const InboundDeleteSuccess({
    required this.message,
    super.deletingId,
    super.liveTotal,
  });

  final String message;

  @override
  InboundDeleteSuccess copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundDeleteSuccess(
        message: message,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}

class InboundError extends InboundStates {
  const InboundError({
    required this.message,
    super.deletingId,
    super.liveTotal,
  });

  final String message;

  @override
  InboundError copyWith({
    String? deletingId,
    double? liveTotal,
  }) =>
      InboundError(
        message: message,
        deletingId: deletingId ?? this.deletingId,
        liveTotal: liveTotal ?? this.liveTotal,
      );
}
