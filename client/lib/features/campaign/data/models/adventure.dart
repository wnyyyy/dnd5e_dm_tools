import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Adventure extends Equatable {
  final List<BulletPoint> entries;

  const Adventure({
    required this.entries,
  });

  Adventure copyWith({
    List<BulletPoint>? entries,
  }) {
    return Adventure(
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [entries];

  factory Adventure.fromJson(Map<String, dynamic> json) {
    return Adventure(
      entries: (json['entries'] as List)
          .map((e) => BulletPoint.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entries': entries.map((e) => e.toJson()).toList(),
    };
  }
}
