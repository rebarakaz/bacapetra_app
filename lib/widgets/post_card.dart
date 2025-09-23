import 'package:flutter/material.dart';
import '../models/post.dart';
import '../utils/html_utils.dart';
import '../utils/constants.dart';
import '../screens/detail_artikel_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final bool showCategories;

  const PostCard({
    super.key,
    required this.post,
    this.showCategories = true,
  });

  @override
  Widget build(BuildContext context) {
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
        margin: const EdgeInsets.symmetric(
          vertical: AppConstants.cardMargin,
          horizontal: 8.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        elevation: AppConstants.cardElevation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.imageUrl != null)
              Hero(
                tag: 'post-image-${post.id}',
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  height: AppConstants.postImageHeight,
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
                      height: AppConstants.postImageHeight,
                      child: Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCategories && post.categories.isNotEmpty)
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
                  if (showCategories && post.categories.isNotEmpty)
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
                    maxLines: AppConstants.excerptMaxLines,
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
  }
}
