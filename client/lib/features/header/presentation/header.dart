import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/font_awesome_icons.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeaderCubit, HeaderState>(
      builder: (context, state) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: [
            IconButton(
              icon: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => context.read<HeaderCubit>().toggleDarkMode(),
            ),
            IconButton(
              icon: const Icon(FontAwesome.picture),
              onPressed: () => context.read<HeaderCubit>().toggleDarkMode(),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
