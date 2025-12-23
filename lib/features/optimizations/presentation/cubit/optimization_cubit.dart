import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/optimizations/data/repositories/optimization_repository.dart';
import 'package:frontend/features/optimizations/data/models/optimization.dart';

// States
abstract class OptimizationState {}

class OptimizationInitial extends OptimizationState {}

class OptimizationLoading extends OptimizationState {}

class OptimizationLoaded extends OptimizationState {
  final List<Optimization> optimizations;

  OptimizationLoaded({required this.optimizations});
}

class OptimizationError extends OptimizationState {
  final String message;

  OptimizationError(this.message);
}

// Cubit
class OptimizationCubit extends Cubit<OptimizationState> {
  final OptimizationRepository optimizationRepository;

  OptimizationCubit({required this.optimizationRepository})
      : super(OptimizationInitial());

  Future<void> loadOptimizations() async {
    try {
      emit(OptimizationLoading());
      final optimizations = await optimizationRepository.getOptimizations();
      emit(OptimizationLoaded(optimizations: optimizations));
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> applyOptimization(int id) async {
    try {
      await optimizationRepository.applyOptimization(id);
      await loadOptimizations(); // Reload after apply
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }

  Future<void> dismissOptimization(int id) async {
    try {
      await optimizationRepository.dismissOptimization(id);
      await loadOptimizations(); // Reload after dismiss
    } catch (e) {
      emit(OptimizationError(e.toString()));
    }
  }
}