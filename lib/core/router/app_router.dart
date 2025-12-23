import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:frontend/features/campaigns/data/models/campaign.dart';
import 'package:frontend/features/campaigns/presentation/screens/campaign_detail_screen.dart';
import 'package:frontend/features/campaigns/presentation/screens/campaign_screen.dart';
import 'package:frontend/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:frontend/features/optimizations/presentation/screens/optimization_screen.dart';
import 'package:frontend/features/settings/presentation/screens/settings_screen.dart';
import 'package:frontend/features/navigation/navigation_shell.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: NavigationShellRoute.page,
      path: '/',
      initial: true,
      children: [
        AutoRoute(
          page: DashboardRoute.page,
          path: 'dashboard',
          initial: true,
        ),
        AutoRoute(
          page: CampaignRoute.page,
          path: 'campaigns',
        ),
        AutoRoute(
          page: OptimizationRoute.page,
          path: 'optimizations',
        ),
        AutoRoute(
          page: SettingsRoute.page,
          path: 'settings',
        ),
      ],
    ),
    // Campaign detail FUORI dalla shell (senza bottom nav)
    AutoRoute(
      page: CampaignDetailRoute.page,
      path: '/campaign-detail',  // ← Ora può iniziare con "/"
    ),
  ];
}