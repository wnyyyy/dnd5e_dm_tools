import 'package:dnd5e_dm_tools/features/database_editor/cubit/database_editor_cubit.dart';
import 'package:dnd5e_dm_tools/features/database_editor/cubit/database_editor_states.dart';
import 'package:dnd5e_dm_tools/features/rules/rules_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DatabaseEditorScreen extends StatefulWidget {
  const DatabaseEditorScreen({super.key});

  @override
  DatabaseEditorScreenState createState() => DatabaseEditorScreenState();
}

class DatabaseEditorScreenState extends State<DatabaseEditorScreen> {
  int _selectedIndex = 5;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, List<TextEditingController>> _controllers = {};
  final TextEditingController _slugController = TextEditingController();
  bool maySync = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onSubmitted: (_) {
                  _fetchData();
                },
                decoration: InputDecoration(
                  hintText: 'Search database...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _fetchData();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: _buildCategoryChips(),
            ),
            const SizedBox(height: 20),
            _buildContent(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCategoryChips() {
    final List<String> categories = [
      'Feat',
      'Race',
      'Spell',
      'Class',
      'Item',
      'Character',
    ];
    final List<Widget> chips = [];
    chips.addAll(
      List<Widget>.generate(
        categories.length,
        (int index) {
          return ChoiceChip(
            label: Text(categories[index]),
            selected: _selectedIndex == index,
            onSelected: (bool selected) {
              setState(() {
                _selectedIndex = index;
                _searchController.clear();
              });
              _fetchData();
            },
          );
        },
      ),
    );
    final String type = [
      'feats',
      'races',
      'spells',
      'classes',
      'items',
      'characters',
    ][_selectedIndex];
    chips.add(
      ActionChip.elevated(
        label: const Text('Sync'),
        onPressed: () {
          final slug = (context.read<DatabaseEditorCubit>().state
                  as DatabaseEditorLoaded)
              .slug;
          final entry = (context.read<DatabaseEditorCubit>().state
                  as DatabaseEditorLoaded)
              .entry;
          context.read<DatabaseEditorCubit>().sync(entry, type, slug);
          context.read<RulesCubit>().reloadRule(type);
        },
      ),
    );
    return chips;
  }

  Widget _buildContent() {
    return BlocBuilder<DatabaseEditorCubit, DatabaseEditorState>(
      builder: (context, state) {
        if (state is DatabaseEditorLoading) {
          return const CircularProgressIndicator();
        }
        if (state is DatabaseEditorLoaded) return _buildInputs(state.entry);
        return const Text('No data loaded');
      },
    );
  }

  Widget _buildInputs(Map<String, dynamic> entries) {
    final List<Widget> fields = [];
    entries.forEach((key, value) {
      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            '$key:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );

      if (value is List) {
        _buildListFields(fields, key, value);
      } else if (value is Map) {
        _buildMapFields(fields, key, Map<String, dynamic>.from(value));
      } else {
        _buildTextField(fields, key, value.toString());
      }
    });

    return Column(children: fields);
  }

  void _buildListFields(List<Widget> fields, String key, List<dynamic> list) {
    final List<TextEditingController> controllers = _controllers.putIfAbsent(
      key,
      () => List.generate(
        list.length,
        (index) => TextEditingController(text: list[index].toString()),
      ),
    );

    for (int i = 0; i < controllers.length; i++) {
      fields.add(_buildArrayField(key, i, controllers[i]));
    }

    fields.add(
      ElevatedButton(
        onPressed: () => setState(() {
          controllers.add(TextEditingController(text: ''));
        }),
        child: Text('Add new item to $key'),
      ),
    );
  }

  void _buildMapFields(
    List<Widget> fields,
    String key,
    Map<String, dynamic> map,
  ) {
    map.forEach((subKey, subValue) {
      final String fieldKey = '$key.$subKey';
      _controllers[fieldKey] ??= [
        TextEditingController(text: subValue.toString()),
      ];

      fields.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controllers[fieldKey]!.first,
                  decoration: InputDecoration(
                    labelText: fieldKey,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => setState(() {
                  map.remove(subKey);
                  _controllers.remove(fieldKey);
                }),
              ),
            ],
          ),
        ),
      );
    });

    fields.add(
      ElevatedButton(
        onPressed: () {
          const String newKey = 'newKey'; // Generate or ask for a new key
          map[newKey] = ''; // Default new value
          _controllers['$key.$newKey'] = [TextEditingController(text: '')];
          setState(() {});
        },
        child: Text('Add new entry to $key'),
      ),
    );
  }

  void _buildTextField(List<Widget> fields, String key, String value) {
    _controllers[key] ??= [TextEditingController(text: value)];
    fields.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: _controllers[key]!.first,
          decoration: InputDecoration(
            labelText: key,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
        ),
      ),
    );
  }

  Widget _buildArrayField(
    String key,
    int index,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '$key [$index]',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => setState(() {
              _controllers[key]?.removeAt(index);
            }),
          ),
        ],
      ),
    );
  }

  void _fetchData() {
    if (_searchController.text.trim().isEmpty) return;
    final String type = [
      'feats',
      'races',
      'spells',
      'classes',
      'items',
      'characters',
    ][_selectedIndex];
    final offline = context.read<SettingsCubit>().state.offlineMode;
    context
        .read<DatabaseEditorCubit>()
        .fetch(_searchController.text.trim(), type, offline: offline);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _slugController.dispose();
    _controllers.forEach((key, list) {
      for (final controller in list) {
        controller.dispose();
      }
    });
    super.dispose();
  }
}
