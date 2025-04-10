class Personality {
  final String id;
  final String mbti;
  final String name;
  final String title;
  final List<String> traits;

  Personality({
    required this.id,
    required this.mbti,
    required this.name,
    required this.title,
    required this.traits,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      id: json['id'],
      mbti: json['mbti'],
      name: json['name'],
      title: json['title'],
      traits: List<String>.from(json['traits']),
    );
  }
}