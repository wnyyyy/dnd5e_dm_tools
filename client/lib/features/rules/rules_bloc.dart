import 'package:dnd5e_dm_tools/core/data/repositories/rules_repository.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesCubit extends Cubit<RulesState> {
  final RulesRepository rulesRepository;
  RulesCubit({required this.rulesRepository}) : super(RulesStateInitial());

  void loadRules() async {
    emit(RulesStateLoading());
    try {
      final conditions = await rulesRepository.getConditions();
      emit(RulesStateLoaded(conditions: conditions));
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
  }
}
