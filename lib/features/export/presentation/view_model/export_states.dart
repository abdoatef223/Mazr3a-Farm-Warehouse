part of 'export_cubit.dart';

sealed class ExportStates {
  const ExportStates();

  ExportStates copyWith();
}

class ExportIdle extends ExportStates {
  const ExportIdle();

  @override
  ExportIdle copyWith() => const ExportIdle();
}

class ExportLoading extends ExportStates {
  const ExportLoading();

  @override
  ExportLoading copyWith() => const ExportLoading();
}

class ExportSuccess extends ExportStates {
  const ExportSuccess({required this.filePath});

  final String filePath;

  @override
  ExportSuccess copyWith({String? filePath}) =>
      ExportSuccess(filePath: filePath ?? this.filePath);
}

class ExportError extends ExportStates {
  const ExportError({required this.message});

  final String message;

  @override
  ExportError copyWith({String? message}) =>
      ExportError(message: message ?? this.message);
}
