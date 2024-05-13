import 'package:equatable/equatable.dart';

class BulletPoint extends Equatable {
  final int id;
  final String content;

  const BulletPoint({
    required this.id,
    required this.content,
  });

  BulletPoint copyWith({
    int? id,
    String? content,
  }) {
    return BulletPoint(
      id: id ?? this.id,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [id, content];
}
