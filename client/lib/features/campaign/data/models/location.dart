import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final List<BulletPoint> entries;
  final String name;
  final String imageUrl;
  final bool isHidden;
  final bool isImageHidden;

  const Location({
    required this.entries,
    required this.imageUrl,
    required this.name,
    this.isHidden = false,
    this.isImageHidden = false,
  });

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

  factory Location.fromJson(Map<String, dynamic> json, String name) {
    final bulletPoints = <BulletPoint>[];
    if (json['entries'] is List) {
      for (var i = 0; i < json['entries'].length; i++) {
        if (json['entries'][i] is String) {
          bulletPoints.add(
            BulletPoint(id: i, content: json['entries'][i] as String),
          );
        }
      }
    }
    if (json['entries'] is Map) {
      for (final entry in json['entries'].entries) {
        if (entry.value is String) {
          bulletPoints.add(
            BulletPoint(
                id: int.parse(entry.key), content: entry.value as String),
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
}
