import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';

class LocationDetailsScreen extends StatelessWidget {
  final Location location;

  const LocationDetailsScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(location.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getImageWidget(context),
                  ...location.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextFormField(
                          textAlign: TextAlign.justify,
                          style: Theme.of(context).textTheme.bodyMedium,
                          initialValue: entry.content,
                          onChanged: (value) =>
                              context.read<CampaignCubit>().updateEntry(
                                    name: location.name,
                                    entryId: entry.id,
                                    content: value,
                                    type: CampaignTab.locations,
                                  ),
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).canvasColor,
                            filled: true,
                            border: const OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(
            child: Divider(height: 1),
          ),
          SizedBox(
            height: 80,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton.filledTonal(
                        onPressed: () {}, icon: const Icon(Icons.add)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (location.imageUrl.isEmpty || location.isImageHidden) {
      return SizedBox(
        height: screenHeight * 0.3,
        child: Center(
          child: Image.asset(
            'assets/img/unknown_loc.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error),
          ),
        ),
      );
    }
    return SizedBox(
      height: screenHeight * 0.5,
      child: Center(
        child: PhotoView(
          backgroundDecoration:
              BoxDecoration(color: Theme.of(context).canvasColor),
          imageProvider: NetworkImage(location.imageUrl),
        ),
      ),
    );
  }
}
