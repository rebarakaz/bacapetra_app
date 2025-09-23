// lib/screens/rubrik_screen.dart
import 'package:flutter/material.dart';
import 'daftar_artikel_rubrik_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../models/category.dart';
import '../utils/html_utils.dart';

// fetchCategories() function has been moved to ApiService

class RubrikScreen extends StatefulWidget {
  const RubrikScreen({super.key});

  @override
  State<RubrikScreen> createState() => _RubrikScreenState();
}

class _RubrikScreenState extends State<RubrikScreen> {
  late Future<List<Category>> futureCategories;
  final List<Color> _cardColors = [
    Colors.blue.shade100,
    Colors.red.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.teal.shade100,
    Colors.pink.shade100,
    Colors.amber.shade100,
  ];

  @override
  void initState() {
    super.initState();
    futureCategories = ApiService.fetchCategories(); // Call from ApiService
  }

  Future<void> _refreshCategories() async {
    setState(() {
      futureCategories = ApiService.fetchCategories(); // Call from ApiService
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Gagal memuat rubrik.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshCategories,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshCategories,
            child: GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.2, // Adjust aspect ratio for better look
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Category category = snapshot.data![index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DaftarArtikelRubrikScreen(
                          categoryId: category.id,
                          categoryName: category.name,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: _cardColors[index % _cardColors.length],
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              unescape.convert(category.name),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${category.count} Tulisan',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const Center(child: Text('Tidak ada rubrik ditemukan.'));
        }
      },
    );
  }
}
