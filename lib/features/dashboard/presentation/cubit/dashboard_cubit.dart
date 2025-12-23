import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/models/metric_config.dart';
import 'package:frontend/core/utils/metric_preferences.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';
import 'package:frontend/features/campaigns/data/repositories/campaign_repository.dart';
import 'package:frontend/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:frontend/features/dashboard/presentation/widgets/period_selector.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository dashboardRepository;
  final CampaignRepository campaignRepository;

  DashboardCubit({
    required this.dashboardRepository,
    required this.campaignRepository,
  }) : super(DashboardInitial());

  Future<void> loadDashboard({
    DateRangeOption? dateRange,
    List<String>? extendedFields,
  }) async {
    try {
      emit(DashboardLoading());

      // Load saved date range if not provided
      final range = dateRange ?? await PeriodSelector.loadSelectedRange();

      // Load metrics preferences
      final selectedMetrics = await MetricPreferences.loadSelectedMetrics();
      final viewMode = await MetricPreferences.loadDashboardViewMode();

      // Calculate extended fields if not provided
      final fields = extendedFields ?? _calculateExtendedFields(selectedMetrics);

      // Fetch LIVE data from Google Ads API
      final results = await Future.wait([
        dashboardRepository.getStats(
          startDate: range.startDateFormatted,
          endDate: range.endDateFormatted,
        ),
        campaignRepository.getCampaigns(
          live: true,
          startDate: range.startDateFormatted,
          endDate: range.endDateFormatted,
          extendedFields: fields,
        ),
        dashboardRepository.getPendingOptimizationsCount(),
      ]);

      final stats = results[0] as DashboardStats;
      final campaigns = results[1] as List<Campaign>;
      final pendingCount = results[2] as int;

      final topCampaigns = campaigns.take(5).toList();

      emit(DashboardLoaded(
        stats: stats,
        campaigns: topCampaigns,
        pendingOptimizations: pendingCount,
        selectedDateRange: range,
        selectedFilter: 'Tutte',
        selectedMetrics: selectedMetrics,
        viewMode: viewMode,
      ));
    } catch (e) {
      print('Error loading dashboard: $e');
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> changePeriod(
      DateRangeOption range, {
        List<String>? extendedFields,
      }) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      // Show loading overlay but keep current data visible
      emit(DashboardLoaded(
        stats: currentState.stats,
        campaigns: currentState.campaigns,
        pendingOptimizations: currentState.pendingOptimizations,
        selectedDateRange: range,
        selectedFilter: currentState.selectedFilter,
        selectedMetrics: currentState.selectedMetrics,
        viewMode: currentState.viewMode,
        isRefreshing: true,
      ));

      final fields = extendedFields ?? _calculateExtendedFields(currentState.selectedMetrics);

      // Fetch LIVE data from Google Ads
      final results = await Future.wait([
        dashboardRepository.getStats(
          startDate: range.startDateFormatted,
          endDate: range.endDateFormatted,
        ),
        campaignRepository.getCampaigns(
          live: true,
          startDate: range.startDateFormatted,
          endDate: range.endDateFormatted,
          extendedFields: fields,
        ),
      ]);

      final stats = results[0] as DashboardStats;
      final campaigns = results[1] as List<Campaign>;

      List<Campaign> filteredCampaigns = _applyFilter(
        campaigns,
        currentState.selectedFilter,
      );

      final topCampaigns = filteredCampaigns.take(5).toList();

      emit(DashboardLoaded(
        stats: stats,
        campaigns: topCampaigns,
        pendingOptimizations: currentState.pendingOptimizations,
        selectedDateRange: range,
        selectedFilter: currentState.selectedFilter,
        selectedMetrics: currentState.selectedMetrics,
        viewMode: currentState.viewMode,
      ));
    } catch (e) {
      print('Error changing period: $e');
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> filterCampaigns(
      String filter, {
        List<String>? extendedFields,
      }) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      final fields = extendedFields ?? _calculateExtendedFields(currentState.selectedMetrics);

      final campaigns = await campaignRepository.getCampaigns(
        live: true,
        startDate: currentState.selectedDateRange.startDateFormatted,
        endDate: currentState.selectedDateRange.endDateFormatted,
        extendedFields: fields,
      );

      final filteredCampaigns = _applyFilter(campaigns, filter);
      final topCampaigns = filteredCampaigns.take(5).toList();

      emit(currentState.copyWith(
        campaigns: topCampaigns,
        selectedFilter: filter,
      ));
    } catch (e) {
      print('Error filtering campaigns: $e');
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> reloadMetricsPreferences() async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    try {
      // Reload preferences from SharedPreferences
      final selectedMetrics = await MetricPreferences.loadSelectedMetrics();
      final viewMode = await MetricPreferences.loadDashboardViewMode();

      // Check if actually changed
      final metricsChanged = _hasMetricsChanged(
        currentState.selectedMetrics,
        selectedMetrics,
      );
      final modeChanged = currentState.viewMode != viewMode;

      if (metricsChanged || modeChanged) {
        // Emit new state with updated preferences
        emit(currentState.copyWith(
          selectedMetrics: selectedMetrics,
          viewMode: viewMode,
        ));

        // If metrics changed, refresh data with new extended fields
        if (metricsChanged) {
          final fields = _calculateExtendedFields(selectedMetrics);
          await refreshDashboard(extendedFields: fields);
        }
      }
    } catch (e) {
      print('Error reloading metrics preferences: $e');
    }
  }

  bool _hasMetricsChanged(
      List<SelectedMetric> old,
      List<SelectedMetric> newMetrics,
      ) {
    if (old.length != newMetrics.length) return true;

    for (int i = 0; i < old.length; i++) {
      if (old[i].config.key != newMetrics[i].config.key ||
          old[i].color != newMetrics[i].color) {
        return true;
      }
    }

    return false;
  }

  List<String> _calculateExtendedFields(List<SelectedMetric> metrics) {
    const baseFields = [
      'cost',
      'conversions',
      'cost_per_conv',
      'conversion_value',
      'impressions',
      'clicks',
      'ctr',
      'cpc',
      'roas'
    ];

    return metrics
        .map((m) => m.config.key)
        .where((key) => !baseFields.contains(key))
        .toList();
  }

  List<Campaign> _applyFilter(List<Campaign> campaigns, String filter) {
    switch (filter) {
      case 'Attive':
        return campaigns
            .where((c) => c.status.toUpperCase() == 'ENABLED')
            .toList();
      case 'In pausa':
        return campaigns
            .where((c) => c.status.toUpperCase() == 'PAUSED')
            .toList();
      case 'Attenzione':
        return campaigns
            .where((c) => c.cost > 1000 || c.ctr < 1.0)
            .toList();
      default: // 'Tutte'
        return campaigns;
    }
  }

  Future<void> refreshDashboard({List<String>? extendedFields}) async {
    final currentState = state;
    final dateRange = currentState is DashboardLoaded
        ? currentState.selectedDateRange
        : await PeriodSelector.loadSelectedRange();
    await loadDashboard(
      dateRange: dateRange,
      extendedFields: extendedFields,
    );
  }
}