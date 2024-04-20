import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';
import 'package:dnd5e_dm_tools/core/data/models/feat.dart';

class FeatRepository {
  final DatabaseProvider databaseProvider;

  FeatRepository(this.databaseProvider);

  Future<List<Feat>> getAllFeats() async {
    final db = await databaseProvider.database;
    var feats = await db.query('Feats', orderBy: 'name');
    List<Feat> featList =
        feats.isNotEmpty ? feats.map((c) => Feat.fromMap(c)).toList() : [];
    return featList;
  }

  Future<Feat?> getFeat(String slug) async {
    final db = await databaseProvider.database;
    var feat = await db.query('Feats', where: 'slug = ?', whereArgs: [slug]);
    if (feat.isEmpty) return null;
    return Feat.fromMap(feat[0]);
  }

  Future<Feat> insertFeat(Feat feat) async {
    final db = await databaseProvider.database;
    var featMap = feat.toMap();
    await db.insert('Feats', featMap);
    return feat;
  }

  Future<Feat> updateFeat(Feat feat) async {
    final db = await databaseProvider.database;
    await db.update(
      'Feats',
      feat.toMap(),
      where: 'name = ?',
      whereArgs: [feat.name],
    );
    return feat;
  }

  Future<void> updateAll(List<Feat> feats) async {
    final db = await databaseProvider.database;
    await db.transaction((txn) async {
      await txn.delete('Feats');

      for (Feat feat in feats) {
        await txn.insert('Feats', feat.toMap());
      }
    });
  }
}
