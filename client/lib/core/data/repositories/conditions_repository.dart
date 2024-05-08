import 'package:dnd5e_dm_tools/core/data/db/database_provider.dart';

class ConditionsRepository {
  final DatabaseProvider databaseProvider;
  final conditionsPath = 'conditions/';

  ConditionsRepository(this.databaseProvider);

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
