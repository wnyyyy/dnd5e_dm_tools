import 'package:equatable/equatable.dart';

class BulletPoint extends Equatable {
  final String id;
  final String content;

  const BulletPoint({
    required this.id,
    required this.content,
  });

  BulletPoint copyWith({
    String? id,
    String? content,
  }) {
    return BulletPoint(
      id: id ?? this.id,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [id, content];

  factory BulletPoint.fromJson(Map<String, dynamic> json) {
    return BulletPoint(
      id: json['id'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
    };
  }
}
