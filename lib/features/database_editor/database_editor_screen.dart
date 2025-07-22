import 'dart:convert';

import 'package:dnd5e_dm_tools/core/data/models/character.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character/character_event.dart';
import 'package:dnd5e_dm_tools/features/database_editor/bloc/database_editor_cubit.dart';
import 'package:dnd5e_dm_tools/features/database_editor/bloc/database_editor_state.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseEditorScreen extends StatelessWidget {
  const DatabaseEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DatabaseEditorCubit, DatabaseEditorState>(
      builder: (context, state) {
        final cubit = context.read<DatabaseEditorCubit>();
        final selectedIndex = state.selectedIndex;
        final List<String> categories = [
          'Feat',
          'Race',
          'Spell',
          'Class',
          'Item',
        ];
        final String type = [
          'feats',
          'races',
          'spells',
          'classes',
          'items',
        ][selectedIndex];

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _SearchBar(
                    onSearch: (query) {
                      if (query.trim().isNotEmpty) {
                        cubit.fetch(query.trim(), type);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  children: [
                    ...List.generate(categories.length, (index) {
                      return ChoiceChip(
                        label: Text(categories[index]),
                        selected: selectedIndex == index,
                        onSelected: (selected) {
                          cubit.setSelectedIndex(index);
                        },
                      );
                    }),
                    Wrap(
                      children: [
                        ActionChip.elevated(
                          label: const Text('Sync'),
                          onPressed: state is DatabaseEditorLoaded
                              ? () {
                                  cubit.sync(type, state.slug);
                                  context.read<RulesCubit>().reloadRule(type);
                                  context.read<CharacterBloc>().add(
                                    CharacterLoad(
                                      context.read<SettingsCubit>().state.name,
                                    ),
                                  );
                                }
                              : null,
                        ),
                        const SizedBox(width: 10),
                        ActionChip.elevated(
                          label: const Text('Invalidate Cache'),
                          onPressed: () async {
                            final types = await showDialog<List<String>>(
                              context: context,
                              builder: (context) => _InvalidateCacheDialog(),
                            );
                            if (types != null &&
                                types.isNotEmpty &&
                                context.mounted) {
                              context.read<RulesCubit>().invalidateCache(types);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Selected caches invalidated.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildContent(state, type, context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    DatabaseEditorState state,
    String type,
    BuildContext context,
  ) {
    if (state is DatabaseEditorLoading) {
      return const CircularProgressIndicator();
    }
    if (state is DatabaseEditorLoaded) {
      return _buildInputs(context, state, type);
    }
    if (state is DatabaseEditorError) {
      return Text(
        state.message != null
            ? 'Error: \n${state.message}'
            : 'An error occurred',
        style: Theme.of(context).textTheme.bodyLarge,
      );
    }
    return const Center();
  }

  Widget _buildInputs(
    BuildContext context,
    DatabaseEditorLoaded state,
    String type,
  ) {
    final List<Widget> fields = [];
    fields.add(
      SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: state.slug,
                decoration: const InputDecoration(
                  labelText: 'slug',
                  border: OutlineInputBorder(),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                onChanged: (val) {
                  val = val.trim().toLowerCase();
                  state.entry['slug'] = val;
                },
              ),
            ),
            const SizedBox(width: 16),
            ActionChip.elevated(
              label: const Text('Save'),
              onPressed: () {
                context.read<DatabaseEditorCubit>().save(
                  state.entry['slug'] as String? ?? '',
                  state.entry,
                  type,
                );
              },
            ),
          ],
        ),
      ),
    );
    const noneditableKeys = ['table'];
    state.entry.forEach((key, value) {
      Widget field;
      if (value is String) {
        field = TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            labelText: key,
            border: const OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          minLines: 1,
          maxLines: 4,
          enabled: !noneditableKeys.contains(key),
          onChanged: (val) {
            val = val.trim();
            state.entry[key] = val;
          },
        );
      } else if (value is num) {
        field = TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: key,
            border: const OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          onChanged: (val) {
            if (val.isNotEmpty) {
              state.entry[key] = num.tryParse(val);
            } else {
              state.entry[key] = null;
            }
          },
        );
      } else if (value is List) {
        field = TextFormField(
          initialValue: value.join('\n'),
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: '$key (one per line)',
            border: const OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          enabled: false,
          onChanged: (val) {
            state.entry[key] = val.split('\n').map((e) => e.trim()).toList();
          },
        );
      } else if (value is Map) {
        field = TextFormField(
          initialValue: const JsonEncoder.withIndent('  ').convert(value),
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: '$key (JSON)',
            border: const OutlineInputBorder(),
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          enabled: false,
          onChanged: (val) {
            try {
              state.entry[key] = jsonDecode(val);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invalid JSON for $key: $e')),
              );
            }
          },
        );
      } else {
        field = Text('$key: $value');
      }

      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: field,
        ),
      );
    });
    return Column(children: fields);
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.onSearch});
  final ValueChanged<String> onSearch;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onSubmitted: widget.onSearch,
      decoration: InputDecoration(
        hintText: 'Search database...',
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => widget.onSearch(_controller.text),
        ),
      ),
    );
  }
}

class _InvalidateCacheDialog extends StatefulWidget {
  @override
  State<_InvalidateCacheDialog> createState() => _InvalidateCacheDialogState();
}

class _InvalidateCacheDialogState extends State<_InvalidateCacheDialog> {
  final Map<String, bool> _selected = {
    'feats': false,
    'races': false,
    'spells': false,
    'classes': false,
    'items': false,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Invalidate Cache'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _selected.keys.map((type) {
          return CheckboxListTile(
            title: Text(type[0].toUpperCase() + type.substring(1)),
            value: _selected[type],
            onChanged: (val) {
              setState(() {
                _selected[type] = val ?? false;
              });
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final selectedTypes = _selected.entries
                .where((e) => e.value)
                .map((e) => e.key)
                .toList();
            Navigator.pop(context, selectedTypes);
          },
          child: const Text('Invalidate'),
        ),
      ],
    );
  }
}
