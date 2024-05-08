import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class FeatsRepository {
  final DatabaseProvider databaseProvider;
  final path = 'feats/';
  final shouldCache = true;

  FeatsRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cache: shouldCache);
    return data;
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }
}
