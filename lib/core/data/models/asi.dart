class ASI {
  final String raceSlug;
  final String attribute;
  final int value;

  ASI({
    required this.raceSlug,
    required this.attribute,
    required this.value,
  });

  static ASI fromMap(Map<String, dynamic> c) {
    return ASI(
      raceSlug: c['race_slug'] as String,
      attribute: c['attribute'] as String,
      value: c['value'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'race_slug': raceSlug,
      'attribute': attribute,
      'value': value,
    };
  }
}
