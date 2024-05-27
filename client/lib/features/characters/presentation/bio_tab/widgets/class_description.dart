import 'package:dnd5e_dm_tools/core/util/helper.dart';
import 'package:dnd5e_dm_tools/core/widgets/description_text.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ClassDescription extends StatefulWidget {
  final Map<String, dynamic> classs;
  final Map<String, dynamic> character;
  final String slug;
  final bool editMode;

  const ClassDescription({
    super.key,
    required this.classs,
    required this.character,
    required this.editMode,
    required this.slug,
  });

  @override
  State<ClassDescription> createState() => _ClassDescriptionState();
}

class _ClassDescriptionState extends State<ClassDescription> {
  String? selectedArchetypeSlug;
  List<Map<String, dynamic>> archetypes = [];

  @override
  void initState() {
    super.initState();
    selectedArchetypeSlug = widget.character['subclass'] ?? '';
    initializeArchetypes();
  }

  void initializeArchetypes() {
    if (widget.classs['archetypes'] != null) {
      archetypes = List<Map<String, dynamic>>.from(widget.classs['archetypes']
          .map((item) => Map<String, dynamic>.from(item)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TabBar(
              tabs: const [
                Tab(text: 'Archetype'),
                Tab(text: 'Class'),
                Tab(text: 'Table'),
              ],
              labelStyle: Theme.of(context).textTheme.bodySmall,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildArchetypeTab(),
                  _buildClassTab(),
                  _buildTableTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassTab() {
    final archetypeChr = widget.character['subclass'] ?? '';
    final archetype = widget.classs['archetypes'].firstWhere(
      (element) => element['slug'] == archetypeChr,
      orElse: () => null,
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
              child: Text(widget.classs['name'],
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
            if (archetype != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '(${archetype['name']})',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            StaggeredGrid.count(
              crossAxisCount:
                  Orientation.landscape == MediaQuery.of(context).orientation
                      ? 4
                      : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildGridCard('Hit Dice', widget.classs['hit_dice'], context),
                _buildGridCard('Saving Throws',
                    widget.classs['prof_saving_throws'], context),
                _buildGridCard('Armor\nProficiencies',
                    widget.classs['prof_armor'], context),
                if (widget.classs['spellcasting_ability'] != null &&
                    widget.classs['spellcasting_ability'].isNotEmpty)
                  _buildGridCard('Spellcasting\nAbility',
                      widget.classs['spellcasting_ability'], context),
                _buildGridCard('Weapon\nProficiencies',
                    widget.classs['prof_weapons'], context),
                _buildGridCard('Tools\nProficiencies',
                    widget.classs['prof_tools'] ?? 'None', context),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Skills\nProficiencies',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.classs['prof_skills'] ?? 'None',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String title, String content, BuildContext context) {
    return StaggeredGridTile.fit(
      crossAxisCellCount: 1,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchetypeTab() {
    final Map<String, dynamic> noneOption = {'slug': '', 'name': 'None'};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          DropdownButton<Map<String, dynamic>>(
            value:
                selectedArchetypeSlug == null || selectedArchetypeSlug!.isEmpty
                    ? noneOption
                    : archetypes.firstWhere(
                        (element) => element['slug'] == selectedArchetypeSlug!,
                        orElse: () => noneOption),
            onChanged: (Map<String, dynamic>? newValue) {
              setState(
                () {
                  selectedArchetypeSlug = newValue!['slug'];
                  widget.character['subclass'] = selectedArchetypeSlug;
                  context.read<CharacterBloc>().add(
                        CharacterUpdate(
                          character: widget.character,
                          slug: widget.slug,
                          offline:
                              context.read<SettingsCubit>().state.offlineMode,
                          persistData: false,
                        ),
                      );
                },
              );
            },
            items: [noneOption]
                .followedBy(archetypes)
                .map<DropdownMenuItem<Map<String, dynamic>>>(
              (Map<String, dynamic> archetype) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: archetype,
                  child: Text(archetype['name']),
                );
              },
            ).toList(),
          ),
          if (selectedArchetypeSlug?.isNotEmpty ?? false)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: _buildArchetypeDetails(selectedArchetypeSlug!),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildArchetypeDetails(String archetypeSlug) {
    final archetype = widget.classs['archetypes']
        .firstWhere((element) => element['slug'] == archetypeSlug);
    List<Widget> widgets = [];
    widgets.add(
      Text(
        archetype?['name'] ?? '',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
    final archetypeFeatures = getArchetypeFeatures(archetype['desc'] ?? '');
    for (final feature in archetypeFeatures.entries) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Text(
              feature.key,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DescriptionText(
                  inputText: feature.value['description'] ?? '',
                  baseStyle: Theme.of(context).textTheme.bodySmall!,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _buildTableTab() {
    final table = parseTable(widget.classs['table'] ?? '');

    List<Widget> levels = [];
    final bool caster =
        widget.classs['spellcasting_ability']?.isNotEmpty ?? false;

    for (var i = 1; i < table.length; i++) {
      List<Widget> entries = [];
      for (final entry in table[i].entries) {
        if (entry.key == 'Level') {
          continue;
        }
        final String key;
        if (caster && int.tryParse(entry.key[0]) != null) {
          key = '${entry.key} Lv Spell Slots';
        } else {
          key = entry.key;
        }
        entries.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            width: double.infinity,
            child: Text(
              '$key: ${entry.value}',
              style: Theme.of(context).textTheme.bodySmall,
              softWrap: true,
            ),
          ),
        );
      }
      final ExpansionTile expansionTile = ExpansionTile(
        title: Text('${table[i]['Level']} Level'),
        expandedAlignment: Alignment.centerLeft,
        children: entries,
      );
      levels.add(expansionTile);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: levels,
      ),
    );
  }
}
