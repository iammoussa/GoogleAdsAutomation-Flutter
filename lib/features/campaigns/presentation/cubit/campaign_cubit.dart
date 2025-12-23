import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';
import '../../data/repositories/campaign_repository.dart';

part 'campaign_state.dart';

class CampaignCubit extends Cubit<CampaignState> {
  final CampaignRepository campaignRepository;
  bool _isLiveMode = false;

  CampaignCubit({required this.campaignRepository}) : super(CampaignInitial());

  bool get isLiveMode => _isLiveMode;

  void toggleLiveMode() {
    _isLiveMode = !_isLiveMode;
    print('Live mode ${_isLiveMode ? "enabled" : "disabled"}');
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    try {
      emit(CampaignLoading());
      print('Loading campaigns (live: $_isLiveMode)');

      // Repository now returns List<Campaign> directly
      final campaigns = await campaignRepository.getCampaigns(live: _isLiveMode);

      final source = _isLiveMode ? 'live' : 'database';
      final lastSync = DateTime.now().toIso8601String();

      print('Loaded ${campaigns.length} campaigns from $source');
      emit(CampaignLoaded(
        campaigns,
        source: source,
        lastSync: lastSync,
      ));
    } catch (e) {
      print('Failed to load campaigns: $e');
      emit(CampaignError(e.toString()));
    }
  }

  Future<void> syncCampaigns() async {
    try {
      print('Syncing campaigns...');
      await campaignRepository.getCampaigns();
      await loadCampaigns();
      print('Campaigns synced successfully');
    } catch (e) {
      print('Failed to sync campaigns: $e');
      emit(CampaignError(e.toString()));
    }
  }
}