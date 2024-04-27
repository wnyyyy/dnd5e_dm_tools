import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/core/util/server_sync.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_event.dart';
import 'package:dnd5e_dm_tools/features/characters/presentation/character_screen.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:dnd5e_dm_tools/features/header/presentation/header.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/presentation/screen_splitter.dart';
import 'package:dnd5e_dm_tools/features/settings/data/settings_repository.dart';
import 'package:dnd5e_dm_tools/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final databaseProvider = DatabaseProvider.db;
  await ServerSync.checkUpdate(databaseProvider, false);

  runApp(const Dnd5eDmTools());
}

class Dnd5eDmTools extends StatelessWidget {
  const Dnd5eDmTools({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CharacterRepository(DatabaseProvider.db)),
        Provider(create: (_) => RaceRepository(DatabaseProvider.db)),
        Provider(create: (_) => FeatRepository(DatabaseProvider.db)),
        Provider(create: (_) => SettingsRepository(DatabaseProvider.db)),
      ],
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(create: (_) => HeaderCubit()),
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(create: (_) {
              var bloc = CharacterBloc(
                context.read<CharacterRepository>(),
                context.read<RaceRepository>(),
                'Sage',
              );
              bloc.add(const CharacterLoad());
              return bloc;
            }),
            BlocProvider(create: (_) => ScreenSplitterCubit()),
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
                          upperChild: CharacterScreen(),
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
      },
    );
  }
}
