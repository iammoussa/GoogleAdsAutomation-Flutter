import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_cubit.dart' as app_theme;
import 'package:frontend/core/network/api_service.dart';
import 'package:frontend/features/campaigns/data/repositories/campaign_repository.dart';
import 'package:frontend/features/campaigns/presentation/cubit/campaign_cubit.dart';
import 'package:frontend/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:frontend/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:frontend/features/optimizations/data/repositories/optimization_repository.dart';
import 'package:frontend/features/optimizations/presentation/cubit/optimization_cubit.dart';

import 'managers/logger_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger
  AppLogger().init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => CampaignRepository(apiService: _apiService),
        ),
        RepositoryProvider(
          create: (context) => DashboardRepository(apiService: _apiService),
        ),
        RepositoryProvider(
          create: (context) => OptimizationRepository(apiService: _apiService),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          // Theme Cubit (must be first!)
          BlocProvider(
            create: (context) => app_theme.ThemeCubit(),
          ),

          // Campaign Cubit
          BlocProvider(
            create: (context) => CampaignCubit(
              campaignRepository: context.read<CampaignRepository>(),
            ),
          ),

          // Dashboard Cubit
          BlocProvider(
            create: (context) => DashboardCubit(
              dashboardRepository: context.read<DashboardRepository>(),
              campaignRepository: context.read<CampaignRepository>(),
            )..loadDashboard(),
          ),

          // Optimization Cubit - ADDED!
          BlocProvider(
            create: (context) => OptimizationCubit(
              optimizationRepository: context.read<OptimizationRepository>(),
            ),
          ),
        ],
        child: BlocBuilder<app_theme.ThemeCubit, app_theme.ThemeState>(
          builder: (context, themeState) {
            // Update system brightness when it changes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final brightness = MediaQuery.of(context).platformBrightness;
              context.read<app_theme.ThemeCubit>().updateSystemBrightness(brightness);
            });

            return MaterialApp.router(
              title: 'Google Ads Automation',
              debugShowCheckedModeBanner: false,

              // Theme configuration
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: _getFlutterThemeMode(themeState.themeMode),

              // Router configuration
              routerConfig: _appRouter.config(),
            );
          },
        ),
      ),
    );
  }

  // Convert app ThemeMode to Flutter ThemeMode
  ThemeMode _getFlutterThemeMode(app_theme.ThemeMode mode) {
    switch (mode) {
      case app_theme.ThemeMode.light:
        return ThemeMode.light;
      case app_theme.ThemeMode.dark:
        return ThemeMode.dark;
      case app_theme.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}