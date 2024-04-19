import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_cubit.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/cubit/screen_splitter_states.dart';
import 'package:dnd5e_dm_tools/features/screen_splitter/presentation/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScreenSplitter extends StatelessWidget {
  final Widget upperChild;
  final Widget lowerChild;

  const ScreenSplitter(
      {super.key, required this.upperChild, required this.lowerChild});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScreenSplitterCubit, ScreenSplitterState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state is! ScreenSplitterStateLowerExpanded)
              Expanded(child: upperChild),
            ScreenDivider(
              onUpper: () =>
                  context.read<ScreenSplitterCubit>().expandLowerScreen(),
              onLower: () =>
                  context.read<ScreenSplitterCubit>().expandUpperScreen(),
              onMiddle: () =>
                  context.read<ScreenSplitterCubit>().equalizeScreen(),
              upperHidden: state is ScreenSplitterStateLowerExpanded,
              lowerHidden: state is ScreenSplitterStateUpperExpanded,
            ),
            if (state is! ScreenSplitterStateUpperExpanded)
              Expanded(child: lowerChild),
          ],
        );
      },
    );
  }
}
