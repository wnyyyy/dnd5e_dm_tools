import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/character_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/class_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feat_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/race_repository.dart';
import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/screens/main_screen.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
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
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  runApp(Dnd5eDmTools());
}

class Dnd5eDmTools extends StatelessWidget {
  final DatabaseProvider databaseProvider = DatabaseProvider();

  Dnd5eDmTools({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CharacterRepository(databaseProvider)),
        Provider(create: (_) => RaceRepository(databaseProvider)),
        Provider(create: (_) => FeatRepository(databaseProvider)),
        Provider(create: (_) => ClassRepository(databaseProvider)),
        Provider(create: (_) => SettingsRepository(databaseProvider)),
        Provider(create: (_) => SpellsRepository(databaseProvider)),
      ],
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(create: (_) => HeaderCubit()),
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(
                create: (_) => CharacterBloc(
                      characterRepository: context.read<CharacterRepository>(),
                      raceRepository: context.read<RaceRepository>(),
                      classRepository: context.read<ClassRepository>(),
                      featRepository: context.read<FeatRepository>(),
                      spellsRepository: context.read<SpellsRepository>(),
                    )),
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(
                create: (_) => SettingsCubit(
                      spellsRepository: context.read<SpellsRepository>(),
                    )),
            BlocProvider(create: (_) => MainScreenCubit()),
          ],
          child: const MainScreen(),
        );
      },
    );
  }
}
