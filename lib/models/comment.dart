class Comment {
  final int id;
  final int post;
  final String authorName;
  final String authorEmail;
  final String content;
  final String date;
  final int parent; // 0 for top-level comments, parent ID for replies
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.post,
    required this.authorName,
    required this.authorEmail,
    required this.content,
    required this.date,
    required this.parent,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      post: json['post'] ?? 0,
      authorName: json['author_name'] ?? '',
      authorEmail: json['author_email'] ?? '',
      content: json['content']['rendered'] ?? '',
      date: json['date'] ?? '',
      parent: json['parent'] ?? 0,
    );
  }

  Comment copyWith({
    List<Comment>? replies,
  }) {
    return Comment(
      id: id,
      post: post,
      authorName: authorName,
      authorEmail: authorEmail,
      content: content,
      date: date,
      parent: parent,
      replies: replies ?? this.replies,
    );
  }
}
