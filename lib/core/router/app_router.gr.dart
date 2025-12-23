// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    CampaignDetailRoute.name: (routeData) {
      final args = routeData.argsAs<CampaignDetailRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: CampaignDetailScreen(
          key: args.key,
          campaign: args.campaign,
        ),
      );
    },
    CampaignRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const CampaignScreen(),
      );
    },
    DashboardRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const DashboardScreen(),
      );
    },
    NavigationShellRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NavigationShell(),
      );
    },
    OptimizationRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const OptimizationScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
  };
}

/// generated route for
/// [CampaignDetailScreen]
class CampaignDetailRoute extends PageRouteInfo<CampaignDetailRouteArgs> {
  CampaignDetailRoute({
    Key? key,
    required Campaign campaign,
    List<PageRouteInfo>? children,
  }) : super(
          CampaignDetailRoute.name,
          args: CampaignDetailRouteArgs(
            key: key,
            campaign: campaign,
          ),
          initialChildren: children,
        );

  static const String name = 'CampaignDetailRoute';

  static const PageInfo<CampaignDetailRouteArgs> page =
      PageInfo<CampaignDetailRouteArgs>(name);
}

class CampaignDetailRouteArgs {
  const CampaignDetailRouteArgs({
    this.key,
    required this.campaign,
  });

  final Key? key;

  final Campaign campaign;

  @override
  String toString() {
    return 'CampaignDetailRouteArgs{key: $key, campaign: $campaign}';
  }
}

/// generated route for
/// [CampaignScreen]
class CampaignRoute extends PageRouteInfo<void> {
  const CampaignRoute({List<PageRouteInfo>? children})
      : super(
          CampaignRoute.name,
          initialChildren: children,
        );

  static const String name = 'CampaignRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [DashboardScreen]
class DashboardRoute extends PageRouteInfo<void> {
  const DashboardRoute({List<PageRouteInfo>? children})
      : super(
          DashboardRoute.name,
          initialChildren: children,
        );

  static const String name = 'DashboardRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NavigationShell]
class NavigationShellRoute extends PageRouteInfo<void> {
  const NavigationShellRoute({List<PageRouteInfo>? children})
      : super(
          NavigationShellRoute.name,
          initialChildren: children,
        );

  static const String name = 'NavigationShellRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [OptimizationScreen]
class OptimizationRoute extends PageRouteInfo<void> {
  const OptimizationRoute({List<PageRouteInfo>? children})
      : super(
          OptimizationRoute.name,
          initialChildren: children,
        );

  static const String name = 'OptimizationRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}
