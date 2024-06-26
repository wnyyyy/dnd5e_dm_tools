import 'dart:collection';
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
        final entry = Map<String, dynamic>.from(json[i] as LinkedHashMap);
        bulletPoints.add(
          BulletPoint(
            id: i.toString(),
            content: entry['content']?.toString() ?? '',
            timestamp: entry['timestamp'] as int? ?? 0,
          ),
        );
      }
    } else if (json is LinkedHashMap) {
      for (final entry in json.entries) {
        final value = Map<String, dynamic>.from(entry.value as LinkedHashMap);
        bulletPoints.add(
          BulletPoint(
            id: entry.key.toString(),
            content: value['content']?.toString() ?? '',
            timestamp: value['timestamp'] as int? ?? 0,
          ),
        );
      }
    }

    bulletPoints.sort((a, b) => a.timestamp.compareTo(b.timestamp));

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
