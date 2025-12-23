import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/theme/theme_cubit.dart' as app_theme;
import 'package:frontend/features/dashboard/presentation/widgets/opportunity_card.dart';
import 'package:frontend/features/dashboard/presentation/widgets/custom_snackbar.dart';
import 'customize_overview_screen.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your experience',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Dashboard Section
              _buildSection(
                context,
                title: 'Dashboard',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.dashboard_customize,
                    title: 'Customize Overview',
                    subtitle: 'Select metrics to display',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CustomizeOverviewScreen(),
                        ),
                      );

                      // Notify that metrics were updated
                      if (result == true && mounted) {
                        CustomSnackBar.showSuccess(
                          context,
                          message: 'Metrics updated successfully',
                        );
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Appearance Section
              _buildSection(
                context,
                title: 'Appearance',
                children: [
                  _buildThemeTile(context),
                ],
              ),

              const SizedBox(height: 16),

              // Debug Section
              _buildSection(
                context,
                title: 'Debug',
                children: [
                  _buildDebugAlwaysShowCardsTile(context),
                  _buildResetDismissedCardsTile(context),
                ],
              ),

              const SizedBox(height: 16),

              // Account Section
              _buildSection(
                context,
                title: 'Account',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.person_outline,
                    title: 'Profile',
                    subtitle: 'Manage your profile',
                    onTap: () {
                      CustomSnackBar.showInfo(
                        context,
                        message: 'Coming soon!',
                      );
                    },
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    onTap: () {
                      CustomSnackBar.showInfo(
                        context,
                        message: 'Coming soon!',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSection(
                context,
                title: 'About',
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help',
                    subtitle: 'FAQ and support',
                    onTap: () {
                      CustomSnackBar.showInfo(
                        context,
                        message: 'Coming soon!',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return BlocBuilder<app_theme.ThemeCubit, app_theme.ThemeState>(
      builder: (context, themeState) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getThemeIcon(themeState.themeMode),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: const Text(
            'Theme',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            _getThemeLabel(themeState.themeMode),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
            ),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            _showThemePicker(context, themeState.themeMode);
          },
        );
      },
    );
  }

  Widget _buildDebugAlwaysShowCardsTile(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.bug_report,
              color: Colors.orange,
            ),
          ),
          title: const Text(
            'Always show cards',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Debug: ignore dismissals',
            style: TextStyle(fontSize: 14),
          ),
          value: OpportunityCardManager.debugAlwaysShow,
          onChanged: (value) {
            setState(() {
              OpportunityCardManager.debugAlwaysShow = value;
            });
            CustomSnackBar.showInfo(
              context,
              message: value
                  ? 'Debug: Cards always visible'
                  : 'Debug: Respects dismissals',
            );
          },
        );
      },
    );
  }

  Widget _buildResetDismissedCardsTile(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.refresh,
          color: Colors.red,
        ),
      ),
      title: const Text(
        'Reset hidden cards',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Show all cards again',
        style: TextStyle(fontSize: 14),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset hidden cards'),
            content: const Text(
              'Do you want to show all hidden cards again?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Reset'),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          await OpportunityCardManager.resetAll();
          if (mounted) {
            CustomSnackBar.showSuccess(
              context,
              message: 'All cards are visible again',
            );
          }
        }
      },
    );
  }

  Widget _buildListTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required VoidCallback? onTap,
      }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
        ),
      ),
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  void _showThemePicker(BuildContext context, app_theme.ThemeMode currentMode) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Theme',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildThemeOption(
              context,
              icon: Icons.light_mode,
              title: 'Light Mode',
              subtitle: 'Always use light theme',
              mode: app_theme.ThemeMode.light,
              currentMode: currentMode,
            ),
            _buildThemeOption(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              subtitle: 'Always use dark theme',
              mode: app_theme.ThemeMode.dark,
              currentMode: currentMode,
            ),
            _buildThemeOption(
              context,
              icon: Icons.brightness_auto,
              title: 'Automatic',
              subtitle: 'Follow system settings',
              mode: app_theme.ThemeMode.system,
              currentMode: currentMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required app_theme.ThemeMode mode,
        required app_theme.ThemeMode currentMode,
      }) {
    final isSelected = mode == currentMode;

    return ListTile(
      leading: Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        context.read<app_theme.ThemeCubit>().setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  IconData _getThemeIcon(app_theme.ThemeMode mode) {
    switch (mode) {
      case app_theme.ThemeMode.light:
        return Icons.light_mode;
      case app_theme.ThemeMode.dark:
        return Icons.dark_mode;
      case app_theme.ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _getThemeLabel(app_theme.ThemeMode mode) {
    switch (mode) {
      case app_theme.ThemeMode.light:
        return 'Light Mode';
      case app_theme.ThemeMode.dark:
        return 'Dark Mode';
      case app_theme.ThemeMode.system:
        return 'Automatic (System)';
    }
  }
}