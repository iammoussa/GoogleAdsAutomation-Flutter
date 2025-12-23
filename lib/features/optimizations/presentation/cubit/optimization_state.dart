part of 'optimization_cubit.dart';

abstract class OptimizationState extends Equatable {
  OptimizationState();

  @override
  List<Object?> get props => [];
}

class OptimizationInitial extends OptimizationState {}

class OptimizationLoading extends OptimizationState {}

class OptimizationLoaded extends OptimizationState {
  final List<Optimization> optimizations;

  OptimizationLoaded({required this.optimizations});

  @override
  List<Object?> get props => [optimizations];
}

class OptimizationError extends OptimizationState {
  final String message;

  OptimizationError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OptimizationActionLoading extends OptimizationState {
  final int optimizationId;

  OptimizationActionLoading({required this.optimizationId});

  @override
  List<Object?> get props => [optimizationId];
}

class OptimizationActionSuccess extends OptimizationState {
  final String message;

  OptimizationActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}