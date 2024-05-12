import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/adventure_tab.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/characters_tab.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/locations_tab.dart';
import 'package:flutter/material.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 3,
      initialIndex: 2,
      child: Column(
        children: <Widget>[
          TabBar(
            tabs: [
              Tab(text: 'Locations'),
              Tab(text: 'Characters'),
              Tab(text: 'Adventure'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                LocationsTab(),
                CharactersTab(),
                AdventureTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
