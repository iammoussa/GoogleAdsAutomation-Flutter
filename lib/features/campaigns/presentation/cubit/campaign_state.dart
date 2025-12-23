part of 'campaign_cubit.dart';

abstract class CampaignState {}

class CampaignInitial extends CampaignState {}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final List<Campaign> campaigns;
  final String source;
  final String? lastSync;

  CampaignLoaded(
      this.campaigns, {
        this.source = 'unknown',
        this.lastSync,
      });
}

class CampaignError extends CampaignState {
  final String message;

  CampaignError(this.message);
}