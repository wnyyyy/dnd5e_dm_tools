import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:dnd5e_dm_tools/features/header/presentation/header.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/presentation/screen_splitter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const Dnd5eDmTools());
}

class Dnd5eDmTools extends StatelessWidget {
  const Dnd5eDmTools({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ScreenSplitterCubit()),
        BlocProvider(create: (_) => HeaderCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
      ],
      child: BlocBuilder<HeaderCubit, HeaderState>(
        builder: (context, state) {
          context.read<ThemeCubit>().updateTheme(state.isDarkMode);
          context.read<HeaderCubit>().setPageTitle('D&D 5e DM Tools');
          return BlocBuilder<ThemeCubit, ThemeData>(
            builder: (context, themeData) {
              return MaterialApp(
                title: 'D&D 5e DM Tools',
                theme: themeData,
                home: const Scaffold(
                  appBar: Header(),
                  body: Center(
                    child: ScreenSplitter(
                      upperChild: Placeholder(),
                      lowerChild: Placeholder(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
