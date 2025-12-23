import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/models/metric_config.dart';
import 'package:frontend/core/utils/metric_preferences.dart';
import 'package:frontend/features/campaigns/presentation/widgets/campaign_card.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/user_header.dart';
import '../widgets/period_selector.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/custom_filter_chip.dart';
import '../widgets/custom_snackbar.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AutoRouteAware {
  bool _isOpportunityCardDismissed = false;

  @override
  void initState() {
    super.initState();
    _loadOpportunityCardState();
    // Load dashboard via BLoC
    context.read<DashboardCubit>().loadDashboard();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen from another route
    // Reload metrics preferences - will auto-refresh if changed
    context.read<DashboardCubit>().reloadMetricsPreferences();
  }

  Future<void> _loadOpportunityCardState() async {
    final isDismissed = await OpportunityCardManager.isDismissed('main_opportunity');
    if (mounted) {
      setState(() {
        _isOpportunityCardDismissed = isDismissed;
      });
    }
  }

  Future<void> _dismissOpportunityCard() async {
    await OpportunityCardManager.dismiss('main_opportunity');
    if (mounted) {
      setState(() {
        _isOpportunityCardDismissed = true;
      });

      CustomSnackBar.showDismissed(
        context,
        message: 'Card hidden',
        onUndo: () async {
          await OpportunityCardManager.show('main_opportunity');
          if (mounted) {
            setState(() {
              _isOpportunityCardDismissed = false;
            });
          }
        },
      );
    }
  }

  Future<void> _toggleViewMode(DashboardLoaded state) async {
    final newMode = state.viewMode == DashboardViewMode.card
        ? DashboardViewMode.chart
        : DashboardViewMode.card;

    await MetricPreferences.saveDashboardViewMode(newMode);

    // Trigger reload - will pick up new view mode
    context.read<DashboardCubit>().reloadMetricsPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<DashboardCubit>().refreshDashboard(),
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is DashboardError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading dashboard',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<DashboardCubit>().loadDashboard(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              if (state is DashboardLoaded) {
                return Stack(
                  children: [
                    _buildDashboard(context, state),
                    if (state.isRefreshing)
                      Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, DashboardLoaded state) {
    final hasOptimizations = state.pendingOptimizations > 0;
    final shouldShowCard = hasOptimizations && !_isOpportunityCardDismissed;

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Column(
            children: [
              UserHeader(
                userName: 'Moussa',
                greeting: 'Welcome',
                showNotification: true,
                onNotificationPressed: () {},
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),

        // Opportunity Card
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: shouldShowCard
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: shouldShowCard ? 1.0 : 0.0,
                child: OpportunityCard(
                  badge: 'OPPORTUNITY',
                  badgeIcon: Icons.auto_awesome,
                  title: '${state.pendingOptimizations} Optimization${state.pendingOptimizations == 1 ? '' : 's'} available',
                  subtitle: 'Improve ROAS by 15% by applying automatic suggestions.',
                  buttonText: 'View suggestions',
                  onButtonPressed: () {
                    context.router.pushNamed('/optimizations');
                  },
                  onDismiss: _dismissOpportunityCard,
                  showDismissButton: true,
                ),
              ),
            )
                : const SizedBox.shrink(),
          ),
        ),

        // Spacing
        SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            height: shouldShowCard ? 20 : 0,
          ),
        ),

        // Overview Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(
                            state.viewMode == DashboardViewMode.card
                                ? Icons.show_chart
                                : Icons.grid_view,
                            size: 20,
                          ),
                          onPressed: () => _toggleViewMode(state),
                          tooltip: state.viewMode == DashboardViewMode.card
                              ? 'Switch to chart view'
                              : 'Switch to card view',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    PeriodSelector(
                      selectedRange: state.selectedDateRange,
                      onRangeChanged: (range) {
                        context.read<DashboardCubit>().changePeriod(range);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (state.viewMode == DashboardViewMode.card)
                  _buildCardView(state)
                else
                  _buildChartView(state),
              ],
            ),
          ),
        ),

        // Campaigns Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SectionHeader(
                  title: 'Campaigns',
                  actionText: 'View all',
                  onActionPressed: () {
                    context.router.pushNamed('/campaigns');
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      CustomFilterChip(
                        label: 'All',
                        isSelected: state.selectedFilter == 'Tutte',
                        onTap: () {
                          context.read<DashboardCubit>().filterCampaigns('Tutte');
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'Active',
                        isSelected: state.selectedFilter == 'Attive',
                        onTap: () {
                          context.read<DashboardCubit>().filterCampaigns('Attive');
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'Paused',
                        isSelected: state.selectedFilter == 'In pausa',
                        onTap: () {
                          context.read<DashboardCubit>().filterCampaigns('In pausa');
                        },
                      ),
                      const SizedBox(width: 8),
                      CustomFilterChip(
                        label: 'Attention',
                        isSelected: state.selectedFilter == 'Attenzione',
                        onTap: () {
                          context.read<DashboardCubit>().filterCampaigns('Attenzione');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Campaign Cards
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final campaign = state.campaigns[index];
                return CampaignCard(
                  campaign: campaign,
                  onTap: () {
                    context.router.pushNamed('/campaigns/${campaign.campaignId}');
                  },
                );
              },
              childCount: state.campaigns.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildCardView(DashboardLoaded state) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: state.selectedMetrics.map((selectedMetric) {
        return _buildStatCardForMetric(selectedMetric, state);
      }).toList(),
    );
  }

  Widget _buildStatCardForMetric(SelectedMetric selectedMetric, DashboardLoaded state) {
    final config = selectedMetric.config;

    String value;
    String change;
    bool isPositive;
    IconData icon;

    switch (config.key) {
      case 'cost':
        value = '€${state.stats.spend.toStringAsFixed(2)}';
        change = '${state.stats.spendChange > 0 ? "+" : ""}${state.stats.spendChange.toStringAsFixed(1)}%';
        isPositive = state.stats.spendChange > 0;
        icon = Icons.payments_outlined;
        break;

      case 'conversions':
        value = '${state.stats.conversions}';
        change = '${state.stats.conversionsChange > 0 ? "+" : ""}${state.stats.conversionsChange.toStringAsFixed(1)}%';
        isPositive = state.stats.conversionsChange > 0;
        icon = Icons.verified_outlined;
        break;

      case 'cost_per_conv':
        value = '€${state.stats.costPerConversion.toStringAsFixed(2)}';
        change = '${state.stats.costPerConversionChange > 0 ? "+" : ""}${state.stats.costPerConversionChange.toStringAsFixed(1)}%';
        isPositive = state.stats.costPerConversionChange < 0;
        icon = Icons.euro_outlined;
        break;

      case 'conversion_value':
        value = '€${state.stats.conversionValue.toStringAsFixed(0)}';
        change = '${state.stats.conversionValueChange > 0 ? "+" : ""}${state.stats.conversionValueChange.toStringAsFixed(1)}%';
        isPositive = state.stats.conversionValueChange > 0;
        icon = Icons.trending_up;
        break;

      default:
        value = 'N/A';
        change = '0.0%';
        isPositive = true;
        icon = Icons.analytics_outlined;
    }

    return StatCard(
      icon: icon,
      label: config.displayName.toUpperCase(),
      value: value,
      change: change,
      isPositive: isPositive,
      color: selectedMetric.color,
    );
  }

  Widget _buildChartView(DashboardLoaded state) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.show_chart,
              size: 48,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Chart view coming soon',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Multi-line chart with ${state.selectedMetrics.length} metrics',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}