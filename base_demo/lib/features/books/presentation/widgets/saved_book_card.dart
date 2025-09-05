import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/book.dart';

class SavedBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const SavedBookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero, // Remove default margin to fill available space
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Cover (expanded to use more space)
            Expanded(
              flex: 6, // Increased to 6 for more cover space
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[100],
                ),
                child: Stack(
                  children: [
                    // Full width cover image
                    Positioned.fill(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0), // More padding on top, left, right
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: book.coverUrl != null
                              ? CachedNetworkImage(
                                  imageUrl: book.coverUrl!,
                                  fit: BoxFit.cover, // This will fill the entire space
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey[300]!),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.grey,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.book,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    
                    // Remove button overlay - refined design
                    if (onRemove != null)
                      Positioned(
                        top: 10, // Adjusted for increased top padding
                        right: 10, // Adjusted for increased right padding
                        child: GestureDetector(
                          onTap: onRemove,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Book Details (compact and top-aligned)
            Expanded(
              flex: 2, // Increased from 1 to 2 to prevent overflow
              child: Container(
                padding: const EdgeInsets.fromLTRB(12.0, 4.0, 12.0, 4.0), // Minimal padding to prevent overflow
                width: double.infinity, // Ensure it fills the width
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start, // Top align with image bottom
                  mainAxisSize: MainAxisSize.min, // Take minimum space needed
                  children: [
                    // Title - single line for compact layout
                    Flexible(
                      child: Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          height: 1.3, // Slightly increased line height for better readability
                        ),
                        maxLines: 1, // Single line for title
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Minimal spacing between title and author
                    const SizedBox(height: 2), // Very small spacing
                    
                    // Author (only show if valid author exists)
                    if (book.authors.isNotEmpty && 
                        book.authors.first.isNotEmpty && 
                        book.authors.first != 'Unknown Author' &&
                        book.authors.first.toLowerCase() != 'null')
                      Flexible(
                        child: Text(
                          book.authors.first,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
