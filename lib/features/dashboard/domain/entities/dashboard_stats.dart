class DashboardStats {
  final double spend;
  final double spendChange;
  final int conversions;
  final double conversionsChange;
  final double costPerConversion;
  final double costPerConversionChange;
  final double conversionValue;
  final double conversionValueChange;

  DashboardStats({
    required this.spend,
    required this.spendChange,
    required this.conversions,
    required this.conversionsChange,
    required this.costPerConversion,
    required this.costPerConversionChange,
    required this.conversionValue,
    required this.conversionValueChange,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      spend: (json['spend'] as num?)?.toDouble() ?? 0.0,
      spendChange: (json['spend_change'] as num?)?.toDouble() ?? 0.0,
      conversions: json['conversions'] as int? ?? 0,
      conversionsChange: (json['conversions_change'] as num?)?.toDouble() ?? 0.0,
      costPerConversion: (json['cost_per_conversion'] as num?)?.toDouble() ?? 0.0,
      costPerConversionChange: (json['cost_per_conv_change'] as num?)?.toDouble() ?? 0.0,
      conversionValue: (json['conversion_value'] as num?)?.toDouble() ?? 0.0,
      conversionValueChange: (json['value_change'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'spend': spend,
      'spend_change': spendChange,
      'conversions': conversions,
      'conversions_change': conversionsChange,
      'cost_per_conversion': costPerConversion,
      'cost_per_conv_change': costPerConversionChange,
      'conversion_value': conversionValue,
      'value_change': conversionValueChange,
    };
  }
}