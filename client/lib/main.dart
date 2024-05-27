import 'dart:io' show Directory, File;
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/db/realtime_database_provider.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/repository/campaign_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/characters_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/items_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/database_editor/cubit/database_editor_cubit.dart';
import 'package:dnd5e_dm_tools/features/main_screen/cubit/main_screen_cubit.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/main_screen/presentation/screens/main_screen.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print("Initializing...");

  final Directory? hiveDir;
  if (kIsWeb) {
    await Hive.initFlutter();
    hiveDir = null;
  } else {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    print(appDocumentDir.path);
    hiveDir = Directory('${appDocumentDir.path}/$hiveFolder');
    await Hive.initFlutter(hiveDir.path);
  }

  final hiveDirPath = hiveDir?.path ?? 'web';

  await checkHiveFiles(hiveDir);

  print('Hive initialized at $hiveDirPath');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );
  print('Firebase initialized');

  runApp(Dnd5eDmTools());
}

Future<void> checkHiveFiles(Directory? hiveDir) async {
  final fileList = [
    '$cacheClassesName.hive',
    '$cacheConditionsName.hive',
    '$cacheFeatsName.hive',
    '$cacheRacesName.hive',
    '$cacheSpellsName.hive',
    '$cacheSpellListsName.hive',
    '$cacheItemsName.hive',
    '$cacheMagicItems.hive',
  ];

  if (hiveDir != null) {
    await hiveDir.create(recursive: true);
  }

  for (var fileName in fileList) {
    final String hiveFilePath =
        hiveDir != null ? '${hiveDir.path}/$fileName' : 'web/$fileName';
    final hiveFile = File(hiveFilePath);
    final exists = hiveDir != null
        ? await hiveFile.exists()
        : await assetExists('assets/precache/$fileName');
    if (!exists) {
      final assetPath = 'assets/precache/$fileName';
      final data = await loadAsset(assetPath);
      if (data != null) {
        if (hiveDir != null) {
          await hiveFile.writeAsBytes(data);
        }
        print('$fileName does not exist, copying from assets...');
      } else {
        print('$fileName does not exist and no asset found');
      }
    } else {
      print('$fileName exists');
    }
  }
}

Future<bool> assetExists(String path) async {
  try {
    await rootBundle.load(path);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Uint8List?> loadAsset(String path) async {
  try {
    final byteData = await rootBundle.load(path);
    return byteData.buffer.asUint8List();
  } catch (e) {
    print('Failed to load $path: $e');
    return null;
  }
}

class Dnd5eDmTools extends StatelessWidget {
  final DatabaseProvider databaseProvider = DatabaseProvider();
  final RealtimeDatabaseProvider realtimeDatabaseProvider =
      RealtimeDatabaseProvider();

  Dnd5eDmTools({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => CharactersRepository(databaseProvider)),
        Provider(create: (_) => RacesRepository(databaseProvider)),
        Provider(create: (_) => FeatsRepository(databaseProvider)),
        Provider(create: (_) => ClassesRepository(databaseProvider)),
        Provider(create: (_) => SpellsRepository(databaseProvider)),
        Provider(create: (_) => ConditionsRepository(databaseProvider)),
        Provider(create: (_) => ItemsRepository(databaseProvider)),
        Provider(create: (_) => CampaignRepository(realtimeDatabaseProvider)),
      ],
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => SettingsCubit(
                racesRepository: context.read<RacesRepository>(),
                featsRepository: context.read<FeatsRepository>(),
                classesRepository: context.read<ClassesRepository>(),
                spellsRepository: context.read<SpellsRepository>(),
                conditionsRepository: context.read<ConditionsRepository>(),
                itemsRepository: context.read<ItemsRepository>(),
                charactersRepository: context.read<CharactersRepository>(),
              ),
            ),
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(create: (_) => MainScreenCubit()),
            BlocProvider(
              create: (_) => CharacterBloc(
                charactersRepository: context.read<CharactersRepository>(),
              ),
            ),
            BlocProvider(create: (_) => ScreenSplitterCubit()),
            BlocProvider(
              create: (_) => RulesCubit(
                conditionsRepository: context.read<ConditionsRepository>(),
                racesRepository: context.read<RacesRepository>(),
                featsRepository: context.read<FeatsRepository>(),
                classesRepository: context.read<ClassesRepository>(),
                spellsRepository: context.read<SpellsRepository>(),
                itemsRepository: context.read<ItemsRepository>(),
              ),
            ),
            BlocProvider(
              create: (_) => DatabaseEditorCubit(
                racesRepository: context.read<RacesRepository>(),
                featsRepository: context.read<FeatsRepository>(),
                classesRepository: context.read<ClassesRepository>(),
                spellsRepository: context.read<SpellsRepository>(),
                itemsRepository: context.read<ItemsRepository>(),
                charactersRepository: context.read<CharactersRepository>(),
              ),
            ),
            BlocProvider(
              create: (_) => CampaignCubit(
                campaignRepository: context.read<CampaignRepository>(),
              ),
            ),
            BlocProvider(
              create: (_) => OnboardingCubit(
                charactersRepository: context.read<CharactersRepository>(),
              ),
            ),
          ],
          child: const MainScreen(),
        );
      },
    );
  }
}
