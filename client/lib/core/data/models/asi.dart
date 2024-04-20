class ASI {
  final String attribute;
  final int value;

  ASI({
    required this.attribute,
    required this.value,
  });

  static ASI fromMap(Map<String, dynamic> c) {
    return ASI(
      attribute: c['attributes'][0] as String,
      value: c['value'] as int,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'attribute': attribute,
      'value': value,
    };
  }
}
