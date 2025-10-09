abstract class Failure {
  final String message;
  final dynamic originalError;

  const Failure(this.message, [this.originalError]);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.originalError]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, [super.originalError]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.originalError]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.originalError]);
}