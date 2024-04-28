import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/character_screen.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:dnd5e_dm_tools/features/header/presentation/header.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_states.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/widgets/main_drawer.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/presentation/screen_splitter.dart';
import 'package:dnd5e_dm_tools/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
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
                drawer: MainDrawer(),
                appBar: Header(),
                body: PopScope(
                  child: BlocBuilder<MainScreenCubit, MainScreenState>(
                    builder: (context, state) {
                      if (state is MainScreenStateCharacter) {
                        return Center(
                          child: ScreenSplitter(
                            upperChild: CharacterScreen(),
                            lowerChild: Placeholder(),
                          ),
                        );
                      }
                      if (state is MainScreenStateParty) {
                        return Center(
                          child: Placeholder(),
                        );
                      }
                      if (state is MainScreenStateSettings) {
                        return Center(
                          child: SettingsScreen(),
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
