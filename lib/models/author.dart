class Author {
  final int id;
  final String name;
  final String slug;
  final int count; // number of posts with this tag

  Author({
    required this.id,
    required this.name,
    required this.slug,
    required this.count,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      count: json['count'] ?? 0,
    );
  }
}
