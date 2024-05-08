import 'package:dnd5e_dm_tools/core/data/repositories/classes_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/conditions_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/feats_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/races_repository.dart';
import 'package:dnd5e_dm_tools/core/data/repositories/spells_repository.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RulesCubit extends Cubit<RulesState> {
  final ConditionsRepository conditionsRepository;
  final RacesRepository racesRepository;
  final FeatsRepository featsRepository;
  final ClassesRepository classesRepository;
  final SpellsRepository spellsRepository;
  RulesCubit({
    required this.conditionsRepository,
    required this.racesRepository,
    required this.featsRepository,
    required this.classesRepository,
    required this.spellsRepository,
  }) : super(RulesStateInitial());

  void loadRules() async {
    emit(RulesStateLoading());
    try {
      final conditions = conditionsRepository.getConditions();
      final races = racesRepository.getAll();
      final classes = classesRepository.getAll();
      final results = await Future.wait([conditions, races, classes]);
      emit(RulesStateLoaded(
          conditions: results[0], races: results[1], classes: results[2]));
    } catch (e) {
      emit(RulesStateError(e.toString()));
    }
  }

  Map<String, dynamic>? getRace(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).races[slug];
    }
    return null;
  }

  Map<String, dynamic>? getClass(String slug) {
    if (state is RulesStateLoaded) {
      return (state as RulesStateLoaded).classes[slug];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getFeat(String slug) async {
    if (state is RulesStateLoaded) {
      if ((state as RulesStateLoaded).feats != null) {
        return (state as RulesStateLoaded).feats![slug];
      }
      final feats = await featsRepository.getAll();
      emit((state as RulesStateLoaded).copyWith(feats: feats));
      return feats[slug];
    }
    return null;
  }

  Future<Map<String, dynamic>?> getAllFeats() async {
    if (state is RulesStateLoaded) {
      if ((state as RulesStateLoaded).feats != null) {
        return (state as RulesStateLoaded).feats;
      }
      final feats = await featsRepository.getAll();
      emit((state as RulesStateLoaded).copyWith(feats: feats));
      return feats;
    }
    return null;
  }
}
