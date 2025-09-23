// lib/screens/bookmark_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/bookmark_provider.dart';
import '../models/post.dart';
import 'detail_artikel_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../utils/html_utils.dart';

// _fetchBookmarkedPosts() function has been moved to ApiService

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer untuk mendapatkan data dari BookmarkProvider
    return Consumer<BookmarkProvider>(
      builder: (context, bookmarkProvider, child) {
        if (bookmarkProvider.bookmarkIds.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Anda belum menyimpan artikel.', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        // Gunakan FutureBuilder untuk mengambil data post berdasarkan ID
        return FutureBuilder<List<Post>>(
          future: ApiService.fetchBookmarkedPosts(bookmarkProvider.bookmarkIds), // Call from ApiService
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat bookmark: ${snapshot.error}'));
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final posts = snapshot.data!;
              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  // Gunakan layout kartu yang sama dengan Beranda
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailArtikelScreen(post: post),
                        ),
                      ).then((_) => setState(() {})); // Refresh saat kembali
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

            return const Center(child: Text('Tidak ada artikel ditemukan.'));
          },
        );
      },
    );
  }
}
