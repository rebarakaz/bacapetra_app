// lib/screens/hasil_pencarian_screen.dart

import 'package:flutter/material.dart';

import '../models/post.dart';
import 'detail_artikel_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../utils/html_utils.dart';

// fetchSearchResults() function has been moved to ApiService

class HasilPencarianScreen extends StatefulWidget {
  final String searchQuery;

  const HasilPencarianScreen({
    super.key,
    required this.searchQuery,
  });

  @override
  State<HasilPencarianScreen> createState() => _HasilPencarianScreenState();
}

class _HasilPencarianScreenState extends State<HasilPencarianScreen> {
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
      final newPosts = await ApiService.fetchSearchResults(widget.searchQuery, page: _currentPage); // Call from ApiService
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat hasil: $e')),
        );
      }
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
        title: Text('Hasil untuk "${widget.searchQuery}"'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildResultsList(),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_posts.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_posts.isEmpty && !_hasMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Tidak ada hasil ditemukan',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Coba gunakan kata kunci yang berbeda.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
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
          // Menggunakan layout kartu modern yang sama
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
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
