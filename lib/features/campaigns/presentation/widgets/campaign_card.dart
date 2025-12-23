import 'package:flutter/material.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';

enum CampaignCardStyle {
  full,
  compact,
  minimal,
}

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  final CampaignCardStyle style;
  final bool showMetric;
  final bool showSubtitle;
  final bool showCTR;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onTap,
    this.style = CampaignCardStyle.full,
    this.showMetric = true,
    this.showSubtitle = true,
    this.showCTR = true,
  });

  const CampaignCard.dashboard({
    super.key,
    required this.campaign,
    this.onTap,
  })  : style = CampaignCardStyle.compact,
        showMetric = true,
        showSubtitle = true,
        showCTR = true;

  const CampaignCard.full({
    super.key,
    required this.campaign,
    this.onTap,
  })  : style = CampaignCardStyle.full,
        showMetric = true,
        showSubtitle = true,
        showCTR = true;

  const CampaignCard.minimal({
    super.key,
    required this.campaign,
    this.onTap,
  })  : style = CampaignCardStyle.minimal,
        showMetric = false,
        showSubtitle = false,
        showCTR = false;

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconFromCampaignName(campaign.campaignName);
    final iconColor = _getColorFromStatus(campaign.status);
    final statusColor = _getStatusColor(campaign.status);
    final statusText = _getStatusText(campaign.status);

    // Calculate metrics
    final hasConversions = campaign.conversions > 0;

    // Determine if needs attention
    final showBorder = campaign.cost > 1000 || campaign.ctr < 1.0;

    // Build subtitle based on style
    String subtitle;
    switch (style) {
      case CampaignCardStyle.full:
        subtitle =
        '${campaign.conversions.toInt()} Conversioni • ${campaign.clicks} Click • ${campaign.impressions} Impressioni';
        break;
      case CampaignCardStyle.compact:
        subtitle = hasConversions
            ? '${campaign.conversions.toInt()} Conversioni • ${campaign.clicks} Click'
            : '${campaign.clicks} Click';
        break;
      case CampaignCardStyle.minimal:
        subtitle = 'ID: ${campaign.campaignId}';
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(style == CampaignCardStyle.minimal ? 12 : 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: showBorder && style != CampaignCardStyle.minimal
              ? Border.all(
            color: iconColor.withOpacity(0.3),
            width: 2,
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                if (style != CampaignCardStyle.minimal) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconData, color: iconColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                // Name and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        campaign.campaignName,
                        style: TextStyle(
                          fontSize:
                          style == CampaignCardStyle.minimal ? 12 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Always show COST
                if (showMetric && style != CampaignCardStyle.minimal) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Spesa',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '€${campaign.cost.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            // Subtitle (NO MORE PROGRESS BAR)
            if (showSubtitle) ...[
              SizedBox(height: style == CampaignCardStyle.minimal ? 8 : 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showCTR && style != CampaignCardStyle.minimal) ...[
                    Text(
                      'CTR ${campaign.ctr.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconFromCampaignName(String name) {
    final nameLower = name.toLowerCase();
    if (nameLower.contains('shopping') ||
        nameLower.contains('saldi') ||
        nameLower.contains('sale')) {
      return Icons.shopping_bag;
    } else if (nameLower.contains('brand') ||
        nameLower.contains('awareness')) {
      return Icons.campaign;
    } else if (nameLower.contains('retarget') ||
        nameLower.contains('remarketing')) {
      return Icons.search;
    } else if (nameLower.contains('display')) {
      return Icons.image;
    } else if (nameLower.contains('video')) {
      return Icons.play_circle;
    }
    return Icons.campaign;
  }

  Color _getColorFromStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return Colors.green;
      case 'PAUSED':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return Colors.green;
      case 'PAUSED':
        return Colors.grey;
      default:
        return Colors.red;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ENABLED':
        return 'Attiva';
      case 'PAUSED':
        return 'In Pausa';
      default:
        return status;
    }
  }
}