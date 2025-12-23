part of 'dashboard_cubit.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<Campaign> campaigns;
  final int pendingOptimizations;
  final DateRangeOption selectedDateRange;
  final String selectedFilter;
  final List<SelectedMetric> selectedMetrics;
  final DashboardViewMode viewMode;
  final bool isRefreshing;

  DashboardLoaded({
    required this.stats,
    required this.campaigns,
    required this.pendingOptimizations,
    required this.selectedDateRange,
    required this.selectedFilter,
    required this.selectedMetrics,
    required this.viewMode,
    this.isRefreshing = false,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<Campaign>? campaigns,
    int? pendingOptimizations,
    DateRangeOption? selectedDateRange,
    String? selectedFilter,
    List<SelectedMetric>? selectedMetrics,
    DashboardViewMode? viewMode,
    bool? isRefreshing,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      campaigns: campaigns ?? this.campaigns,
      pendingOptimizations: pendingOptimizations ?? this.pendingOptimizations,
      selectedDateRange: selectedDateRange ?? this.selectedDateRange,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      selectedMetrics: selectedMetrics ?? this.selectedMetrics,
      viewMode: viewMode ?? this.viewMode,
      isRefreshing: isRefreshing ?? false,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;

  DashboardError(this.message);
}