import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/presentation/screens/location_screen.dart';

class LocationsTab extends StatelessWidget {
  const LocationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        if (state is CampaignLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CampaignLoaded) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: state.locations
                  .map((location) => ChoiceChip(
                        label: Text(location.name),
                        selected: false,
                        onSelected: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<CampaignCubit>(context),
                                child:
                                    LocationDetailsScreen(location: location),
                              ),
                            ),
                          );
                        },
                      ))
                  .toList(),
            ),
          );
        } else if (state is CampaignError) {
          return const Center(child: Text('Failed to load locations'));
        } else {
          return const Center(child: Text('No locations data'));
        }
      },
    );
  }
}
