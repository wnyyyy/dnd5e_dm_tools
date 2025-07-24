class DeathSave {
  const DeathSave({required this.successes, required this.fails});

  factory DeathSave.fromJson(Map<String, dynamic> json) {
    final successes = json['successes'] as int? ?? 0;
    final fails = json['fails'] as int? ?? 0;

    return DeathSave(successes: successes, fails: fails);
  }

  final int successes;
  final int fails;

  Map<String, dynamic> toJson() {
    return {'successes': successes, 'fails': fails};
  }

  DeathSave copyWith({int? successes, int? fails}) {
    return DeathSave(
      successes: successes ?? this.successes,
      fails: fails ?? this.fails,
    );
  }

  @override
  String toString() => 'DeathSave successes: $successes, fails: $fails';
}
