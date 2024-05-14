import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/adventure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';

class AdventureWidget extends StatefulWidget {
  final Adventure adventure;

  const AdventureWidget({super.key, required this.adventure});

  @override
  AdventureWidgetState createState() => AdventureWidgetState();
}

class AdventureWidgetState extends State<AdventureWidget> {
  var editMode = false;
  late Adventure updatedAdventure;

  void _toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  @override
  void initState() {
    super.initState();
    updatedAdventure = widget.adventure;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        updatedAdventure = (state as CampaignLoaded).adventure;
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ...List.generate(updatedAdventure.entries.length, (index) {
                      final entry = updatedAdventure.entries[index];
                      if (entry.id != '0') {
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
                      } else {
                        return const SizedBox.shrink();
                      }
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
                        name: 'Adventure',
                        content: content,
                        type: CampaignTab.adventure,
                      );
                  Navigator.pop(context);
                }
              } else {
                context.read<CampaignCubit>().updateEntry(
                      name: 'Adventure',
                      entryId: entryId,
                      content: content,
                      type: CampaignTab.adventure,
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
}
