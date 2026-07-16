import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

/// Failure produced by database read/write errors.
class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}
