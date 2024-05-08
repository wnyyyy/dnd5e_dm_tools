import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class ClassesRepository {
  final DatabaseProvider databaseProvider;
  final path = 'classes/';
  final shouldCache = true;

  ClassesRepository(this.databaseProvider);

  Future<dynamic> get(String slug) async {
    final data = await databaseProvider.getDocument(
        path: '$path$slug', cache: shouldCache);
    return data;
  }

  Future<void> updateClass(String slug, Map<String, dynamic> classs) async {
    await databaseProvider.setData(
      path: '$path$slug',
      data: classs,
    );
  }

  Future<Map<String, Map<String, dynamic>>> getAll() async {
    final data = await databaseProvider.getCollection(path: path);
    return data;
  }
}
