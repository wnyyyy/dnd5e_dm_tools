import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dnd5e_dm_tools/core/widgets/error_handler.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:dnd5e_dm_tools/features/onboarding/bloc/onboarding_state.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_cubit.dart';
import 'package:dnd5e_dm_tools/features/settings/bloc/settings_states.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  late PageController pageController;
  int currentPage = 1000;
  bool isMouseScrolling = false;

  late Future<void> preloadImages;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: currentPage);
    preloadImages = _preloadCharacterImages();
  }

  Future<void> _preloadCharacterImages() async {
    final characters = context.read<OnboardingCubit>().state.characters;
    for (final character in characters.values) {
      await precacheImage(
        NetworkImage((character as Map)['image_url']?.toString() ?? ''),
        context,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent &&
            event.kind == PointerDeviceKind.mouse) {
          setState(() {
            isMouseScrolling = true;
          });
        } else {
          setState(() {
            isMouseScrolling = false;
          });
        }
      },
      child: FutureBuilder<void>(
        future: preloadImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildOnboardingContent();
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget _buildOnboardingContent() {
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
                context.read<OnboardingCubit>().loadCharacters(currentPage);
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
                return _buildOnboardingContentDetails(
                  context,
                  state.characters,
                  state.selectedCharacter,
                );
              }

              return Container();
            },
          );
        }
        return Container();
      },
    );
  }

  Widget _buildOnboardingContentDetails(
    BuildContext context,
    Map<String, dynamic> characters,
    String selectedCharacter,
  ) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Center(
          child: orientation == Orientation.portrait
              ? _buildPortraitContent(
                  context,
                  characters,
                  selectedCharacter,
                  pageController,
                )
              : _buildLandscapeContent(
                  context,
                  characters,
                  selectedCharacter,
                  pageController,
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
    PageController pageController,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final character = characters[selectedCharacter] as Map<String, dynamic>;
    final longName = (character['name']?.toString() ?? '').length > 7;
    final baseTheme = longName
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;
    final colorChar = character['color']?.toString() ?? '';
    final Color color;
    if (colorChar.isEmpty) {
      color = hexToColor(colorChar);
    } else {
      color = Theme.of(context).colorScheme.onSurface;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: screenHeight * 0.8,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              final currentIndex = index % characters.length;
              final slug = characters.keys.elementAt(currentIndex);
              context.read<OnboardingCubit>().selectCharacter(slug);
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final characterPaged = characters.values
                  .elementAt(index % characters.length) as Map<String, dynamic>;
              return CachedNetworkImage(
                imageUrl: characterPaged['image_url']?.toString() ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
          ),
        ),
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
                padding:
                    longName ? const EdgeInsets.only(top: 12) : EdgeInsets.zero,
                child: Text(
                  character['name']?.toString() ?? '',
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
        _buildAdvanceButton(context, selectedCharacter, character),
      ],
    );
  }

  Widget _buildAdvanceButton(
    BuildContext context,
    String selectedCharacter,
    Map<String, dynamic> character,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: ElevatedButton(
        onPressed: () {
          var caster = false;
          if (character['known_spells'] != null &&
              (character['known_spells'] as List).isNotEmpty) {
            caster = true;
          }
          context
              .read<SettingsCubit>()
              .changeName(name: selectedCharacter, caster: caster);
        },
        child: const Text('Start', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildLandscapeContent(
    BuildContext context,
    Map<String, dynamic> characters,
    String selectedCharacter,
    PageController pageController,
  ) {
    final character = characters[selectedCharacter] as Map<String, dynamic>;
    final longName = (character['name']?.toString() ?? '').length > 7;
    final baseTheme = longName
        ? Theme.of(context).textTheme.displayMedium
        : Theme.of(context).textTheme.displayLarge;
    final colorChar = character['color']?.toString() ?? '';
    final Color color;
    if (colorChar.isEmpty) {
      color = hexToColor(colorChar);
    } else {
      color = Theme.of(context).colorScheme.onSurface;
    }
    final extraScrollSpeed = MediaQuery.of(context).size.height * 0.6;
    pageController.addListener(() {
      final ScrollDirection scrollDirection =
          pageController.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle && isMouseScrolling) {
        double scrollEnd = pageController.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(
          pageController.position.maxScrollExtent,
          max(pageController.position.minScrollExtent, scrollEnd),
        );
        pageController.jumpTo(scrollEnd);
      }
    });
    return Row(
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
              setState(() {
                currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final characterPaged =
                  characters.values.elementAt(index % characters.length) as Map;
              return CachedNetworkImage(
                imageUrl: characterPaged['image_url']?.toString() ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              );
            },
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              Container(
                width: double.infinity,
                padding: longName
                    ? const EdgeInsets.symmetric(vertical: 6)
                    : EdgeInsets.zero,
                child: Text(
                  character['name']?.toString() ?? '',
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
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child:
                    _buildAdvanceButton(context, selectedCharacter, character),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
