class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.origin,
    required this.image,
  });

  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String origin;
  final String image;

  factory Character.fromJson(Map<String, dynamic> json) {
    final origin = json['origin'];
    return Character(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Sin nombre',
      status: json['status'] as String? ?? 'Unknown',
      species: json['species'] as String? ?? 'Unknown',
      gender: json['gender'] as String? ?? 'Unknown',
      origin: origin is Map<String, dynamic>
          ? origin['name'] as String? ?? 'Unknown'
          : 'Unknown',
      image: json['image'] as String? ?? '',
    );
  }

  Character copyWith({
    String? name,
    String? status,
    String? species,
    String? gender,
    String? origin,
    String? image,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      gender: gender ?? this.gender,
      origin: origin ?? this.origin,
      image: image ?? this.image,
    );
  }
}
