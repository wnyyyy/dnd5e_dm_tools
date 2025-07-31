import 'package:dnd5e_dm_tools/features/main_screen/bloc/main_screen_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            child: Text(
              'D&D 5e Toolbox',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Character'),
            onTap: () {
              BlocProvider.of<MainScreenCubit>(context).showCharacter();
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              BlocProvider.of<MainScreenCubit>(context).showSettings();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage),
            title: const Text('Database'),
            onTap: () {
              BlocProvider.of<MainScreenCubit>(context).showDatabase();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
