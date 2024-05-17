import 'package:equatable/equatable.dart';

class BulletPoint extends Equatable {
  final String id;
  final String content;
  final int timestamp;

  const BulletPoint({
    required this.id,
    required this.content,
    required this.timestamp,
  });

  BulletPoint copyWith({
    String? id,
    String? content,
    int? timestamp,
  }) {
    return BulletPoint(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [id, content, timestamp];
}
