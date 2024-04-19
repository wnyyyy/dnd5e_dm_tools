import 'package:dnd5e_dm_tools/core/enum.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_cubit.dart';
import 'package:dnd5e_dm_tools/features/header/cubit/header_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HeaderCubit, HeaderState>(
      builder: (context, state) {
        return AppBar(
          title: Text(state.pageTitle),
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          actions: [
            IconButton(
              icon: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () => context.read<HeaderCubit>().toggleDarkMode(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Icon(
                state.connectionStatus == ConnectionStatus.connected
                    ? Icons.signal_cellular_alt
                    : state.connectionStatus == ConnectionStatus.connecting
                        ? Icons.link
                        : Icons.link_off,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
