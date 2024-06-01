import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_cubit.dart';
import 'package:dnd5e_dm_tools/features/campaign/cubit/campaign_states.dart';
import 'package:dnd5e_dm_tools/features/campaign/data/models/character.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

class CharacterDetailsScreen extends StatefulWidget {

  const CharacterDetailsScreen({super.key, required this.character});
  final Character character;

  @override
  CharacterDetailsScreenState createState() => CharacterDetailsScreenState();
}

class CharacterDetailsScreenState extends State<CharacterDetailsScreen> {
  bool editMode = false;
  late Character updatedCharacter;

  void _toggleEditMode() {
    setState(() {
      editMode = !editMode;
    });
  }

  @override
  void initState() {
    super.initState();
    updatedCharacter = widget.character;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignCubit, CampaignState>(
      builder: (context, state) {
        updatedCharacter = (state as CampaignLoaded).characters.firstWhere(
              (char) => char.name == widget.character.name,
              orElse: () => widget.character,
            );
        return Scaffold(
          appBar: AppBar(
            title: Text(updatedCharacter.name),
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
                      ...List.generate(updatedCharacter.entries.length,
                          (index) {
                        final entry = updatedCharacter.entries[index];
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
    final TextEditingController dialogController =
        TextEditingController(text: initialText);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entryId == null ? 'Add New Entry' : 'Edit Entry'),
        content: TextFormField(
          controller: dialogController,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Enter text here'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final content = dialogController.text.trim();
              if (entryId == null) {
                if (content.isNotEmpty) {
                  context.read<CampaignCubit>().addEntry(
                        name: widget.character.name,
                        content: content,
                        type: CampaignTab.characters,
                      );
                  Navigator.pop(context);
                }
              } else {
                context.read<CampaignCubit>().updateEntry(
                      name: widget.character.name,
                      entryId: entryId,
                      content: content,
                      type: CampaignTab.characters,
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

    if (updatedCharacter.imageUrl.isEmpty || updatedCharacter.isImageHidden) {
      return SizedBox(
        height: screenHeight * 0.3,
        child: Center(
          child: Image.asset(
            'assets/img/unknown.jpg',
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
          imageProvider: NetworkImage(updatedCharacter.imageUrl),
        ),
      ),
    );
  }
}
