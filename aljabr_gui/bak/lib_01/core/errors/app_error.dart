/// Typed failure hierarchy — use sealed classes for exhaustive handling.
sealed class AppError {
  const AppError(this.message);
  final String message;
}

final class NetworkError extends AppError {
  const NetworkError(super.message, {this.statusCode});
  final int? statusCode;
}

final class ApiError extends AppError {
  const ApiError(super.message, {this.type});
  final String? type;
}

final class StorageError extends AppError {
  const StorageError(super.message);
}

final class ParseError extends AppError {
  const ParseError(super.message);
}

final class ValidationError extends AppError {
  const ValidationError(super.message);
}

final class ExecutionError extends AppError {
  const ExecutionError(super.message);
}
