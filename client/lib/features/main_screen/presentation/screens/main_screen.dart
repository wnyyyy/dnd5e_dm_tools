import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/screens/campaign_screen.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/character_screen.dart';
import 'package:dnd5e_dm_tools/features/database_editor/database_editor.dart';
import 'package:dnd5e_dm_tools/features/header/header.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_states.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/widgets/main_drawer.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/presentation/screen_splitter.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:dnd5e_dm_tools/features/settings/presentation/settings_screen.dart';
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
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is SettingsError) {
          return ErrorHandler(error: state.message);
        }
        if (state is SettingsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is SettingsLoaded) {
          final appTheme =
              AppThemes.buildThemeData(state.themeColor, state.isDarkMode);
          return MaterialApp(
            theme: appTheme,
            home: Scaffold(
              drawer: const MainDrawer(),
              appBar: const Header(),
              body: PopScope(
                child: Builder(
                  builder: (context) {
                    if (state.name.isEmpty) {
                      return Center(
                        child: SettingsScreen(),
                      );
                    }
                    return _loadMainScreen(context, state);
                  },
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _loadMainScreen(BuildContext context, SettingsLoaded settingsState) {
    return BlocBuilder<RulesCubit, RulesState>(
      builder: (context, rulesState) {
        if (rulesState is RulesStateInitial) {
          context.read<RulesCubit>().loadRules();
          return Container();
        }
        if (rulesState is RulesStateError) {
          return ErrorHandler(error: rulesState.message);
        }
        if (rulesState is RulesStateLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (rulesState is RulesStateLoaded) {
          return BlocBuilder<MainScreenCubit, MainScreenState>(
            builder: (context, mainScreenState) {
              return _buildMainContent(mainScreenState);
            },
          );
        }

        return Container();
      },
    );
  }

  Widget _buildMainContent(MainScreenState state) {
    if (state is MainScreenStateCharacter) {
      return const Center(
        child: ScreenSplitter(
          upperChild: CharacterScreen(),
          lowerChild: Placeholder(),
        ),
      );
    }
    if (state is MainScreenStateParty) {
      return const Center(
        child: Placeholder(),
      );
    }
    if (state is MainScreenStateSettings) {
      return Center(
        child: SettingsScreen(),
      );
    }
    if (state is MainScreenStateDatabase) {
      return const Center(
        child: DatabaseEditorScreen(),
      );
    }
    if (state is MainScreenStateCampaign) {
      return const Center(
        child: CampaignScreen(),
      );
    }
    return Container();
  }
}
