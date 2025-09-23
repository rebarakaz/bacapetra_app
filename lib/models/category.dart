
class Category {
  final int id;
  final String name;
  final int count;

  Category({required this.id, required this.name, required this.count});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      count: json['count'],
    );
  }
}
