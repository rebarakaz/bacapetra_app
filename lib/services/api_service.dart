// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart'; // Import logging package

import '../models/post.dart';
import '../models/category.dart';
import '../models/author.dart';
import '../models/comment.dart';
import '../utils/constants.dart';
final Logger _logger = Logger('ApiService'); // Create a logger instance

class ApiService {
  static const String _baseUrl = 'https://www.bacapetra.co/wp-json/wp/v2';

  static Future<List<Post>> fetchPosts({int page = 1, int perPage = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?_embed&page=$page&per_page=$perPage');
      _logger.info('Fetching posts from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Successfully fetched ${jsonResponse.length} posts');
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        _logger.severe('Failed to load posts. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load posts. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching posts: $e', e, stackTrace);
      throw Exception('Failed to load posts: $e');
    }
  }

  static Future<List<Post>> fetchPostsByCategory(int categoryId, {int page = 1, int perPage = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?categories=$categoryId&_embed&page=$page&per_page=$perPage');
      _logger.info('Fetching posts by category from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Successfully fetched ${jsonResponse.length} posts for category $categoryId');
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        _logger.severe('Failed to load posts for category. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load posts for category. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching posts by category: $e', e, stackTrace);
      throw Exception('Failed to load posts for category: $e');
    }
  }

  static Future<List<Post>> fetchSearchResults(String query, {int page = 1, int perPage = 10}) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?search=$query&_embed&page=$page&per_page=$perPage');
      _logger.info('Fetching search results from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Successfully fetched ${jsonResponse.length} search results');
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        _logger.severe('Failed to load search results. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load search results. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching search results: $e', e, stackTrace);
      throw Exception('Failed to load search results: $e');
    }
  }

  static Future<Post> fetchPageContent(int pageId) async {
    try {
      final uri = Uri.parse('$_baseUrl/pages/$pageId');
      _logger.info('Fetching page content from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        _logger.info('Successfully fetched page content for page $pageId');
        return Post.fromJson(json.decode(response.body));
      } else {
        _logger.severe('Failed to load page content. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load page content. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching page content: $e', e, stackTrace);
      throw Exception('Failed to load page content: $e');
    }
  }

  static Future<Post?> fetchPostBySlug(String slug) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?slug=$slug&_embed');
      _logger.info('Fetching post by slug from: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          _logger.info('Successfully fetched post by slug: $slug');
          return Post.fromJson(jsonResponse.first);
        } else {
          _logger.info('No post found for slug: $slug');
          return null;
        }
      } else {
        _logger.severe('Failed to fetch post by slug. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching post by slug: $e', e, stackTrace);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchTagBySlug(String slug) async {
    try {
      final uri = Uri.parse('$_baseUrl/tags?slug=$slug');
      _logger.info('Fetching tag by slug from: $uri');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final List jsonResponse = json.decode(response.body);
        if (jsonResponse.isNotEmpty) {
          _logger.info('Successfully fetched tag by slug: $slug');
          return jsonResponse.first as Map<String, dynamic>;
        } else {
          _logger.info('No tag found for slug: $slug');
          return null;
        }
      } else {
        _logger.severe('Failed to fetch tag by slug. Status: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching tag by slug: $e', e, stackTrace);
    }
    return null;
  }

  static Future<List<Category>> fetchCategories() async {
    try {
      final uri = Uri.parse('$_baseUrl/categories?per_page=100');
      _logger.info('Fetching categories from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        final categories = jsonResponse
            .map((category) => Category.fromJson(category))
            .where((category) => category.id != 1 && category.count > 0)
            .toList();
        _logger.info('Successfully fetched ${categories.length} categories');
        return categories;
      } else {
        _logger.severe('Failed to load categories. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load categories. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching categories: $e', e, stackTrace);
      throw Exception('Failed to load categories: $e');
    }
  }

  static Future<List<Post>> fetchBookmarkedPosts(List<String> ids) async {
    if (ids.isEmpty) {
      return [];
    }
    try {
      final includeQuery = ids.map((id) => 'include[]=$id').join('&');
      final url = '$_baseUrl/posts?$includeQuery&_embed';
      final uri = Uri.parse(url);
      
      _logger.info('Fetching bookmarked posts from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Successfully fetched ${jsonResponse.length} bookmarked posts');
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        _logger.severe('Failed to load bookmarked posts. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load bookmarked posts. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching bookmarked posts: $e', e, stackTrace);
      throw Exception('Failed to load bookmarked posts: $e');
    }
  }

  static Future<List<Post>> fetchPostsByAuthorTag(int tagId) async {
    try {
      final uri = Uri.parse('$_baseUrl/posts?_embed&tags=$tagId&per_page=50');
      _logger.info('Fetching posts by author tag from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Successfully fetched ${jsonResponse.length} posts for author tag $tagId');
        return jsonResponse.map((post) => Post.fromJson(post)).toList();
      } else {
        _logger.severe('Failed to load author posts. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load author posts. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching posts by author tag: $e', e, stackTrace);
      throw Exception('Failed to load author posts: $e');
    }
  }

  static Future<Author?> fetchAuthorByTagId(int tagId) async {
    try {
      final uri = Uri.parse('$_baseUrl/tags/$tagId');
      _logger.info('Fetching author by tag ID from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        _logger.info('Successfully fetched author for tag ID $tagId');
        return Author.fromJson(json.decode(response.body));
      } else {
        _logger.severe('Failed to load author. Status: ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching author by tag ID: $e', e, stackTrace);
      return null;
    }
  }

  static Future<List<Comment>> fetchComments(int postId) async {
    try {
      final uri = Uri.parse('$_baseUrl/comments?post=$postId&per_page=50');
      _logger.info('Fetching comments for post $postId from: $uri');
      final response = await http.get(uri);

      _logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        final comments = jsonResponse.map((comment) => Comment.fromJson(comment)).toList();

        // Organize comments into threads (parent-child relationships)
        final topLevelComments = <Comment>[];
        final commentMap = <int, Comment>{};

        // First pass: create all comments
        for (final comment in comments) {
          commentMap[comment.id] = comment;
        }

        // Second pass: organize into hierarchy
        for (final comment in comments) {
          if (comment.parent == 0) {
            // Top-level comment
            topLevelComments.add(comment);
          } else {
            // Reply - add to parent's replies
            final parent = commentMap[comment.parent];
            if (parent != null) {
              final updatedParent = parent.copyWith(
                replies: [...parent.replies, comment],
              );
              commentMap[comment.parent] = updatedParent;
            }
          }
        }

        _logger.info('Successfully fetched ${topLevelComments.length} top-level comments for post $postId');
        return topLevelComments;
      } else {
        _logger.severe('Failed to load comments. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to load comments. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching comments: $e', e, stackTrace);
      throw Exception('Failed to load comments: $e');
    }
  }

  static Future<Comment> postComment({
    required int postId,
    required String authorName,
    required String authorEmail,
    required String content,
    int parent = 0,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/comments');
      _logger.info('Posting comment to post $postId');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post': postId,
          'author_name': authorName,
          'author_email': authorEmail,
          'content': content,
          'parent': parent,
        }),
      );

      _logger.info('Response status: ${response.statusCode}');

      if (response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        _logger.info('Successfully posted comment');
        return Comment.fromJson(jsonResponse);
      } else {
        _logger.severe('Failed to post comment. Status: ${response.statusCode}, Body: ${response.body}');
        throw Exception('Failed to post comment. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _logger.severe('Exception while posting comment: $e', e, stackTrace);
      throw Exception('Failed to post comment: $e');
    }
  }

  static Future<List<Post>> fetchDiversePosts({int postsPerCategory = 2}) async {
    try {
      _logger.info('Fetching diverse posts from multiple categories');

      // First, get all categories
      final categories = await fetchCategories();

      // Filter out categories with no posts and take top categories by post count
      final activeCategories = categories
          .where((category) => category.count > 0)
          .take(4) // Reduced from 6 to 4 for better performance
          .toList();

      // Prepare all API calls to run in parallel
      final List<Future<List<Post>>> apiCalls = [];

      // Add recent posts call
      apiCalls.add(fetchPosts(perPage: 4));

      // Add category posts calls
      for (final category in activeCategories) {
        apiCalls.add(fetchPostsByCategory(category.id, perPage: postsPerCategory));
      }

      // Execute all API calls in parallel
      _logger.info('Making ${apiCalls.length} parallel API calls');
      final results = await Future.wait(apiCalls, eagerError: false);

      final List<Post> allPosts = [];

      // Process results
      for (int i = 0; i < results.length; i++) {
        try {
          if (i == 0) {
            // First result is recent posts
            allPosts.addAll(results[i]);
            _logger.info('Added ${results[i].length} recent posts');
          } else {
            // Other results are category posts
            final categoryPosts = results[i];
            final categoryName = activeCategories[i - 1].name;

            // Add category posts that aren't already in the list
            int addedCount = 0;
            for (final post in categoryPosts) {
              if (!allPosts.any((existingPost) => existingPost.id == post.id)) {
                allPosts.add(post);
                addedCount++;
              }
            }
            _logger.info('Added $addedCount posts from category: $categoryName');
          }
        } catch (e) {
          _logger.warning('Failed to process result ${i}: $e');
          // Continue with other results
        }
      }

      // Remove duplicates and sort by date (newest first)
      final uniquePosts = <Post>[];
      final seenIds = <int>{};

      for (final post in allPosts) {
        if (!seenIds.contains(post.id)) {
          seenIds.add(post.id);
          uniquePosts.add(post);
        }
      }

      // Sort by date (newest first)
      uniquePosts.sort((a, b) => b.id.compareTo(a.id)); // Assuming higher ID = newer post

      _logger.info('Successfully fetched ${uniquePosts.length} diverse posts from ${activeCategories.length} categories');
      return uniquePosts;

    } catch (e, stackTrace) {
      _logger.severe('Exception while fetching diverse posts: $e', e, stackTrace);
      // Fallback to regular posts if diverse fetching fails
      return fetchPosts();
    }
  }
}
