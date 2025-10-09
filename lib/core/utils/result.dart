import '../errors/failures.dart';

class Result<T> {
  final T? _data;
  final Failure? _failure;

  const Result._(this._data, this._failure);

  factory Result.success(T data) => Result._(data, null);
  factory Result.failure(Failure failure) => Result._(null, failure);

  bool get isSuccess => _failure == null;
  bool get isFailure => _failure != null;

  T get data {
    if (_failure != null) throw StateError('Result is a failure');
    return _data as T;
  }

  Failure get failure {
    if (_failure == null) throw StateError('Result is a success');
    return _failure;
  }

  T getOrElse(T Function() defaultValue) {
    return _failure == null ? _data as T : defaultValue();
  }

  Result<R> map<R>(R Function(T) transform) {
    return _failure == null 
      ? Result.success(transform(_data as T))
      : Result.failure(_failure);
  }

  Future<Result<R>> flatMap<R>(Future<Result<R>> Function(T) transform) async {
    return _failure == null 
      ? await transform(_data as T)
      : Result.failure(_failure);
  }
}