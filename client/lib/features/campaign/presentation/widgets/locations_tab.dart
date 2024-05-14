import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
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
          List<Location> sortedLocations = List<Location>.from(state.locations);
          sortedLocations.sort((a, b) => a.name.compareTo(b.name));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: sortedLocations
                  .map(
                    (location) => Visibility(
                      visible: !location.isHidden,
                      child: ChoiceChip(
                        label: Text(location.name),
                        selected: false,
                        onSelected: (_) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: BlocProvider.of<CampaignCubit>(context),
                                child: LocationDetailsScreen(
                                    key: ValueKey(location.name),
                                    location: location),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          );
        } else if (state is CampaignError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load locations\n${state.message}'),
                TextButton(
                  onPressed: () {
                    context.read<CampaignCubit>().retry();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No locations data'));
        }
      },
    );
  }
}
