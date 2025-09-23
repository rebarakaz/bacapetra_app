import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:logging/logging.dart';
import '../providers/bookmark_provider.dart';
import '../models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webview_screen.dart';
import 'author_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../utils/html_utils.dart';
import '../widgets/comments_section.dart';

class DetailArtikelScreen extends StatelessWidget {
  final Post post;
  final Logger _logger = Logger('DetailArtikelScreen');

  DetailArtikelScreen({super.key, required this.post});

  // _fetchPostBySlug() and _fetchTagBySlug() functions have been moved to ApiService

  // Handles all link taps within the article content
  void _handleLinkTap(BuildContext context, String? url) async {
    if (url == null) return;

    final uri = Uri.parse(url);

    // Check if it's an internal bacapetra.co link
    if (uri.host.endsWith('bacapetra.co')) {
      // Show a loading indicator immediately
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Check if it's a TAG/AUTHOR link
      if (uri.pathSegments.contains('tag')) {
        final slug = uri.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
        if (slug.isNotEmpty) {
          final tag = await ApiService.fetchTagBySlug(slug); // Call from ApiService
          if (context.mounted) {
            Navigator.pop(context); // Dismiss loading dialog
            if (tag != null && tag['id'] is int && tag['name'] is String) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthorScreen(
                    tagId: tag['id'],
                    authorName: unescape.convert(tag['name']),
                  ),
                ),
              );
              return; // Stop further processing
            }
          }
        }
      } else { // If not a tag, assume it's an article link (e.g., "Baca Juga" links)
        final slug = uri.pathSegments.lastWhere((s) => s.isNotEmpty, orElse: () => '');
        if (slug.isNotEmpty) {
          final newPost = await ApiService.fetchPostBySlug(slug); // Call from ApiService
          if (context.mounted) {
            Navigator.pop(context); // Dismiss loading dialog
            if (newPost != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailArtikelScreen(post: newPost),
                ),
              );
              return; // Stop further processing
            }
          }
        }
      }

      // Fallback for other internal links or if fetching failed
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        // If we couldn't handle it as a post or tag, open in WebView as a fallback.
        _openInWebView(context, url);
      }

    } else {
      // It's an external link
      _openInWebView(context, url);
    }
  }

  // Opens a URL in the in-app WebView
  void _openInWebView(BuildContext context, String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebviewScreen(url: url, title: 'BacaPetra'),
          ),
        );
      }
    } else {
      _logger.warning('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unescape.convert(post.title)),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final isBookmarked = bookmarkProvider.isBookmarked(post.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber.shade700 : null,
                ),
                onPressed: () {
                  bookmarkProvider.toggleBookmark(post.id);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'Baca tulisan menarik "${unescape.convert(post.title)}" di ${post.link}',
                subject: unescape.convert(post.title),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Hero(
                          tag: 'post-image-${post.id}',
                          child: Image.network(
                            post.imageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 50);
                            },
                          ),
                        ),
                      ),
                    ),
                  Text(
                    unescape.convert(post.title),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Html(
                    data: unescape.convert(post.content),
                    style: {
                      "body": Style(
                        fontSize: FontSize.large,
                        lineHeight: LineHeight.number(1.5),
                      ),
                      "p": Style(
                        margin: Margins.only(bottom: 16.0),
                      ),
                      "hr": Style(
                        margin: Margins.symmetric(vertical: 24.0),
                        border: const Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                      ),
                      "a": Style(
                        color: Colors.blue.shade800,
                        textDecoration: TextDecoration.none,
                        fontWeight: FontWeight.w500,
                      ),
                    },
                    onLinkTap: (String? url, Map<String, String> attributes, element) {
                      _handleLinkTap(context, url);
                    },
                  ),
                ],
              ),
            ),

            // Comments Section
            CommentsSection(post: post),
          ],
        ),
      ),
    );
  }
}
