import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Character extends Equatable {
  final List<BulletPoint> entries;
  final String name;
  final String imageUrl;
  final bool isHidden;
  final bool isImageHidden;

  const Character({
    required this.entries,
    required this.imageUrl,
    required this.name,
    this.isHidden = false,
    this.isImageHidden = false,
  });

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

  factory Character.fromJson(Map<String, dynamic> json, String name) {
    final bulletPoints = <BulletPoint>[];
    if (json['entries'] is List) {
      for (var i = 0; i < json['entries'].length; i++) {
        if (json['entries'][i] is String) {
          final entry = json['entries'][i];
          bulletPoints.add(
            BulletPoint(
              id: i.toString(),
              content: entry['content'] as String,
              timestamp: entry['timestamp'] as int,
            ),
          );
        }
      }
    }
    if (json['entries'] is Map) {
      for (final entry in json['entries'].entries) {
        if (entry.value is String) {
          bulletPoints.add(
            BulletPoint(
              id: entry.key,
              content: entry.value as String,
              timestamp: entry.value['timestamp'] as int,
            ),
          );
        }
      }
    }
    return Character(
      entries: bulletPoints,
      name: name,
      imageUrl: json['url'],
      isHidden: json['isHidden'] ?? false,
      isImageHidden: json['isImageHidden'] ?? false,
    );
  }
}
