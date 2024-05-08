import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/config/theme_cubit.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/screens/main_screen.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_bloc.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/data/settings_repository.dart';
import 'package:dnd5e_dm_tools/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox<Map<String, dynamic>>('firestore_cache');
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
        Provider(create: (_) => CharactersRepository(databaseProvider)),
        Provider(create: (_) => RacesRepository(databaseProvider)),
        Provider(create: (_) => FeatsRepository(databaseProvider)),
        Provider(create: (_) => ClassesRepository(databaseProvider)),
        Provider(create: (_) => SettingsRepository(databaseProvider)),
        Provider(create: (_) => SpellsRepository(databaseProvider)),
        Provider(create: (_) => ConditionsRepository(databaseProvider)),
      ],
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(create: (_) => HeaderCubit()),
            BlocProvider(create: (_) => ThemeCubit()),
            BlocProvider(
                create: (_) => CharacterBloc(
                      charactersRepository:
                          context.read<CharactersRepository>(),
                    )),
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(
                create: (_) => SettingsCubit(
                      spellsRepository: context.read<SpellsRepository>(),
                    )),
            BlocProvider(create: (_) => MainScreenCubit()),
            BlocProvider(
                create: (_) => RulesCubit(
                      conditionsRepository:
                          context.read<ConditionsRepository>(),
                      racesRepository: context.read<RacesRepository>(),
                      featsRepository: context.read<FeatsRepository>(),
                      classesRepository: context.read<ClassesRepository>(),
                      spellsRepository: context.read<SpellsRepository>(),
                    )),
          ],
          child: const MainScreen(),
        );
      },
    );
  }
}
