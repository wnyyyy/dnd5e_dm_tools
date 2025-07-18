import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/core/widgets/header.dart';
import 'package:dnd5e_dm_tools/features/main_screen/bloc/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/bloc/main_screen_state.dart';
import 'package:dnd5e_dm_tools/features/onboarding/onboarding_screen.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsInitial) {
          context.read<SettingsCubit>().init();
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SettingsError) {
          return ErrorHandler(error: state.message);
        }
        if (state is SettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SettingsLoaded) {
          final appTheme = AppThemes.buildThemeData(
            state.themeColor,
            state.isDarkMode,
          );
          if (state.isOnboardingComplete) {
            return MaterialApp(
              theme: appTheme,
              home: Scaffold(
                appBar: const Header(),
                body: PopScope(
                  child: Builder(
                    builder: (context) {
                      if (state.name.isEmpty) {
                        return const Center(child: Center());
                      }
                      return BlocBuilder<MainScreenCubit, MainScreenState>(
                        builder: (context, mainScreenState) {
                          return _buildMainContent(mainScreenState);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          } else {
            return MaterialApp(
              theme: appTheme,
              home: const Scaffold(body: OnboardingScreen()),
            );
          }
        }
        return Container();
      },
    );
  }

  Widget _buildMainContent(MainScreenState state) {
    if (state is MainScreenStateCharacter) {
      return const Center(child: Center());
    }
    if (state is MainScreenStateSettings) {
      return const Center(child: Center());
    }
    if (state is MainScreenStateDatabase) {
      return const Center(child: Center());
    }
    return Container();
  }
}
