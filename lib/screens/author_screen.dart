import 'package:flutter/material.dart';
import 'detail_artikel_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../models/post.dart';
import '../models/author.dart';
import '../utils/html_utils.dart';

// fetchPostsByAuthorTag() and fetchAuthorByTagId() functions have been moved to ApiService

class AuthorScreen extends StatefulWidget {
  final int tagId;
  final String? authorName;

  const AuthorScreen({super.key, required this.tagId, this.authorName});

  @override
  State<AuthorScreen> createState() => _AuthorScreenState();
}

class _AuthorScreenState extends State<AuthorScreen> {
  late Future<List<Post>> futureAuthorPosts;
  late Future<Author?> futureAuthor;

  @override
  void initState() {
    super.initState();
    futureAuthorPosts = ApiService.fetchPostsByAuthorTag(widget.tagId); // Call from ApiService
    futureAuthor = ApiService.fetchAuthorByTagId(widget.tagId); // Call from ApiService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<Author?>(
          future: futureAuthor,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Text(unescape.convert(snapshot.data!.name));
            } else if (widget.authorName != null) {
              return Text(unescape.convert(widget.authorName!));
            } else {
              return const Text('Penulis');
            }
          },
        ),
      ),
      body: FutureBuilder<List<Post>>(
        future: futureAuthorPosts,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final posts = snapshot.data!;
            return CustomScrollView(
              slivers: [
                // Author info header
                SliverToBoxAdapter(
                  child: FutureBuilder<Author?>(
                    future: futureAuthor,
                    builder: (context, authorSnapshot) {
                      if (authorSnapshot.hasData && authorSnapshot.data != null) {
                        final author = authorSnapshot.data!;
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                unescape.convert(author.name),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${author.count} artikel diterbitkan',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Articles list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = posts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: ListTile(
                          leading: post.imageUrl != null
                              ? SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      post.imageUrl!,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(child: CircularProgressIndicator());
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.broken_image);
                                      },
                                    ),
                                  ),
                                )
                              : null,
                          title: Text(
                            unescape.convert(post.title),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            unescape.convert(post.excerpt.replaceAll(RegExp(r'<[^>]*>'), '')),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailArtikelScreen(post: post),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: posts.length,
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Gagal memuat artikel penulis',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        futureAuthorPosts = ApiService.fetchPostsByAuthorTag(widget.tagId); // Call from ApiService
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
