import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';
import 'package:frontend/features/campaigns/presentation/widgets/advanced_metrics_section.dart';
import 'package:frontend/features/campaigns/presentation/widgets/campaign_detail_header.dart';
import 'package:frontend/features/campaigns/presentation/widgets/metric_card.dart';
import 'package:frontend/features/campaigns/presentation/widgets/metrics_grid.dart';
import 'package:frontend/features/campaigns/presentation/widgets/section_card.dart';
import 'package:frontend/features/campaigns/presentation/widgets/trend_chart.dart';

@RoutePage(name: 'CampaignDetailRoute')
class CampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;

  const CampaignDetailScreen({
    super.key,
    required this.campaign,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.router.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            CampaignDetailHeader(campaign: campaign),

            const SizedBox(height: 16),

            // Main metrics cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      icon: Icons.payments_outlined,
                      label: 'SPESA',
                      value: '€${campaign.cost.toStringAsFixed(2)}',
                      change: '+12% vs ieri',
                      changePositive: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MetricCard(
                      icon: Icons.shopping_cart_outlined,
                      label: 'CONVERSIONI',
                      value: '${campaign.conversions.toInt()}',
                      subtitle: 'Valore: €${campaign.conversionValue.toStringAsFixed(2)}',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Trend chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionCard(
                title: '',
                child: TrendChart(
                  data: const [
                    FlSpot(0, 8),
                    FlSpot(1, 12),
                    FlSpot(2, 10),
                    FlSpot(3, 15),
                    FlSpot(4, 11),
                    FlSpot(5, 14),
                    FlSpot(6, 12.5),
                  ],
                  onPeriodTap: () {
                    // TODO: Show period selector
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Main metrics section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionCard(
                title: 'METRICHE PRINCIPALI',
                child: MetricsGrid(
                  metrics: {
                    'Impressions': campaign.impressions.toString(),
                    'Click': campaign.clicks.toString(),
                    'CTR': '${campaign.ctr.toStringAsFixed(2)}%',
                    'Costo / Conv.': '€${campaign.costPerAction?.toStringAsFixed(2) ?? "0.00"}',
                    'CPC Medio': '€${campaign.averageCpc?.toStringAsFixed(2) ?? "0.00"}',
                    'ROAS': campaign.roas?.toStringAsFixed(2) ?? "0.00",
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Advanced sections
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AdvancedMetricsSection(
                    icon: Icons.touch_app,
                    title: 'Interazioni & Engagement',
                    metrics: const {
                      'INTERACTION RATE': '4.52%',
                      'INTERACTIONS': '705',
                      'ENGAGEMENTS': '680',
                      'AVG. CPM': '€5.28',
                    },
                  ),
                  const SizedBox(height: 16),
                  AdvancedMetricsSection(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Conversioni Totali',
                    metrics: const {
                      'CONV. RATE': '0.72%',
                      'TUTTE LE CONV.': '7.5',
                      'VALORE TUTTE CONV.': '€310.50',
                      'CPA': '€10.99',
                    },
                  ),
                  const SizedBox(height: 16),
                  AdvancedMetricsSection(
                    icon: Icons.visibility_outlined,
                    title: 'Visibilità',
                    metrics: const {
                      'VIEWABLE IMPL.': '12,400',
                      'VIEWABLE CTR': '3.8%',
                      'SEARCH IMPR. SHARE': '< 10%',
                      'TOP IMPR. SHARE': '45%',
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}