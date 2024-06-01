import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  const Location({
    required this.entries,
    required this.imageUrl,
    required this.name,
    this.isHidden = false,
    this.isImageHidden = false,
  });

  factory Location.fromJson(Map<String, dynamic> json, String name) {
    final bulletPoints = <BulletPoint>[];
    if (json['entries'] is List) {
      for (var i = 0; i < (json['entries'] as List).length; i++) {
        final entry = (json['entries'] as List)[i];
        if (entry is Map<String, dynamic>) {
          bulletPoints.add(
            BulletPoint(
              id: i.toString(),
              content: entry['content'] as String,
              timestamp: entry['timestamp'] as int,
            ),
          );
        }
      }
    } else if (json['entries'] is Map) {
      final entriesMap = json['entries'] as Map<String, dynamic>;
      for (final entry in entriesMap.entries) {
        if (entry.value is Map<String, dynamic>) {
          bulletPoints.add(
            BulletPoint(
              id: entry.key,
              content: (entry.value as Map)['content'] as String,
              timestamp: (entry.value as Map)['timestamp'] as int,
            ),
          );
        }
      }
    }
    return Location(
      entries: bulletPoints,
      name: name,
      imageUrl: json['url'] as String? ?? '',
      isHidden: json['isHidden'] as bool? ?? false,
      isImageHidden: json['isImageHidden'] as bool? ?? false,
    );
  }

  final List<BulletPoint> entries;
  final String name;
  final String imageUrl;
  final bool isHidden;
  final bool isImageHidden;

  Location copyWith({
    List<BulletPoint>? entries,
    String? imageUrl,
    String? name,
    bool? isHidden,
    bool? isImageHidden,
  }) {
    return Location(
      entries: entries ?? this.entries,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      isHidden: isHidden ?? this.isHidden,
      isImageHidden: isImageHidden ?? this.isImageHidden,
    );
  }

  @override
  List<Object?> get props => [entries, name, imageUrl, isHidden, isImageHidden];
}
