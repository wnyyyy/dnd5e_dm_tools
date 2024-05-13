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
  List<Object?> get props => [entries, name, imageUrl, isHidden, isImageHidden];

  factory Character.fromJson(Map<String, dynamic> json, String name) {
    return Character(
      entries: (json['entries'] as List)
          .map((e) => BulletPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      name: name,
      imageUrl: json['url'],
      isHidden: json['isHidden'] ?? false,
      isImageHidden: json['isImageHidden'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
      'name': name,
      'imageUrl': imageUrl,
      'isHidden': isHidden,
      'isImageHidden': isImageHidden,
    };
  }
}
