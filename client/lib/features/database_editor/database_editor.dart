import 'dart:io';

import 'package:dnd5e_dm_tools/core/util/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_bloc.dart';
import 'package:dnd5e_dm_tools/features/characters/bloc/character_events.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseEditorScreen extends StatefulWidget {
  DatabaseEditorScreen({Key? key}) : super(key: key);

  @override
  _DatabaseEditorScreenState createState() => _DatabaseEditorScreenState();
}

class _DatabaseEditorScreenState extends State<DatabaseEditorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Race', 'Class', 'Item', 'Spell', 'Feat'];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    }
  }

  void _showInvalidateCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalidate Cache'),
          content: const Text('Select which cache to invalidate.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _invalidateCache('$cacheCharacterName.hive');
                Navigator.of(context).pop();
              },
              child: const Text('Character'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _invalidateCache(String file) async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDocumentDir.path}/$hiveFolder');
    final hiveFile = File('${hiveDir.path}/$file');
    if (await hiveFile.exists()) {
      await hiveFile.delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Editor'),
        actions: [
          TextButton(
            onPressed: _showInvalidateCacheDialog,
            child: const Text('Invalidate Cache'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _categories
              .map((String category) => Tab(text: category))
              .toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RaceEditorTab(),
          ClassEditorTab(),
          ItemEditorTab(),
          SpellEditorTab(),
          FeatEditorTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class RaceEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Race Editor'));
  }
}

class ClassEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Class Editor'));
  }
}

class ItemEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Item Editor'));
  }
}

class SpellEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Spell Editor'));
  }
}

class FeatEditorTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Feat Editor'));
  }
}
