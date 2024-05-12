import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdventureTab extends StatelessWidget {
  const AdventureTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        if (state is CampaignLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CampaignInitial) {
          context.read<CampaignCubit>().loadCampaign();
          return Container();
        } else if (state is CampaignLoaded) {
          return Container();
        } else if (state is CampaignError) {
          return const Center(child: Text('Failed to load adventure'));
        } else {
          return const Center(child: Text('No adventure data'));
        }
      },
    );
  }
}
