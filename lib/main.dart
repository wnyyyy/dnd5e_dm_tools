import 'dart:io';

import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/equipment/equipment_bloc.dart';
import 'package:dnd5e_dm_tools/features/database_editor/bloc/database_editor_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/bloc/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/main_screen.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive with platform-specific configuration
  if (kIsWeb) {
    await Hive.initFlutter(hiveWebSubdir);
  } else {
    await Hive.initFlutter('hive');
  }

  await checkHiveFiles();

  runApp(Dnd5eDmTools());
}

Future<void> checkHiveFiles() async {
  final hiveFileNames = [
    cacheClassesName,
    cacheConditionsName,
    cacheFeatsName,
    cacheRacesName,
    cacheSpellsName,
    cacheSpellListsName,
    cacheItemsName,
  ];

  if (kIsWeb) {
    await _initializeWebHiveFiles(hiveFileNames);
  } else {
    await _initializeMobileHiveFiles(hiveFileNames);
  }
}

Future<void> _initializeWebHiveFiles(List<String> hiveFileNames) async {
  for (final fileName in hiveFileNames) {
    try {
      var box = await Hive.openBox<Map>(fileName);

      if (box.isEmpty) {
        logStart(
          'Initializing box data with bundled assets file',
          level: Level.info,
        );
        await box.close();

        final assetPath = 'assets/precache/$fileName.hive';
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();

        box = await Hive.openBox<Map>(fileName, bytes: bytes);
      } else {
        logStart('Box $fileName already contains data', level: Level.info);
      }
    } catch (e) {
      logStart('Error checking $fileName for web: $e', level: Level.error);
    }
  }
}

Future<void> _initializeMobileHiveFiles(List<String> hiveFileNames) async {
  final appDocDir = await getApplicationDocumentsDirectory();
  final hiveDir = Directory(path.join(appDocDir.path, 'hive'));

  if (!await hiveDir.exists()) {
    logStart('Creating Hive directory at ${hiveDir.path}', level: Level.info);
    await hiveDir.create(recursive: true);
  } else {
    logStart(
      'Hive directory already exists at ${hiveDir.path}',
      level: Level.info,
    );
  }

  for (final fileName in hiveFileNames) {
    final hiveFile = File(path.join(hiveDir.path, '$fileName.hive'));

    if (!await hiveFile.exists()) {
      try {
        final assetPath = 'assets/precache/$fileName.hive';
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List();
        await hiveFile.writeAsBytes(bytes);
        logStart(
          'Copied $fileName.hive from assets to Hive directory',
          level: Level.info,
        );
      } catch (e) {
        logStart(
          'Error copying $fileName.hive from assets: $e',
          level: Level.error,
        );
        throw Exception('Error copying $fileName.hive from assets: $e');
      }
    }
  }
}

class Dnd5eDmTools extends StatelessWidget {
  Dnd5eDmTools({super.key});
  final DatabaseProvider databaseProvider = DatabaseProvider();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<CharactersRepository>(
          create: (_) => CharactersRepository(databaseProvider),
        ),
        RepositoryProvider<ClassesRepository>(
          create: (_) => ClassesRepository(databaseProvider),
        ),
        RepositoryProvider<ConditionsRepository>(
          create: (_) => ConditionsRepository(databaseProvider),
        ),
        RepositoryProvider<RacesRepository>(
          create: (_) => RacesRepository(databaseProvider),
        ),
        RepositoryProvider<SpellsRepository>(
          create: (_) => SpellsRepository(databaseProvider),
        ),
        RepositoryProvider<ItemsRepository>(
          create: (_) => ItemsRepository(databaseProvider),
        ),
        RepositoryProvider<FeatsRepository>(
          create: (_) => FeatsRepository(databaseProvider),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>(
            lazy: false,
            create: (context) => SettingsCubit(
              charactersRepository: context.read<CharactersRepository>(),
            )..init(),
          ),
          BlocProvider<OnboardingCubit>(
            create: (context) => OnboardingCubit(
              charactersRepository: context.read<CharactersRepository>(),
            ),
          ),
          BlocProvider<CharacterBloc>(
            create: (context) => CharacterBloc(
              charactersRepository: context.read<CharactersRepository>(),
              classesRepository: context.read<ClassesRepository>(),
              racesRepository: context.read<RacesRepository>(),
            ),
          ),
          BlocProvider<EquipmentBloc>(
            create: (context) =>
                EquipmentBloc(itemsRepository: context.read<ItemsRepository>()),
          ),
          BlocProvider<MainScreenCubit>(create: (context) => MainScreenCubit()),
          BlocProvider<DatabaseEditorCubit>(
            create: (context) => DatabaseEditorCubit(
              spellsRepository: context.read<SpellsRepository>(),
              featsRepository: context.read<FeatsRepository>(),
              classesRepository: context.read<ClassesRepository>(),
              racesRepository: context.read<RacesRepository>(),
              itemsRepository: context.read<ItemsRepository>(),
            ),
          ),
          BlocProvider<RulesCubit>(
            lazy: false,
            create: (context) => RulesCubit(
              conditionsRepository: context.read<ConditionsRepository>(),
              itemsRepository: context.read<ItemsRepository>(),
              spellsRepository: context.read<SpellsRepository>(),
              featsRepository: context.read<FeatsRepository>(),
              classesRepository: context.read<ClassesRepository>(),
              racesRepository: context.read<RacesRepository>(),
            )..loadRules(),
          ),
        ],
        child: const MainScreen(),
      ),
    );
  }
}
