import 'package:dnd5e_dm_tools/core/config/app_themes.dart';
import 'package:dnd5e_dm_tools/core/util/enum.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(settings.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            context.read<SettingsCubit>().changeTheme(
                  settings.themeColor,
                  !settings.isDarkMode,
                );
          },
        ),
        IconButton(
          icon: const Icon(Icons.palette),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: ThemeColor.values.map((ThemeColor value) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: settings.isDarkMode
                                ? value.darkColor
                                : value.lightColor,
                            radius: 10,
                          ),
                          title: Text(value.name),
                          onTap: () {
                            context.read<SettingsCubit>().changeTheme(
                                  value,
                                  settings.isDarkMode,
                                );
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
