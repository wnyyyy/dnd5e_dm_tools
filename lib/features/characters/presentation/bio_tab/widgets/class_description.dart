import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:dnd5e_dm_tools/core/data/models/archetype.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
import 'package:dnd5e_dm_tools/core/data/models/class_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ClassDescription extends StatelessWidget {
  const ClassDescription({
    super.key,
    required this.classs,
    required this.character,
  });

  final Class classs;
  final Character character;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 900
        ? 810.0
        : (screenWidth * 0.9) < 450.0
        ? 450.0
        : screenWidth * 0.9;
    final Archetype? archetype = classs.archetypes
        .where((element) => element.slug == character.archetype)
        .firstOrNull;
    final tabs = <Tab>[
      if (archetype != null) const Tab(text: 'Archetype'),
      const Tab(text: 'Class'),
      const Tab(text: 'Table'),
    ];
    final tabViews = <Widget>[
      if (archetype != null) _buildArchetypeTab(context, archetype),
      _buildClassTab(context, archetype),
      _buildTableTab(context),
    ];
    return Dialog(
      child: DefaultTabController(
        initialIndex: archetype != null ? 1 : 0,
        length: tabs.length,
        child: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TabBar(
                tabs: tabs,
                labelStyle: Theme.of(context).textTheme.bodySmall,
              ),
              Expanded(child: TabBarView(children: tabViews)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassTab(BuildContext context, Archetype? archetype) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 8, left: 8),
              child: Text(
                classs.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            if (archetype != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  archetype.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            StaggeredGrid.count(
              crossAxisCount:
                  MediaQuery.of(context).orientation == Orientation.landscape
                  ? 4
                  : 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _buildGridCard('Hit Dice', classs.hitDice, context),
                _buildGridCard(
                  'Saving Throws',
                  classs.profSavingThrows,
                  context,
                ),
                _buildGridCard(
                  'Armor\nProficiencies',
                  classs.profArmor,
                  context,
                ),
                if (classs.spellCastingAbility?.isNotEmpty ?? false)
                  _buildGridCard(
                    'Spellcasting\nAbility',
                    classs.spellCastingAbility!,
                    context,
                  ),
                _buildGridCard(
                  'Weapon\nProficiencies',
                  classs.profWeapons,
                  context,
                ),
                _buildGridCard(
                  'Tools\nProficiencies',
                  classs.profTools,
                  context,
                ),
                StaggeredGridTile.fit(
                  crossAxisCellCount: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Text(
                            'Skills\nProficiencies',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            classs.profSkills,
                            style: classs.profSkills.length > 30
                                ? Theme.of(context).textTheme.bodySmall
                                : Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
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
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                content,
                style: content.length > 30
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchetypeTab(BuildContext context, Archetype archetype) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Column(
        children: [
          Text(
            archetype.name,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Markdown(
              data: archetype.desc,
              styleSheet: AppThemes.markdownStyleSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableTab(BuildContext context) {
    final List<Widget> levels = [];

    for (var i = 1; i < 21; i++) {
      final ClassTableRow? entry = classs.table.levelData[i];
      if (entry == null) continue;
      final ExpansionTile expansionTile = ExpansionTile(
        title: Text('Level $i'),
        expandedAlignment: Alignment.centerLeft,
        childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
        children: [
          _buildField(
            context,
            label: 'Proficiency Bonus:',
            value: ' +${entry.proficiencyBonus}',
          ),
          _buildField(
            context,
            label: 'Features: ',
            value: entry.features.join(', '),
          ),
          if (entry.classSpecificFeatures?.isNotEmpty ?? false)
            ...entry.classSpecificFeatures!.entries.map(
              (e) => _buildField(
                context,
                label: '${e.key}: ',
                value: e.value.toString(),
              ),
            ),
        ],
      );
      levels.add(expansionTile);
    }

    return SingleChildScrollView(child: Column(children: levels));
  }

  Widget _buildField(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(4),
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: label,
          style: Theme.of(context).textTheme.bodyMedium,
          children: [
            TextSpan(
              text: value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
