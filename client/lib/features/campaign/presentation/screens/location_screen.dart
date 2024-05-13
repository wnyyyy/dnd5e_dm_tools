import 'dart:math';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/location.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';

class LocationDetailsScreen extends StatefulWidget {
  final Location location;

  const LocationDetailsScreen({super.key, required this.location});

  @override
  LocationDetailsScreenState createState() => LocationDetailsScreenState();
}

class LocationDetailsScreenState extends State<LocationDetailsScreen> {
  var editMode = false;
  late Location updatedLocation;

  void _toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  @override
  void initState() {
    super.initState();
    updatedLocation = widget.location;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        updatedLocation = (state as CampaignLoaded).locations.firstWhere(
              (loc) => loc.name == widget.location.name,
              orElse: () => widget.location,
            );
        return Scaffold(
          appBar: AppBar(
            title: Text(updatedLocation.name),
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
                      const SizedBox(height: 16),
                      ...List.generate(updatedLocation.entries.length, (index) {
                        final entry = updatedLocation.entries[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            tileColor: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            title: Text(
                              entry.content,
                              textAlign: TextAlign.justify,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    fontFamily:
                                        GoogleFonts.montserrat().fontFamily,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                            ),
                            trailing: editMode
                                ? IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _showEntryDialog(
                                      entryId: entry.id,
                                      initialText: entry.content,
                                    ),
                                  )
                                : null,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              SizedBox(
                height: 80,
                child: Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => _toggleEditMode(),
                          icon: Icon(editMode ? Icons.done : Icons.edit),
                        ),
                        IconButton(
                          onPressed: () => _showEntryDialog(),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEntryDialog({String? entryId, String initialText = ''}) {
    TextEditingController dialogController =
        TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entryId == null ? 'Add New Entry' : 'Edit Entry'),
        content: TextFormField(
          controller: dialogController,
          maxLines: null,
          decoration: const InputDecoration(hintText: "Enter text here"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              var content = dialogController.text.trim();
              if (entryId == null) {
                if (content.isNotEmpty) {
                  context.read<CampaignCubit>().addEntry(
                        name: widget.location.name,
                        content: content,
                        type: CampaignTab.locations,
                      );
                  Navigator.pop(context);
                }
              } else {
                context.read<CampaignCubit>().updateEntry(
                      name: widget.location.name,
                      entryId: entryId,
                      content: content,
                      type: CampaignTab.locations,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _getImageWidget(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (updatedLocation.imageUrl.isEmpty || updatedLocation.isImageHidden) {
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
          imageProvider: NetworkImage(updatedLocation.imageUrl),
        ),
      ),
    );
  }
}
