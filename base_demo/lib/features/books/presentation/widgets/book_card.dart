import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onSave;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 80,
                  child: book.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: book.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.book,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.book,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.book,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Book Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    if (book.authors.isNotEmpty)
                      Text(
                        'by ${book.authors.join(', ')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 4),
                    
                    if (book.publishYear != null)
                      Text(
                        'Published: ${book.publishYear}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Save Button
              if (onSave != null)
                IconButton(
                  onPressed: onSave,
                  icon: Icon(
                    book.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: book.isSaved ? Colors.blue : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
