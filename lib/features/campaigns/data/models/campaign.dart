class Campaign {
  // Base identifiers
  final String campaignId;
  final String campaignName;
  final String status;
  final String? lastUpdated;

  // Performance metrics (always present)
  final int impressions;
  final int clicks;
  final double cost;
  final double ctr;
  final int conversions;
  final double conversionValue;
  final double costPerConversion;
  final double cpc;

  // Extended metrics (nullable - only present if user configures them)
  final double? averageCpc;
  final double? averageCpm;
  final double? conversionRate;
  final double? costPerAction;
  final double? roas;

  // Viewability metrics
  final int? viewableImpressions;
  final double? viewableCtr;

  // Attribution metrics
  final double? allConversions;
  final double? allConversionValue;

  // Engagement metrics
  final int? interactions;
  final double? interactionRate;
  final int? engagements;
  final double? engagementRate;

  // Competitive metrics
  final double? searchImpressionShare;
  final double? searchTopImpressionShare;

  Campaign({
    required this.campaignId,
    required this.campaignName,
    required this.status,
    this.lastUpdated,
    required this.impressions,
    required this.clicks,
    required this.cost,
    required this.ctr,
    required this.conversions,
    required this.conversionValue,
    required this.costPerConversion,
    required this.cpc,
    this.averageCpc,
    this.averageCpm,
    this.conversionRate,
    this.costPerAction,
    this.roas,
    this.viewableImpressions,
    this.viewableCtr,
    this.allConversions,
    this.allConversionValue,
    this.interactions,
    this.interactionRate,
    this.engagements,
    this.engagementRate,
    this.searchImpressionShare,
    this.searchTopImpressionShare,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      campaignId: json['campaign_id'].toString(),
      campaignName: json['campaign_name'] as String,
      status: json['status'] as String? ?? 'UNKNOWN',
      lastUpdated: json['timestamp'] as String?,

      // Base metrics
      impressions: json['impressions'] as int? ?? 0,
      clicks: json['clicks'] as int? ?? 0,
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
      ctr: (json['ctr'] as num?)?.toDouble() ?? 0.0,
      conversions: (json['conversions'] as num?)?.toInt() ?? 0,
      conversionValue: (json['conv_value'] as num?)?.toDouble() ?? 0.0,
      costPerConversion: (json['cost_per_conv'] as num?)?.toDouble() ?? 0.0,
      cpc: (json['cpc'] as num).toDouble() ?? 0.0,

      // Extended metrics (nullable)
      averageCpc: (json['cpc'] as num?)?.toDouble(),
      averageCpm: (json['avg_cpm'] as num?)?.toDouble(),
      conversionRate: (json['conversion_rate'] as num?)?.toDouble(),
      costPerAction: (json['cost_per_action'] as num?)?.toDouble(),
      roas: (json['roas'] as num?)?.toDouble(),

      // Viewability
      viewableImpressions: json['viewable_impressions'] as int?,
      viewableCtr: (json['viewable_ctr'] as num?)?.toDouble(),

      // Attribution
      allConversions: (json['all_conversions'] as num?)?.toDouble(),
      allConversionValue: (json['all_conversion_value'] as num?)?.toDouble(),

      // Engagement
      interactions: json['interactions'] as int?,
      interactionRate: (json['interaction_rate'] as num?)?.toDouble(),
      engagements: json['engagements'] as int?,
      engagementRate: (json['engagement_rate'] as num?)?.toDouble(),

      // Competitive
      searchImpressionShare: (json['search_impression_share'] as num?)?.toDouble(),
      searchTopImpressionShare: (json['search_top_impression_share'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'status': status,
      'timestamp': lastUpdated,
      'impressions': impressions,
      'clicks': clicks,
      'cost': cost,
      'ctr': ctr,
      'conversions': conversions,
      'conv_value': conversionValue,
      'cost_per_conv': costPerConversion,
      if (averageCpc != null) 'cpc': averageCpc,
      if (averageCpm != null) 'avg_cpm': averageCpm,
      if (conversionRate != null) 'conversion_rate': conversionRate,
      if (costPerAction != null) 'cost_per_action': costPerAction,
      if (roas != null) 'roas': roas,
      if (viewableImpressions != null) 'viewable_impressions': viewableImpressions,
      if (viewableCtr != null) 'viewable_ctr': viewableCtr,
      if (allConversions != null) 'all_conversions': allConversions,
      if (allConversionValue != null) 'all_conversion_value': allConversionValue,
      if (interactions != null) 'interactions': interactions,
      if (interactionRate != null) 'interaction_rate': interactionRate,
      if (engagements != null) 'engagements': engagements,
      if (engagementRate != null) 'engagement_rate': engagementRate,
      if (searchImpressionShare != null) 'search_impression_share': searchImpressionShare,
      if (searchTopImpressionShare != null) 'search_top_impression_share': searchTopImpressionShare,
    };
  }

  // Helper to get metric value by key (for dynamic metric display)
  double? getMetricValue(String metricKey) {
    switch (metricKey) {
      case 'cost':
        return cost;
      case 'conversions':
        return conversions.toDouble();
      case 'conversion_value':
        return conversionValue;
      case 'cost_per_conv':
        return costPerConversion;
      case 'impressions':
        return impressions.toDouble();
      case 'clicks':
        return clicks.toDouble();
      case 'ctr':
        return ctr;
      case 'average_cpc':
        return averageCpc;
      case 'average_cpm':
        return averageCpm;
      case 'conversion_rate':
        return conversionRate;
      case 'cost_per_action':
        return costPerAction;
      case 'roas':
        return roas;
      case 'viewable_impressions':
        return viewableImpressions?.toDouble();
      case 'viewable_ctr':
        return viewableCtr;
      case 'all_conversions':
        return allConversions;
      case 'all_conversion_value':
        return allConversionValue;
      case 'interactions':
        return interactions?.toDouble();
      case 'interaction_rate':
        return interactionRate;
      case 'engagements':
        return engagements?.toDouble();
      case 'engagement_rate':
        return engagementRate;
      case 'search_impression_share':
        return searchImpressionShare;
      case 'search_top_impression_share':
        return searchTopImpressionShare;
      default:
        return null;
    }
  }
}