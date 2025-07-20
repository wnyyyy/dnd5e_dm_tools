import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:dnd5e_dm_tools/core/data/models/archetype.dart';
import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/core/data/models/class.dart';
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
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            classs.profSkills,
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
    final bool caster = classs.spellCastingAbility?.isNotEmpty ?? false;

    for (var i = 1; i < 21; i++) {
      final List<Widget> entries = [];
      entries.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          width: double.infinity,
          child: Text(
            '$key: ',
            style: Theme.of(context).textTheme.bodySmall,
            softWrap: true,
          ),
        ),
      );

      final ExpansionTile expansionTile = ExpansionTile(
        title: const Text('evel'),
        expandedAlignment: Alignment.centerLeft,
        children: entries,
      );
      levels.add(expansionTile);
    }

    return SingleChildScrollView(child: Column(children: levels));
  }
}
