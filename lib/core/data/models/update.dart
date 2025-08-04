import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Update extends Equatable {
  const Update({
    required this.id,
    required this.timestamp,
    required this.updatedEntries,
    required this.deletedEntries,
  });

  factory Update.fromJson(Map<String, dynamic> json, String documentId) {
    final updatedJson = Map<String, dynamic>.from(
      json['updated'] as Map? ?? {},
    );
    final updated = <UpdateEntries>[];
    updatedJson.forEach((key, value) {
      final List<String> values = List<String>.from(value as List? ?? []);
      updated.add(UpdateEntries.fromJson(key, values));
    });

    final deletedJson = Map<String, dynamic>.from(
      json['deleted'] as Map? ?? {},
    );
    final deleted = <UpdateEntries>[];
    deletedJson.forEach((key, value) {
      final List<String> values = List<String>.from(value as List? ?? []);
      deleted.add(UpdateEntries.fromJson(key, values));
    });

    return Update(
      id: documentId,
      timestamp: json['timestamp'] is Timestamp
          ? json['timestamp'] as Timestamp
          : Timestamp.fromMillisecondsSinceEpoch(
              (json['timestamp'] as num).toInt(),
            ),
      updatedEntries: updated,
      deletedEntries: deleted,
    );
  }

  final String id;
  final Timestamp timestamp;
  final List<UpdateEntries> updatedEntries;
  final List<UpdateEntries> deletedEntries;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'updated': Map.fromEntries(
        updatedEntries.map((e) => MapEntry(e.collection, e.documents)),
      ),
      'deleted': Map.fromEntries(
        deletedEntries.map((e) => MapEntry(e.collection, e.documents)),
      ),
    };
  }

  @override
  List<Object?> get props => [id, timestamp, updatedEntries, deletedEntries];
}

class UpdateEntries extends Equatable {
  const UpdateEntries({required this.collection, required this.documents});

  factory UpdateEntries.fromJson(String entry, List<String> value) {
    return UpdateEntries(collection: entry, documents: value);
  }

  Map<String, dynamic> toJson() {
    return {'collection': collection, 'documents': documents};
  }

  final String collection;
  final List<String> documents;

  @override
  List<Object?> get props => [collection, documents];
}
