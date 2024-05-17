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

  factory Adventure.fromJson(dynamic json) {
    final bulletPoints = <BulletPoint>[];
    if (json is List) {
      for (var i = 0; i < json.length; i++) {
        final entry = json[i];
        if (json[i] is String) {
          bulletPoints.add(
            BulletPoint(
              id: i.toString(),
              content: entry['content'] as String,
              timestamp: entry['timestamp'],
            ),
          );
        }
      }
    }
    if (json is Map) {
      for (var entry in json.entries) {
        if (entry.value is String) {
          bulletPoints.add(
            BulletPoint(
              id: entry.key,
              content: entry.value['content'] as String,
              timestamp: entry.value['timestamp'] as int,
            ),
          );
        }
      }
    }
    return Adventure(
      entries: bulletPoints,
    );
  }
}
