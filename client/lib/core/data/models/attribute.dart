class Attribute {
  final String name;

  Attribute({
    required this.name,
  });

  static Attribute fromMap(Map<String, dynamic> c) {
    return Attribute(
      name: c['name'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'name': name,
    };
  }
}
