// lib/screens/cari_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hasil_pencarian_screen.dart';

class CariScreen extends StatefulWidget {
  const CariScreen({super.key});

  @override
  State<CariScreen> createState() => _CariScreenState();
}

class _CariScreenState extends State<CariScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = [];
  static const String _kRecentSearchesKey = 'recent_searches';

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList(_kRecentSearchesKey) ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus jika sudah ada untuk dipindahkan ke atas
    _recentSearches.remove(query);
    // Tambahkan ke paling atas
    _recentSearches.insert(0, query);
    // Batasi hanya 10 item
    if (_recentSearches.length > 10) {
      _recentSearches = _recentSearches.sublist(0, 10);
    }
    await prefs.setStringList(_kRecentSearchesKey, _recentSearches);
    setState(() {});
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kRecentSearchesKey);
    setState(() {
      _recentSearches = [];
    });
  }

  void _jalankanPencarian([String? query]) {
    final searchQuery = query ?? _searchController.text;
    if (searchQuery.isNotEmpty) {
      _saveRecentSearch(searchQuery);
      _searchController.clear();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HasilPencarianScreen(
            searchQuery: searchQuery,
          ),
        ),
      ).then((_) => _loadRecentSearches()); // Muat ulang riwayat saat kembali
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Cari artikel, penulis, atau topik...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _jalankanPencarian(),
            ),
          ),
          onSubmitted: _jalankanPencarian,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => _jalankanPencarian(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 16),
          ),
          child: const Text('Cari'),
        ),
        const SizedBox(height: 32),
        if (_recentSearches.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Riwayat Pencarian',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: _clearRecentSearches,
                    child: const Text('Hapus Semua'),
                  ),
                ],
              ),
              const Divider(),
              ..._recentSearches.map((term) {
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(term),
                  onTap: () {
                    _searchController.text = term;
                    _jalankanPencarian(term);
                  },
                );
              }),
            ],
          ),
      ],
    );
  }
}
