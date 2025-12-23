import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/dashboard/presentation/widgets/custom_filter_chip.dart';
import 'package:frontend/features/optimizations/presentation/cubit/optimization_cubit.dart';
import 'package:frontend/features/optimizations/data/models/optimization.dart';
import 'package:frontend/features/optimizations/presentation/widgets/optimization_card.dart';

@RoutePage()
class OptimizationScreen extends StatefulWidget {
  const OptimizationScreen({super.key});

  @override
  State<OptimizationScreen> createState() => _OptimizationScreenState();
}

class _OptimizationScreenState extends State<OptimizationScreen> {
  String _selectedFilter = 'PENDING';

  @override
  void initState() {
    super.initState();
    context.read<OptimizationCubit>().loadOptimizations();
  }

  List<Optimization> _filterOptimizations(List<Optimization> optimizations) {
    if (_selectedFilter == 'ALL') return optimizations;
    return optimizations.where((o) => o.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: BlocConsumer<OptimizationCubit, OptimizationState>(
          listener: (context, state) {
            if (state is OptimizationError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OptimizationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is OptimizationError) {
              return _buildErrorState(context, state.message);
            }

            if (state is OptimizationLoaded) {
              final filteredOptimizations = _filterOptimizations(state.optimizations);

              if (state.optimizations.isEmpty) {
                return _buildEmptyState(context);
              }

              return RefreshIndicator(
                onRefresh: () => context.read<OptimizationCubit>().loadOptimizations(),
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(context, state.optimizations.length),
                    _buildFilters(context),
                    _buildOptimizationsList(context, filteredOptimizations),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

  Widget _buildHeader(BuildContext context, int totalCount) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.orange.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Optimizations',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$totalCount total suggestion${totalCount == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tap a card to expand and see full details',
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CustomFilterChip(
                label: 'Pending',
                isSelected: _selectedFilter == 'PENDING',
                onTap: () => setState(() => _selectedFilter = 'PENDING'),
              ),
              const SizedBox(width: 8),
              CustomFilterChip(
                label: 'Applied',
                isSelected: _selectedFilter == 'APPLIED',
                onTap: () => setState(() => _selectedFilter = 'APPLIED'),
              ),
              const SizedBox(width: 8),
              CustomFilterChip(
                label: 'Dismissed',
                isSelected: _selectedFilter == 'DISMISSED',
                onTap: () => setState(() => _selectedFilter = 'DISMISSED'),
              ),
              const SizedBox(width: 8),
              CustomFilterChip(
                label: 'All',
                isSelected: _selectedFilter == 'ALL',
                onTap: () => setState(() => _selectedFilter = 'ALL'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptimizationsList(BuildContext context, List<Optimization> optimizations) {
    if (optimizations.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.filter_list_off, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No results for this filter',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final optimization = optimizations[index];
            return OptimizationCard(
              optimization: optimization,
              onApply: () => _showApplyDialog(context, optimization),
              onDismiss: () => _showDismissDialog(context, optimization),
            );
          },
          childCount: optimizations.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.green.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'All Optimized!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No optimization suggestions at the moment. Your campaigns are performing well!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => context.read<OptimizationCubit>().loadOptimizations(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reload'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading optimizations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<OptimizationCubit>().loadOptimizations(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showApplyDialog(BuildContext context, Optimization optimization) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apply Optimization'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Do you want to apply this optimization to campaign "${optimization.campaignName}"?',
            ),
            if (optimization.currentValue != null && optimization.proposedValue != null) ...[
              const SizedBox(height: 16),
              Text(
                'Current value: ${optimization.currentValue}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Proposed value: ${optimization.proposedValue}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OptimizationCubit>().applyOptimization(optimization.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Optimization applied successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showDismissDialog(BuildContext context, Optimization optimization) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dismiss Suggestion'),
        content: const Text(
          'Are you sure you want to dismiss this suggestion? It will no longer be shown.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<OptimizationCubit>().dismissOptimization(optimization.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Suggestion dismissed'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}