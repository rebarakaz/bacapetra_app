// lib/screens/cari_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bacapetra_app/services/api_service.dart';
import 'package:bacapetra_app/models/post.dart';
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
  
  // Live search variables
  List<Post> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  Timer? _debounce;
  
  // Debounce duration
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    // Add listener for live search
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
        _isSearching = false;
      });
      return;
    }
    
    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });
    
    _debounce = Timer(_debounceDuration, () {
      _performLiveSearch(query);
    });
  }
  
  Future<void> _performLiveSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    try {
      final results = await ApiService.fetchSearchResults(query, perPage: 5);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }
  
  void _navigateToSearchResults(String query) {
    _saveRecentSearch(query);
    _searchController.clear();
    setState(() {
      _showSearchResults = false;
      _searchResults = [];
    });
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HasilPencarianScreen(
          searchQuery: query,
        ),
      ),
    ).then((_) => _loadRecentSearches());
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
      _navigateToSearchResults(searchQuery);
    }
  }

  Widget _buildLiveSearchResults() {
    if (!_showSearchResults) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Mencari...'),
                ],
              ),
            )
          else if (_searchResults.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.search_off, size: 40, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak ada hasil untuk "${_searchController.text}"',
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_searchResults.length} hasil untuk "${_searchController.text}"',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _navigateToSearchResults(_searchController.text),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ..._searchResults.take(5).map((post) {
              return ListTile(
                leading: post.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          post.imageUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 40,
                              height: 40,
                              color: Colors.grey[300],
                              child: const Icon(Icons.article, color: Colors.grey),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(Icons.article, color: Colors.grey),
                      ),
                title: Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  post.categories.isNotEmpty ? post.categories.first : 'Artikel',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  _navigateToSearchResults(_searchController.text);
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari'),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
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
          
          // Live search results
          _buildLiveSearchResults(),
          
          const SizedBox(height: 20),
          
          // Traditional search button
          ElevatedButton(
            onPressed: () => _jalankanPencarian(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Cari'),
          ),
          
          const SizedBox(height: 32),
          
          // Recent searches
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
      ),
    );
  }
}
