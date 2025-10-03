// lib/screens/beranda_screen.dart

import 'package:flutter/material.dart';
import 'detail_artikel_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../models/post.dart';
import '../utils/html_utils.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('BerandaScreen');

// fetchPosts() function has been moved to ApiService

// Ubah nama widget dari HomePage menjadi BerandaScreen
class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  late Future<List<Post>> futurePosts;
  late Future<List<Post>> futurePopularPosts;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      errorMessage = '';
    });
    try {
      futurePosts = ApiService.fetchDiversePosts(postsPerCategory: 2);
      futurePopularPosts = ApiService.fetchPopularPosts(perPage: 5);
    } catch (e, stackTrace) {
      _logger.severe('Error loading posts: $e', e, stackTrace);
      setState(() {
        errorMessage = 'Gagal memuat tulisan: $e';
      });
    }
  }

  // Fungsi untuk memuat ulang data post
  Future<void> _refreshPosts() async {
    _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: futurePosts,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          _logger.severe('Snapshot error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Gagal memuat tulisan.\nSilakan coba lagi.'),
                if (snapshot.error != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      snapshot.error.toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPosts,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshPosts,
            child: CustomScrollView(
              slivers: [
                // Popular Posts Section
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Populer',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Post>>(
                        future: futurePopularPosts,
                        builder: (context, popularSnapshot) {
                          if (popularSnapshot.connectionState == ConnectionState.waiting) {
                            return const SizedBox(
                              height: 120,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (popularSnapshot.hasData && popularSnapshot.data!.isNotEmpty) {
                            // Filter posts that have comments (commentCount > 0)
                            final postsWithComments = popularSnapshot.data!.where((post) => post.commentCount > 0).take(5).toList();

                            if (postsWithComments.isEmpty) {
                              return const SizedBox.shrink(); // Don't show section if no posts have comments
                            }

                            return SizedBox(
                              height: 200,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: postsWithComments.length,
                                itemBuilder: (context, index) {
                                  Post post = postsWithComments[index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailArtikelScreen(post: post),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 160,
                                      margin: const EdgeInsets.only(right: 12.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.antiAliasWithSaveLayer,
                                        elevation: 3,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (post.imageUrl != null)
                                              Hero(
                                                tag: 'popular-post-image-${post.id}',
                                                child: Image.network(
                                                  post.imageUrl!,
                                                  width: double.infinity,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null) return child;
                                                    return const SizedBox(
                                                      height: 100,
                                                      child: Center(child: CircularProgressIndicator()),
                                                    );
                                                  },
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const SizedBox(
                                                      height: 100,
                                                      child: Icon(Icons.broken_image, size: 20),
                                                    );
                                                  },
                                                ),
                                              ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    unescape.convert(post.title),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.comment,
                                                        size: 12,
                                                        color: Theme.of(context).colorScheme.secondary,
                                                      ),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        '${post.commentCount} komentar',
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                          color: Theme.of(context).colorScheme.secondary,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text(
                          'Semua Tulisan',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Regular Posts List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      Post post = snapshot.data![index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailArtikelScreen(post: post),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (post.imageUrl != null)
                                Hero(
                                  tag: 'post-image-${post.id}',
                                  child: Image.network(
                                    post.imageUrl!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(32.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return const SizedBox(
                                        height: 200,
                                        child: Icon(Icons.broken_image, size: 40),
                                      );
                                    },
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (post.categories.isNotEmpty)
                                      Wrap(
                                        spacing: 8.0,
                                        runSpacing: 4.0,
                                        children: post.categories.map((category) {
                                          return Chip(
                                            label: Text(category),
                                            labelStyle: const TextStyle(fontSize: 12),
                                            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20.0),
                                              side: BorderSide(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    const SizedBox(height: 12),
                                    Text(
                                      unescape.convert(post.title),
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      unescape.convert(post.excerpt.replaceAll(RegExp(r'<[^>]*>'), '')),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          calculateReadingTime(post.content),
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.secondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada tulisan untuk ditampilkan.'),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      errorMessage,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshPosts,
                  child: const Text('Muat Ulang'),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
