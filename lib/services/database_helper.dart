import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/post.dart';

class DatabaseHelper {
  static const String _databaseName = 'bacapetra.db';
  static const int _databaseVersion = 1;

  static const String tableOfflinePosts = 'offline_posts';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableOfflinePosts (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        excerpt TEXT,
        imageUrl TEXT,
        tags TEXT,
        categories TEXT,
        link TEXT NOT NULL,
        savedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
  }

  // Save post for offline reading
  Future<int> savePostForOffline(Post post) async {
    final db = await database;

    // Check if post already exists
    final existing = await db.query(
      tableOfflinePosts,
      where: 'id = ?',
      whereArgs: [post.id],
    );

    final tagsString = post.tags.map((tag) => tag.toString()).join(',');

    if (existing.isNotEmpty) {
      // Update existing post
      return await db.update(
        tableOfflinePosts,
        {
          'title': post.title,
          'content': post.content,
          'excerpt': post.excerpt,
          'imageUrl': post.imageUrl,
          'tags': tagsString,
          'categories': post.categories.join(','),
          'link': post.link,
          'savedAt': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [post.id],
      );
    } else {
      // Insert new post
      return await db.insert(tableOfflinePosts, {
        'id': post.id,
        'title': post.title,
        'content': post.content,
        'excerpt': post.excerpt,
        'imageUrl': post.imageUrl,
        'tags': tagsString,
        'categories': post.categories.join(','),
        'link': post.link,
        'savedAt': DateTime.now().toIso8601String(),
      });
    }
  }

  // Get all offline posts
  Future<List<Post>> getOfflinePosts() async {
    final db = await database;
    final maps = await db.query(tableOfflinePosts, orderBy: 'savedAt DESC');

    return List.generate(maps.length, (i) {
      final map = maps[i];
      final tagsString = map['tags'] as String?;
      final tags = tagsString?.split(',').map((tag) => int.tryParse(tag) ?? 0).toList() ?? [];

      return Post(
        id: map['id'] as int,
        title: map['title'] as String,
        content: map['content'] as String,
        excerpt: map['excerpt'] as String? ?? '',
        imageUrl: map['imageUrl'] as String?,
        tags: tags,
        link: map['link'] as String,
        categories: (map['categories'] as String?)?.split(',') ?? [],
      );
    });
  }

  // Check if post is saved offline
  Future<bool> isPostSavedOffline(int postId) async {
    final db = await database;
    final result = await db.query(
      tableOfflinePosts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Remove post from offline storage
  Future<int> removeOfflinePost(int postId) async {
    final db = await database;
    return await db.delete(
      tableOfflinePosts,
      where: 'id = ?',
      whereArgs: [postId],
    );
  }

  // Get offline post by ID
  Future<Post?> getOfflinePost(int postId) async {
    final db = await database;
    final maps = await db.query(
      tableOfflinePosts,
      where: 'id = ?',
      whereArgs: [postId],
      limit: 1,
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final tagsString = map['tags'] as String?;
    final tags = tagsString?.split(',').map((tag) => int.tryParse(tag) ?? 0).toList() ?? [];

    return Post(
      id: map['id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      excerpt: map['excerpt'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      tags: tags,
      link: map['link'] as String,
      categories: (map['categories'] as String?)?.split(',') ?? [],
    );
  }

  // Get storage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableOfflinePosts');
    final count = result.isNotEmpty ? (result.first['count'] as int?) ?? 0 : 0;

    // Estimate size (rough calculation)
    final posts = await getOfflinePosts();
    int totalSize = 0;
    for (final post in posts) {
      totalSize += post.title.length + post.content.length + (post.excerpt?.length ?? 0);
    }

    return {
      'postCount': count,
      'estimatedSizeKB': (totalSize / 1024).round(),
    };
  }

  // Clear all offline posts
  Future<int> clearAllOfflinePosts() async {
    final db = await database;
    return await db.delete(tableOfflinePosts);
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
