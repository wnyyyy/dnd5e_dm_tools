import 'package:flutter/material.dart';

class ClassDescription extends StatefulWidget {
  const ClassDescription({
    super.key,
    required this.classs,
    required this.level,
    required this.editMode,
  });

  final Map<String, dynamic> classs;
  final Map<String, dynamic> level;
  final bool editMode;

  @override
  State<ClassDescription> createState() => _ClassDescriptionState();
}

class _ClassDescriptionState extends State<ClassDescription> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
