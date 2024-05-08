import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/character_screen.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:dnd5e_dm_tools/features/header/presentation/header.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_states.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/widgets/main_drawer.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_bloc.dart';
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
    return BlocBuilder<HeaderCubit, HeaderState>(
      builder: (context, state) {
        context.read<ThemeCubit>().updateTheme(state.isDarkMode);
        return BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, themeData) {
            return MaterialApp(
              theme: themeData,
              home: Scaffold(
                drawer: const MainDrawer(),
                appBar: const Header(),
                body: PopScope(
                  child: BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (BuildContext context, SettingsState state) {
                      if (state is SettingsInitial) {
                        context.read<SettingsCubit>().init();
                      }
                      if (state is SettingsLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (state is SettingsError) {
                        return Center(
                          child: ErrorHandler(error: state.message),
                        );
                      }
                      if (state is SettingsLoaded) {
                        return BlocBuilder<RulesCubit, RulesState>(
                          builder: (context, state) {
                            if (state is RulesStateInitial) {
                              context.read<RulesCubit>().loadRules();
                            }
                            if (state is RulesStateError) {
                              return ErrorHandler(error: state.message);
                            }
                            if (state is RulesStateLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is RulesStateLoaded) {
                              return BlocBuilder<MainScreenCubit,
                                  MainScreenState>(
                                builder: (context, state) {
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
                                    return const Center(
                                      child: SettingsScreen(),
                                    );
                                  }
                                  return Container();
                                },
                              );
                            }
                            return Container();
                          },
                        );
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
