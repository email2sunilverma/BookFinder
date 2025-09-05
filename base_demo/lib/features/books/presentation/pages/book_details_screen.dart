import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_details/book_details_bloc.dart';
import '../bloc/book_details/book_details_event.dart';
import '../bloc/book_details/book_details_state.dart';
import '../bloc/saved_books/saved_books_bloc.dart';
import '../bloc/saved_books/saved_books_event.dart';
import '../widgets/animated_book_cover.dart';
import '../../domain/entities/book.dart';

class BookDetailsScreen extends StatefulWidget {
  final Book book;

  const BookDetailsScreen({
    super.key,
    required this.book,
  });

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Set the book data directly without API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BookDetailsBloc>().add(SetBookDetailsEvent(book: widget.book));
      }
    });
  }

  @override
  void dispose() {
    // Note: No need to clear book details here as the BLoC will be disposed
    // when the screen is popped from the navigation stack
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<BookDetailsBloc, BookDetailsState>(
            builder: (context, state) {
              if (state is BookDetailsLoaded) {
                return IconButton(
                  onPressed: state.isSaving 
                      ? null 
                      : () => _toggleBookSaved(),
                  icon: state.isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(
                          state.book.isSaved 
                              ? Icons.bookmark 
                              : Icons.bookmark_border,
                          color: Colors.white,
                          size: 24,
                        ),
                  tooltip: state.book.isSaved 
                      ? 'Remove from saved books' 
                      : 'Save this book',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<BookDetailsBloc, BookDetailsState>(
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(BookDetailsState state) {
    if (state is BookDetailsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is BookDetailsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: ${state.message}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (!mounted) return;
                context
                    .read<BookDetailsBloc>()
                    .add(SetBookDetailsEvent(book: widget.book));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is! BookDetailsLoaded) {
      return const Center(
        child: Text('Book not found'),
      );
    }

    final book = state.book;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Animated Book Cover
          Center(
            child: AnimatedBookCover(
              imageUrl: book.coverUrl,
              width: 200,
              height: 300,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Book Title
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Authors
          Text(
            book.authors.isNotEmpty && book.authors.first != 'Unknown Author'
                ? 'by ${book.authors.join(', ')}'
                : 'Author information not available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontStyle: book.authors.isEmpty || book.authors.first == 'Unknown Author' 
                  ? FontStyle.italic 
                  : FontStyle.normal,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Publication Year
          if (book.publishYear != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Published: ${book.publishYear}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isSaving ? null : _toggleBookSaved,
              icon: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      book.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    ),
              label: Text(
                book.isSaved ? 'Remove from Saved' : 'Save Book',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: book.isSaved ? Colors.red : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Book Key (for debugging/reference)
          if (widget.book.key.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Book ID:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.book.key,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _toggleBookSaved() {
    if (!mounted) return;
    context.read<BookDetailsBloc>().add(const ToggleBookSavedEvent());
    // Also refresh saved books list
    context.read<SavedBooksBloc>().add(const LoadSavedBooksEvent());
  }
}
