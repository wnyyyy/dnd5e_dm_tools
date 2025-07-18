import 'dart:collection';
import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Character extends Equatable {
  const Character({
    required this.entries,
    required this.imageUrl,
    required this.name,
    this.isHidden = false,
    this.isImageHidden = false,
  });

  factory Character.fromJson(Map<String, dynamic> json, String name) {
    final bulletPoints = <BulletPoint>[];
    if (json['entries'] is List) {
      for (var i = 0; i < (json['entries'] as List).length; i++) {
        final entry = Map<String, dynamic>.from(
          (json['entries'] as List)[i] as LinkedHashMap,
        );
        bulletPoints.add(
          BulletPoint(
            id: i.toString(),
            content: entry['content'] as String,
            timestamp: entry['timestamp'] as int,
          ),
        );
      }
    } else if (json['entries'] is Map) {
      final entriesMap = json['entries'] as LinkedHashMap;
      for (final entry in entriesMap.entries) {
        if (entry.value is LinkedHashMap) {
          bulletPoints.add(
            BulletPoint(
              id: entry.key.toString(),
              content: (entry.value as LinkedHashMap)['content'] as String,
              timestamp: (entry.value as LinkedHashMap)['timestamp'] as int,
            ),
          );
        }
      }
    }
    return Character(
      entries: bulletPoints,
      name: name,
      imageUrl: json['url'] as String,
      isHidden: json['isHidden'] as bool? ?? false,
      isImageHidden: json['isImageHidden'] as bool? ?? false,
    );
  }

  final List<BulletPoint> entries;
  final String name;
  final String imageUrl;
  final bool isHidden;
  final bool isImageHidden;

  Character copyWith({
    List<BulletPoint>? entries,
    String? imageUrl,
    String? name,
    bool? isHidden,
    bool? isImageHidden,
  }) {
    return Character(
      entries: entries ?? this.entries,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isHidden: isHidden ?? this.isHidden,
      isImageHidden: isImageHidden ?? this.isImageHidden,
    );
  }

  @override
  List<Object?> get props => [
        entries,
        name,
        imageUrl,
        isHidden,
        isImageHidden,
      ];
}
