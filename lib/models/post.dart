import '../utils/html_utils.dart';

class Post {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String? imageUrl;
  final List<dynamic> tags; // Tag IDs for author identification
  final String link;
  final List<String> categories;
  final int commentCount;

  Post({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    this.imageUrl,
    required this.tags,
    required this.link,
    required this.categories,
    this.commentCount = 0,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String? imageUrl;
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'][0] != null) {
      imageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
    }

    List<String> categories = [];
    if (json['_embedded'] != null && json['_embedded']['wp:term'] != null) {
      final terms = json['_embedded']['wp:term'];
      if (terms.isNotEmpty) {
        final categoryTerms = terms[0];
        for (var term in categoryTerms) {
          categories.add(unescape.convert(term['name']));
        }
      }
    }

    return Post(
      id: json['id'],
      title: json['title']['rendered'],
      excerpt: json['excerpt']['rendered'],
      content: json['content']['rendered'],
      imageUrl: imageUrl,
      tags: json['tags'] ?? [],
      link: json['link'],
      categories: categories,
      commentCount: json['comment_count'] ?? 0,
    );
  }
}
