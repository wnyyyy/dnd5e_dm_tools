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

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      entries: (json['entries'] as List)
          .map((e) => BulletPoint.fromJson(e))
          .toList(),
      name: json['name'],
      imageUrl: json['imageUrl'],
      isHidden: json['isHidden'],
      isImageHidden: json['isImageHidden'],
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
