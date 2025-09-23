// lib/screens/daftar_artikel_rubrik_screen.dart

import 'package:flutter/material.dart';

import '../models/post.dart';
import 'detail_artikel_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../utils/html_utils.dart';

// fetchPostsByCategory() function has been moved to ApiService

class DaftarArtikelRubrikScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const DaftarArtikelRubrikScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<DaftarArtikelRubrikScreen> createState() => _DaftarArtikelRubrikScreenState();
}

class _DaftarArtikelRubrikScreenState extends State<DaftarArtikelRubrikScreen> {
  final List<Post> _posts = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newPosts = await ApiService.fetchPostsByCategory(widget.categoryId, page: _currentPage); // Call from ApiService
      setState(() {
        if (newPosts.isEmpty) {
          _hasMore = false;
        } else {
          _posts.addAll(newPosts);
          _currentPage++;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Optionally, show a snackbar or a toast message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat tulisan: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _posts.clear();
      _currentPage = 1;
      _hasMore = true;
      _isLoading = false;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unescape.convert(widget.categoryName)),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildPostList(),
      ),
    );
  }

  Widget _buildPostList() {
    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_posts.isEmpty && !_hasMore) {
      return const Center(child: Text('Tidak ada tulisan di rubrik ini.'));
    } else {
      return ListView.builder(
        controller: _scrollController,
        itemCount: _posts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final post = _posts[index];
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
              margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
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
      );
    }
  }
}
