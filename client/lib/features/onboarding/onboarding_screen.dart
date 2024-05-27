import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        if (settingsState is SettingsInitial) {
          context.read<SettingsCubit>().init();
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (settingsState is SettingsError) {
          return ErrorHandler(error: settingsState.message);
        }
        if (settingsState is SettingsLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (settingsState is SettingsLoaded) {
          return BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (context, state) {
              if (state is OnboardingInitial) {
                context.read<OnboardingCubit>().loadCharacters();
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is OnboardingError) {
                return ErrorHandler(error: state.message);
              }
              if (state is OnboardingLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (state is OnboardingLoaded) {
                return _buildOnboardingContent(
                    context, state.characters, state.selectedCharacter);
              }

              return Container();
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildOnboardingContent(
    BuildContext context,
    Map<String, dynamic> characters,
    String selectedCharacter,
  ) {
    final PageController pageController = PageController(initialPage: 999);

    return OrientationBuilder(
      builder: (context, orientation) {
        return Scaffold(
          body: Center(
            child: orientation == Orientation.portrait
                ? _buildPortraitContent(
                    context, characters, selectedCharacter, pageController)
                : _buildLandscapeContent(
                    context, characters, selectedCharacter, pageController),
          ),
        );
      },
    );
  }

  Color hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Widget _buildPortraitContent(
      BuildContext context,
      Map<String, dynamic> characters,
      String selectedCharacter,
      PageController pageController) {
    final screenHeight = MediaQuery.of(context).size.height;
    final character = characters[selectedCharacter];
    final longName = character['name'].length > 7;
    final baseTheme = longName
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;
    var color = character['color'] ?? Theme.of(context).colorScheme.onSurface;
    if (color is String) {
      color = hexToColor(color);
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: screenHeight * 0.8,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              final currentIndex = index % characters.length;
              final slug = characters.keys.elementAt(currentIndex);
              context.read<OnboardingCubit>().selectCharacter(slug);
            },
            itemBuilder: (context, index) {
              final characterPaged =
                  characters.values.elementAt(index % characters.length);
              return Image.network(
                characterPaged['image_url'],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        SizedBox(height: screenHeight * 0.03),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: IconButton(
                iconSize: 36,
                onPressed: () {
                  final targetPage = pageController.page!.toInt() - 1;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Elusive.left_open, color: color),
              ),
            ),
            Expanded(
              child: Padding(
                padding: longName
                    ? const EdgeInsets.only(top: 8)
                    : const EdgeInsets.only(top: 0),
                child: Text(
                  character['name'],
                  textAlign: TextAlign.center,
                  style: baseTheme!.copyWith(
                    fontFamily: GoogleFonts.patuaOne().fontFamily,
                    color: color,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 8),
              child: IconButton(
                iconSize: 36,
                onPressed: () {
                  final targetPage = pageController.page!.toInt() + 1;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Elusive.right_open, color: color),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLandscapeContent(
      BuildContext context,
      Map<String, dynamic> characters,
      String selectedCharacter,
      PageController pageController) {
    final character = characters[selectedCharacter];
    final longName = character['name'].length > 7;
    final baseTheme = longName
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;
    var color = character['color'] ?? Theme.of(context).colorScheme.onSurface;
    if (color is String) {
      color = hexToColor(color);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            controller: pageController,
            onPageChanged: (index) {
              final currentIndex = index % characters.length;
              final slug = characters.keys.elementAt(currentIndex);
              context.read<OnboardingCubit>().selectCharacter(slug);
            },
            itemBuilder: (context, index) {
              final characterPaged =
                  characters.values.elementAt(index % characters.length);
              return Image.network(
                characterPaged['image_url'],
              );
            },
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 36,
                onPressed: () {
                  final targetPage = pageController.page!.toInt() - 1;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Elusive.up_open, color: color),
              ),
              Padding(
                padding: longName
                    ? const EdgeInsets.symmetric(vertical: 6)
                    : const EdgeInsets.symmetric(vertical: 0),
                child: Text(
                  character['name'],
                  textAlign: TextAlign.center,
                  style: baseTheme!.copyWith(
                    fontFamily: GoogleFonts.patuaOne().fontFamily,
                    color: color,
                  ),
                ),
              ),
              IconButton(
                iconSize: 36,
                onPressed: () {
                  final targetPage = pageController.page!.toInt() + 1;
                  pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                icon: Icon(Elusive.down_open, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
