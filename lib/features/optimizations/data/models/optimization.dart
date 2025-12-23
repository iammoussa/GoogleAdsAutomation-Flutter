class Optimization {
  final int id;
  final int campaignId;
  final String campaignName;
  final String optimizationType;
  final Map<String, dynamic> action;
  final String reason;
  final String? expectedImpact;
  final String priority;
  final double? confidence;
  final String status;
  final String? currentValue;
  final String? proposedValue;
  final String? createdAt;

  Optimization({
    required this.id,
    required this.campaignId,
    required this.campaignName,
    required this.optimizationType,
    required this.action,
    required this.reason,
    this.expectedImpact,
    required this.priority,
    this.confidence,
    required this.status,
    this.currentValue,
    this.proposedValue,
    this.createdAt,
  });

  factory Optimization.fromJson(Map<String, dynamic> json) {
    try {
      return Optimization(
        id: json['id'] as int,
        campaignId: json['campaign_id'] as int,
        campaignName: json['campaign_name'] as String? ?? 'Unknown',
        optimizationType: json['action_type'] as String? ?? 'UNKNOWN',
        action: json['action'] as Map<String, dynamic>? ?? {},
        reason: json['reason'] as String? ?? '',
        expectedImpact: json['expected_impact'] as String?,
        priority: json['priority'] as String? ?? 'MEDIUM',
        confidence: (json['confidence'] as num?)?.toDouble(),
        status: json['status'] as String? ?? 'PENDING',
        currentValue: json['current_value'] as String?,
        proposedValue: json['proposed_value'] as String?,
        createdAt: json['created_at'] as String?,
      );
    } catch (e) {
      print('Error parsing Optimization: $e');
      print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaign_id': campaignId,
      'campaign_name': campaignName,
      'optimization_type': optimizationType,
      'action': action,
      'reason': reason,
      'expected_impact': expectedImpact,
      'priority': priority,
      'confidence': confidence,
      'status': status,
      'current_value': currentValue,
      'proposed_value': proposedValue,
      'created_at': createdAt,
    };
  }
}