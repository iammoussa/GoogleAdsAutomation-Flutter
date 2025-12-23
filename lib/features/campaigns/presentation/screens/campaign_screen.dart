import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';
import 'package:frontend/features/campaigns/presentation/cubit/campaign_cubit.dart';
import 'package:frontend/features/campaigns/presentation/widgets/campaign_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/custom_filter_chip.dart';

@RoutePage()
class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  String _selectedFilter = 'Tutte';

  @override
  void initState() {
    super.initState();
    // Load campaigns with live mode
    context.read<CampaignCubit>().loadCampaigns();
  }

  List<Campaign> _filterCampaigns(List<Campaign> campaigns) {
    switch (_selectedFilter) {
      case 'Attive':
        return campaigns.where((c) => c.status.toUpperCase() == 'ENABLED').toList();
      case 'In pausa':
        return campaigns.where((c) => c.status.toUpperCase() == 'PAUSED').toList();
      case 'Attenzione':
        return campaigns.where((c) => c.cost > 1000 || c.ctr < 1.0).toList();
      default:
        return campaigns;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: BlocBuilder<CampaignCubit, CampaignState>(
          builder: (context, state) {
            if (state is CampaignLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CampaignError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading campaigns',
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
                      onPressed: () =>
                          context.read<CampaignCubit>().loadCampaigns(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is CampaignLoaded) {
              final filteredCampaigns = _filterCampaigns(state.campaigns);

              return RefreshIndicator(
                onRefresh: () => context.read<CampaignCubit>().loadCampaigns(),
                child: CustomScrollView(
                  slivers: [
                    // Header with title and filters
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title and "Vedi tutte" button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Campagne',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() => _selectedFilter = 'Tutte');
                                  },
                                  child: Text(
                                    'Vedi tutte',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Filter chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  CustomFilterChip(
                                    label: 'Tutte',
                                    isSelected: _selectedFilter == 'Tutte',
                                    onTap: () {
                                      setState(() => _selectedFilter = 'Tutte');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  CustomFilterChip(
                                    label: 'Attive',
                                    isSelected: _selectedFilter == 'Attive',
                                    onTap: () {
                                      setState(() => _selectedFilter = 'Attive');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  CustomFilterChip(
                                    label: 'In pausa',
                                    isSelected: _selectedFilter == 'In pausa',
                                    onTap: () {
                                      setState(() => _selectedFilter = 'In pausa');
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  CustomFilterChip(
                                    label: 'Attenzione',
                                    isSelected: _selectedFilter == 'Attenzione',
                                    onTap: () {
                                      setState(() => _selectedFilter = 'Attenzione');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Campaigns count
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '${filteredCampaigns.length} ${filteredCampaigns.length == 1 ? 'campagna' : 'campagne'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),

                    // Campaign cards
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: filteredCampaigns.isEmpty
                          ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Nessuna campagna trovata',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                          : SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final campaign = filteredCampaigns[index];
                            return CampaignCard.full(
                              campaign: campaign,
                              onTap: () {
                                // TODO: Navigate to campaign detail
                                context.router.push(
                                    CampaignDetailRoute(campaign: campaign)
                                );
                              },
                            );
                          },
                          childCount: filteredCampaigns.length,
                        ),
                      ),
                    ),

                    // Bottom spacing for FAB
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 80),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}