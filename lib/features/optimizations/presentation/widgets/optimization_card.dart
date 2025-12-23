import 'package:flutter/material.dart';
import 'package:frontend/features/optimizations/data/models/optimization.dart';

class OptimizationCard extends StatefulWidget {
  final Optimization optimization;
  final VoidCallback onApply;
  final VoidCallback onDismiss;

  const OptimizationCard({
    super.key,
    required this.optimization,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  State<OptimizationCard> createState() => _OptimizationCardState();
}

class _OptimizationCardState extends State<OptimizationCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDismissed = widget.optimization.status == 'DISMISSED';
    final isApplied = widget.optimization.status == 'APPLIED';
    final canInteract = !isDismissed && !isApplied;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getTypeColor().withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type badge and priority
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getTypeIcon(), size: 14, color: _getTypeColor()),
                      const SizedBox(width: 6),
                      Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Priority badge
                _buildPriorityBadge(),
                const SizedBox(width: 8),
                // Expand/collapse icon with rotation animation
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Campaign name - always visible
            Text(
              widget.optimization.campaignName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Current vs Proposed values - always visible
            if (widget.optimization.currentValue != null &&
                widget.optimization.proposedValue != null)
              _buildValueComparison(),

            // Animated expandable content
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              clipBehavior: Clip.none,
              child: _isExpanded
                  ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Reason - only when expanded
                  Text(
                    widget.optimization.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),

                  // Expected impact - only when expanded
                  if (widget.optimization.expectedImpact != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 16,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Impatto: ${widget.optimization.expectedImpact}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Confidence score - only when expanded
                  if (widget.optimization.confidence != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Confidenza: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          '${(widget.optimization.confidence! * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              )
                  : const SizedBox(
                width: double.infinity,
                height: 0,
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons - always visible
            if (canInteract)
              Row(
                children: [
                  // Rifiuta button - Grey style
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Rifiuta',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Applica button - Blue style
                  Expanded(
                    child: ElevatedButton(
                      onPressed: widget.onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Applica',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Status badges for applied/dismissed
            if (isApplied)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Applicata',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            if (isDismissed)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.block,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rifiutata',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
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

  Widget _buildValueComparison() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Current value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attuale',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.optimization.currentValue!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.grey.shade400,
            ),
          ),

          // Proposed value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Proposto',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.optimization.proposedValue!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge() {
    Color color;
    String label;

    switch (widget.optimization.priority.toUpperCase()) {
      case 'HIGH':
        color = Colors.red;
        label = 'ALTA';
        break;
      case 'MEDIUM':
        color = Colors.orange;
        label = 'MEDIA';
        break;
      case 'LOW':
        color = Colors.blue;
        label = 'BASSA';
        break;
      default:
        color = Colors.grey;
        label = widget.optimization.priority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (widget.optimization.optimizationType.toUpperCase()) {
      case 'BUDGET_INCREASE':
      case 'BUDGET_DECREASE':
        return Colors.blue;
      case 'BID_ADJUSTMENT':
      case 'BID_INCREASE':
      case 'BID_DECREASE':
        return Colors.orange;
      case 'KEYWORD_ADD':
      case 'KEYWORD_REMOVE':
      case 'NEGATIVE_KEYWORD':
        return Colors.purple;
      case 'PAUSE_CAMPAIGN':
      case 'ENABLE_CAMPAIGN':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.optimization.optimizationType.toUpperCase()) {
      case 'BUDGET_INCREASE':
      case 'BUDGET_DECREASE':
        return Icons.account_balance_wallet;
      case 'BID_ADJUSTMENT':
      case 'BID_INCREASE':
      case 'BID_DECREASE':
        return Icons.gavel;
      case 'KEYWORD_ADD':
      case 'KEYWORD_REMOVE':
      case 'NEGATIVE_KEYWORD':
        return Icons.key;
      case 'PAUSE_CAMPAIGN':
        return Icons.pause;
      case 'ENABLE_CAMPAIGN':
        return Icons.play_arrow;
      default:
        return Icons.lightbulb;
    }
  }

  String _getTypeLabel() {
    switch (widget.optimization.optimizationType.toUpperCase()) {
      case 'BUDGET_INCREASE':
        return 'Aumenta Budget';
      case 'BUDGET_DECREASE':
        return 'Riduci Budget';
      case 'BID_ADJUSTMENT':
        return 'Aggiusta Offerta';
      case 'BID_INCREASE':
        return 'Aumenta Offerta';
      case 'BID_DECREASE':
        return 'Riduci Offerta';
      case 'KEYWORD_ADD':
        return 'Aggiungi Keyword';
      case 'KEYWORD_REMOVE':
        return 'Rimuovi Keyword';
      case 'NEGATIVE_KEYWORD':
        return 'Keyword Negativa';
      case 'PAUSE_CAMPAIGN':
        return 'Pausa Campagna';
      case 'ENABLE_CAMPAIGN':
        return 'Attiva Campagna';
      default:
        return widget.optimization.optimizationType;
    }
  }
}