import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:flutter/material.dart';

class LocationDetailsScreen extends StatelessWidget {
  final Location location;

  const LocationDetailsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          location.name,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location.name,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final entry in location.entries)
                  Text(
                    entry.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
