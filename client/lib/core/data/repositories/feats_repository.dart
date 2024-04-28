import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';

class FeatRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';

  FeatRepository(this.databaseProvider);

  Future<dynamic> getJson(String name) async {
    final docSnapshot = await databaseProvider.getDocument(path: '$path$name');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      return data;
    }
    return null;
  }

  Future<Feat?> get(String name) async {
    final docSnapshot = await databaseProvider.getDocument(path: '$path$name');
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data == null) {
        return null;
      }
      return Feat.fromMap(data);
    }
    return null;
  }

  Future<void> create(Feat feat) async {
    await databaseProvider.setData(
      path: '$path${feat.slug}',
      data: feat.toMap(),
    );
  }

  Future<void> update(Feat feat) async {
    var json = await getJson(feat.slug);
    if (json == null) {
      return;
    }
    final featMap = feat.toMap();
    for (var key in featMap.keys) {
      if (json[key] != featMap[key]) {
        json[key] = featMap[key];
      }
    }
    await databaseProvider.setData(
      path: '$path${feat.slug}',
      data: json,
    );
  }
}
