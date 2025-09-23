import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../models/post.dart';
import '../services/api_service.dart';
import '../utils/html_utils.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class CommentsSection extends StatefulWidget {
  final Post post;

  const CommentsSection({super.key, required this.post});

  @override
  State<CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  late Future<List<Comment>> _commentsFuture;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  void _loadComments() {
    _commentsFuture = ApiService.fetchComments(widget.post.id);
  }

  Future<void> _submitComment() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua field')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ApiService.postComment(
        postId: widget.post.id,
        authorName: _nameController.text.trim(),
        authorEmail: _emailController.text.trim(),
        content: _commentController.text.trim(),
      );

      // Clear form
      _commentController.clear();

      // Reload comments
      setState(() {
        _loadComments();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dikirim')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim komentar: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Komentar',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Comment Form
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tinggalkan Komentar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Komentar *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Kirim Komentar'),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Comments List
        FutureBuilder<List<Comment>>(
          future: _commentsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: LoadingWidget(),
              );
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: ErrorDisplayWidget(
                  message: 'Gagal memuat komentar',
                  onRetry: () {
                    setState(() {
                      _loadComments();
                    });
                  },
                ),
              );
            }

            final comments = snapshot.data ?? [];

            if (comments.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text('Belum ada komentar. Jadilah yang pertama!'),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return CommentTile(comment: comments[index]);
              },
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _commentController.dispose();
    super.dispose();
  }
}

class CommentTile extends StatelessWidget {
  final Comment comment;

  const CommentTile({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author and Date
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      child: Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatDate(comment.date),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Comment Content
                Text(
                  unescape.convert(comment.content),
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ),
        // Replies
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Column(
              children: comment.replies.map((reply) => CommentTile(comment: reply)).toList(),
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Hari ini';
      } else if (difference.inDays == 1) {
        return 'Kemarin';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
