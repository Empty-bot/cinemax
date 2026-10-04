class CastMember {
  const CastMember({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  final int id;
  final String name;
  final String character;
  final String? profilePath;

  factory CastMember.fromJson(Map<String, dynamic> json) => CastMember(
        id: json['id'] as int,
        name: (json['name'] ?? '') as String,
        character: (json['character'] ?? '') as String,
        profilePath: json['profile_path'] as String?,
      );
}
