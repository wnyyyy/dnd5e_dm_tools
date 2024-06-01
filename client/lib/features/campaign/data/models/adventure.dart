import 'package:dnd5e_dm_tools/features/campaign/data/models/bullet_point.dart';
import 'package:equatable/equatable.dart';

class Adventure extends Equatable {
  const Adventure({
    required this.entries,
  });

  factory Adventure.fromJson(dynamic json) {
    final bulletPoints = <BulletPoint>[];
    if (json is List) {
      for (var i = 0; i < json.length; i++) {
        final entry = json[i] as Map<String, dynamic>? ?? {};
        if (json[i] is String) {
          bulletPoints.add(
            BulletPoint(
              id: i.toString(),
              content: entry['content']?.toString() ?? '',
              timestamp: entry['timestamp'] as int? ?? 0,
            ),
          );
        }
      }
    }
    if (json is Map) {
      for (final entry in json.entries) {
        if (entry.value is String) {
          bulletPoints.add(
            BulletPoint(
              id: entry.key as String,
              content: (entry.value as Map)['content'] as String,
              timestamp: (entry.value as Map)['timestamp'] as int,
            ),
          );
        }
      }
    }
    return Adventure(
      entries: bulletPoints,
    );
  }
  final List<BulletPoint> entries;

  Adventure copyWith({
    List<BulletPoint>? entries,
  }) {
    return Adventure(
      entries: entries ?? this.entries,
    );
  }

  @override
  List<Object?> get props => [entries];
}
