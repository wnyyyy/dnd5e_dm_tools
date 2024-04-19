class ASI {
  final int raceId;
  final String attribute;
  final int value;

  ASI({
    required this.raceId,
    required this.attribute,
    required this.value,
  });

  static ASI fromMap(Map<String, dynamic> c) {
    return ASI(
      raceId: c['race_id'] as int,
      attribute: c['attribute'] as String,
      value: c['value'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'race_id': raceId,
      'attribute': attribute,
      'value': value,
    };
  }
}
