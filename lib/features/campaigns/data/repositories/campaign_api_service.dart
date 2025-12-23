import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign.dart';

class CampaignApiService {
  final String baseUrl;

  CampaignApiService({required this.baseUrl});

  /// Fetch campaigns with optional extended metrics
  Future<List<Campaign>> getCampaigns({
    List<int>? campaignIds,
    List<String>? extendedFields,
    bool useCached = true,
    int maxAgeHours = 6,
  }) async {
    // Build query parameters
    final queryParams = <String, String>{
      'use_cached': useCached.toString(),
      'max_age_hours': maxAgeHours.toString(),
    };

    // Add campaign IDs if specified
    if (campaignIds != null && campaignIds.isNotEmpty) {
      for (var id in campaignIds) {
        queryParams['campaign_ids'] = id.toString();
      }
    }

    // Add extended fields if specified
    if (extendedFields != null && extendedFields.isNotEmpty) {
      for (var field in extendedFields) {
        queryParams['extended_fields'] = field;
      }
    }

    final uri = Uri.parse('$baseUrl/api/campaigns/metrics').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final campaigns = data['campaigns'] as List;
      return campaigns.map((json) => Campaign.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load campaigns: ${response.body}');
    }
  }

  /// Get list of available metric fields
  Future<Map<String, dynamic>> getAvailableFields() async {
    final uri = Uri.parse('$baseUrl/api/campaigns/available-fields');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load available fields');
    }
  }
}