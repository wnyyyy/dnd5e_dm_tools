import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/adventure_tab.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/characters_tab.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/widgets/locations_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CampaignScreen extends StatelessWidget {
  const CampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CampaignCubit>(
      create: (_) => CampaignCubit(
        campaignRepository: context.read(),
      ),
      child: BlocListener<CampaignCubit, CampaignState>(
        listener: (context, state) {
          if (state is CampaignInitial) {
            context.read<CampaignCubit>().loadCampaign();
          }
        },
        child: const DefaultTabController(
          length: 3,
          initialIndex: 2,
          child: Column(children: [
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
          ],),
        ),
      ),
    );
  }
}
