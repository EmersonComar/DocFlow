abstract class Failure {
  final String messageKey;
  final List<Object> messageArgs;
  final dynamic originalError;

  const Failure(this.messageKey, [this.messageArgs = const [], this.originalError]);

  @override
  String toString() => 'Failure(messageKey: $messageKey, messageArgs: $messageArgs)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.messageKey, [super.messageArgs = const [], super.originalError]);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(super.messageKey, [super.messageArgs = const [], super.originalError]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.messageKey, [super.messageArgs = const [], super.originalError]);
}

class CacheFailure extends Failure {
  const CacheFailure(super.messageKey, [super.messageArgs = const [], super.originalError]);
}