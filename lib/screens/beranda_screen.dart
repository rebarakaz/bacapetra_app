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
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
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
                    margin: const EdgeInsets.symmetric(vertical: 12.0),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
