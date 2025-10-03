import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/src/style/fontsize.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:logging/logging.dart';
import '../providers/bookmark_provider.dart';
import '../providers/font_size_provider.dart';
import '../models/post.dart';
import 'package:url_launcher/url_launcher.dart';
import 'webview_screen.dart';
import 'author_screen.dart';
import '../services/api_service.dart'; // Import ApiService
import '../services/database_helper.dart';
import '../utils/html_utils.dart';
import '../widgets/comments_section.dart';

class DetailArtikelScreen extends StatefulWidget {
  final Post post;

  const DetailArtikelScreen({super.key, required this.post});

  @override
  State<DetailArtikelScreen> createState() => _DetailArtikelScreenState();
}

class _DetailArtikelScreenState extends State<DetailArtikelScreen> {
  final Logger _logger = Logger('DetailArtikelScreen');
  final ScrollController _scrollController = ScrollController();
  bool _isSavedOffline = false;
  bool _isSavingOffline = false;

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
  void initState() {
    super.initState();
    _checkOfflineStatus();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }



  Future<void> _checkOfflineStatus() async {
    try {
      final isSaved = await DatabaseHelper.instance.isPostSavedOffline(widget.post.id);
      if (mounted) {
        setState(() {
          _isSavedOffline = isSaved;
        });
      }
    } catch (e) {
      _logger.warning('Failed to check offline status: $e');
    }
  }

  Future<void> _toggleOfflineSave() async {
    if (_isSavingOffline) return;

    setState(() {
      _isSavingOffline = true;
    });

    try {
      if (_isSavedOffline) {
        // Remove from offline storage
        await DatabaseHelper.instance.removeOfflinePost(widget.post.id);
        if (mounted) {
          setState(() {
            _isSavedOffline = false;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel dihapus dari penyimpanan offline')),
        );
      } else {
        // Save for offline reading
        await DatabaseHelper.instance.savePostForOffline(widget.post);
        if (mounted) {
          setState(() {
            _isSavedOffline = true;
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Artikel disimpan untuk dibaca offline')),
        );
      }
    } catch (e) {
      _logger.severe('Failed to toggle offline save: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan artikel: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingOffline = false;
        });
      }
    }
  }

  void _showShareDialog() {
    final articleTitle = unescape.convert(widget.post.title);
    final articleUrl = widget.post.link;
    final shareText = 'Baca tulisan menarik "$articleTitle" di BacaPetra\n\n$articleUrl';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Bagikan Artikel',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Icon(
                Icons.share,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Bagikan'),
              subtitle: const Text('Kirim ke aplikasi lain'),
              onTap: () {
                Navigator.pop(context);
                Share.share(shareText, subject: articleTitle);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.copy,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Salin Link'),
              subtitle: const Text('Salin link ke clipboard'),
              onTap: () async {
                await Clipboard.setData(ClipboardData(text: articleUrl));
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link berhasil disalin ke clipboard')),
                  );
                }
              },
            ),
            ListTile(
              leading: Icon(
                Icons.message,
                color: Colors.green,
              ),
              title: const Text('WhatsApp'),
              subtitle: const Text('Bagikan via WhatsApp'),
              onTap: () async {
                Navigator.pop(context);
                final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(shareText)}';
                if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
                  await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('WhatsApp tidak terinstall')),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(unescape.convert(widget.post.title)),
        actions: [
          Consumer<BookmarkProvider>(
            builder: (context, bookmarkProvider, child) {
              final isBookmarked = bookmarkProvider.isBookmarked(widget.post.id);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber.shade700 : null,
                ),
                onPressed: () {
                  bookmarkProvider.toggleBookmark(widget.post.id);
                },
              );
            },
          ),
          IconButton(
            icon: _isSavingOffline
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isSavedOffline ? Icons.offline_pin : Icons.download,
                    color: _isSavedOffline ? Colors.green.shade600 : null,
                  ),
            onPressed: _toggleOfflineSave,
            tooltip: _isSavedOffline ? 'Hapus dari offline' : 'Simpan untuk offline',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareDialog,
            tooltip: 'Bagikan artikel',
          ),
          Consumer<FontSizeProvider>(
            builder: (context, fontSizeProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'increase') {
                    fontSizeProvider.increaseFontSize();
                  } else if (value == 'decrease') {
                    fontSizeProvider.decreaseFontSize();
                  } else if (value == 'reset') {
                    fontSizeProvider.resetFontSize();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'increase', child: Text('Perbesar Font')),
                  const PopupMenuItem(value: 'decrease', child: Text('Perkecil Font')),
                  const PopupMenuItem(value: 'reset', child: Text('Reset Font')),
                ],
                icon: const Icon(Icons.format_size),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.post.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Hero(
                          tag: 'post-image-${widget.post.id}',
                          child: Image.network(
                            widget.post.imageUrl!,
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
                    unescape.convert(widget.post.title),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        calculateReadingTime(widget.post.content),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Consumer<FontSizeProvider>(
                    builder: (context, fontSizeProvider, child) {
                      return Html(
                        data: unescape.convert(widget.post.content),
                        style: {
                          "body": Style(
                            fontSize: FontSize(18.0 * fontSizeProvider.fontSizeScale),
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
                        // Performance optimization
                        shrinkWrap: true,
                      );
                    },
                  ),
                ],
              ),
            ),

            // Comments Section
            CommentsSection(post: widget.post),

            // Share Section at the end of article
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.share,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Menikmati artikel ini?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bagikan dengan teman-teman Anda agar mereka juga bisa menikmati tulisan menarik ini.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _showShareDialog,
                          icon: const Icon(Icons.share),
                          label: const Text('Bagikan'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: widget.post.link));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link berhasil disalin ke clipboard')),
                              );
                            }
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Salin Link'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
