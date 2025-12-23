import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/models/metric_config.dart';
import 'package:frontend/core/utils/metric_preferences.dart';
import 'package:frontend/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:frontend/features/dashboard/presentation/widgets/custom_snackbar.dart';

class CustomizeOverviewScreen extends StatefulWidget {
  const CustomizeOverviewScreen({super.key});

  @override
  State<CustomizeOverviewScreen> createState() => _CustomizeOverviewScreenState();
}

class _CustomizeOverviewScreenState extends State<CustomizeOverviewScreen> {
  List<SelectedMetric> _selectedMetrics = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final metrics = await MetricPreferences.loadSelectedMetrics();
    setState(() {
      _selectedMetrics = metrics;
      _isLoading = false;
    });
  }

  Future<void> _saveAndExit() async {
    await MetricPreferences.saveSelectedMetrics(_selectedMetrics);

    // Trigger DashboardCubit to reload preferences
    if (mounted) {
      context.read<DashboardCubit>().reloadMetricsPreferences();
      Navigator.pop(context, true);
    }
  }

  void _toggleMetric(MetricConfig config) {
    setState(() {
      final existingIndex = _selectedMetrics.indexWhere(
            (m) => m.config.key == config.key,
      );

      if (existingIndex >= 0) {
        _selectedMetrics.removeAt(existingIndex);
        for (int i = 0; i < _selectedMetrics.length; i++) {
          _selectedMetrics[i] = _selectedMetrics[i].copyWith(order: i);
        }
      } else if (_selectedMetrics.length < 4) {
        _selectedMetrics.add(
          SelectedMetric(
            config: config,
            order: _selectedMetrics.length,
          ),
        );
      } else {
        CustomSnackBar.showError(
          context,
          message: 'Maximum 4 metrics allowed',
        );
      }
    });
  }

  void _removeMetric(int index) {
    setState(() {
      _selectedMetrics.removeAt(index);
      for (int i = 0; i < _selectedMetrics.length; i++) {
        _selectedMetrics[i] = _selectedMetrics[i].copyWith(order: i);
      }
    });
  }

  void _setMetricColor(int index, Color? color) {
    setState(() {
      _selectedMetrics[index] = _selectedMetrics[index].copyWith(
        color: color,
        clearColor: color == null,
      );
    });
  }

  bool _isMetricSelected(String key) {
    return _selectedMetrics.any((m) => m.config.key == key);
  }

  List<MetricConfig> _getFilteredMetrics(MetricCategory category) {
    final metrics = MetricConfig.allMetrics[category] ?? [];
    if (_searchQuery.isEmpty) return metrics;

    return metrics.where((m) {
      return m.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Overview'),
        actions: [
          TextButton(
            onPressed: _saveAndExit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search metrics',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          if (_selectedMetrics.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your columns (${_selectedMetrics.length}/4)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedMetrics.length == 4)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedMetrics.map((selected) {
                      return _buildSelectedChip(selected);
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: MetricCategory.values.length,
              itemBuilder: (context, index) {
                final category = MetricCategory.values[index];
                final metrics = _getFilteredMetrics(category);
                if (metrics.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCategoryCard(category, metrics),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChip(SelectedMetric selectedMetric) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chipBgColor = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : Theme.of(context).colorScheme.surfaceContainerHigh;

    final textColor = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: () {
        _showColorPicker(selectedMetric);
      },
      child: Chip(
        avatar: selectedMetric.color != null
            ? Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: selectedMetric.color,
            shape: BoxShape.circle,
          ),
        )
            : Icon(
          Icons.palette_outlined,
          size: 16,
          color: textColor.withOpacity(0.7),
        ),
        label: Text(
          selectedMetric.config.displayName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: 18,
          color: textColor.withOpacity(0.7),
        ),
        onDeleted: () {
          final index = _selectedMetrics.indexOf(selectedMetric);
          _removeMetric(index);
        },
        backgroundColor: chipBgColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        side: BorderSide.none,
      ),
    );
  }

  Widget _buildCategoryCard(MetricCategory category, List<MetricConfig> metrics) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          title: Text(
            category.displayName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          initiallyExpanded: category == MetricCategory.recommended,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          children: metrics.map((metric) {
            final isSelected = _isMetricSelected(metric.key);
            return _buildMetricListTile(metric, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMetricListTile(MetricConfig metric, bool isSelected) {
    return InkWell(
      onTap: () => _toggleMetric(metric),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _buildModernCheckbox(isSelected),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                metric.displayName,
                style: const TextStyle(fontSize: 15),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              onPressed: () => _showMetricInfo(metric),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCheckbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isChecked
            ? Theme.of(context).colorScheme.primary
            : (Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3c4043)
            : const Color(0xFFe8eaed)),
      ),
      child: isChecked
          ? const Icon(
        Icons.check,
        size: 18,
        color: Colors.white,
      )
          : null,
    );
  }

  void _showColorPicker(SelectedMetric selectedMetric) {
    final index = _selectedMetrics.indexOf(selectedMetric);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose color for ${selectedMetric.config.displayName}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildColorOption(
                  context,
                  color: null,
                  label: 'Default',
                  isSelected: selectedMetric.color == null,
                  onTap: () {
                    _setMetricColor(index, null);
                    Navigator.pop(context);
                  },
                ),
                ...MetricColors.available.map((color) {
                  return _buildColorOption(
                    context,
                    color: color,
                    label: MetricColors.names[color] ?? '',
                    isSelected: selectedMetric.color == color,
                    onTap: () {
                      _setMetricColor(index, color);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(
      BuildContext context, {
        required Color? color,
        required String label,
        required bool isSelected,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color ?? Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: color == null
                ? Icon(
              Icons.block,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showMetricInfo(MetricConfig metric) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(metric.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(metric.description),
            if (metric.unit != null) ...[
              const SizedBox(height: 12),
              Text(
                'Unit: ${metric.unit}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}