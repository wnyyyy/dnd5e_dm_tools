import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';
import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:dnd5e_dm_tools/core/util/logger.dart';
import 'package:logger/logger.dart';

class FeatsRepository {
  FeatsRepository(this.databaseProvider);
  final DatabaseProvider databaseProvider;

  Future<void> init() async {
    await databaseProvider.loadCache(cacheFeatsName);
  }

  Future<Feat> get(String slug) async {
    final data = await databaseProvider.getDocument(
      path: '$firebaseFeatsPath/$slug',
      cacheBoxName: cacheFeatsName,
    );
    if (data == null) {
      logRep('Feat not found: $slug', level: Level.warning);
      throw Exception('Feat not found');
    }
    final feat = Feat.fromJson(data, slug);
    return feat;
  }

  Future<List<Feat>> getAll() async {
    final data = await databaseProvider.getCollection(
      path: firebaseFeatsPath,
      cacheBoxName: cacheFeatsName,
    );
    final List<Feat> feats = [];
    for (final entry in data.entries) {
      final slug = entry.key;
      final featData = entry.value;
      try {
        final feat = Feat.fromJson(featData, slug);
        feats.add(feat);
      } catch (e) {
        logRep('Error parsing Feat $slug: $e', level: Level.error);
      }
    }
    return feats;
  }

  Future<void> sync(String slug, Feat feat) async {
    final entry = feat.toJson();
    await databaseProvider.setData(
      path: slug,
      data: entry,
      offline: true,
      cacheBoxName: cacheFeatsName,
    );
  }

  Future<void> save(String slug, Feat feat, bool offline) async {
    final entry = feat.toJson();
    await databaseProvider.setData(
      path: '$firebaseFeatsPath/$slug',
      data: entry,
      offline: offline,
      cacheBoxName: cacheFeatsName,
    );
  }
}
