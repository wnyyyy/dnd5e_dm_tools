import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class RulesRepository {
  final DatabaseProvider databaseProvider;
  final conditionsPath = 'conditions/';

  RulesRepository(this.databaseProvider);

  Future<Map<String, Map<String, dynamic>>> getConditions() async {
    final docs = await databaseProvider.getCollection(path: conditionsPath);
    return docs.fold<Map<String, Map<String, dynamic>>>(
      {},
      (previousValue, element) {
        previousValue[element.id] = {'id': element.id, ...element.data() ?? {}};
        return previousValue;
      },
    );
  }
}
