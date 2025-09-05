import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/saved_books/saved_books_bloc.dart';
import '../bloc/saved_books/saved_books_event.dart';
import '../bloc/saved_books/saved_books_state.dart';
import '../../domain/entities/book.dart';
import '../widgets/saved_book_card.dart';
import 'book_details_screen.dart';
import '../../../../home_screen.dart';

class SavedBooksScreen extends StatefulWidget {
  const SavedBooksScreen({super.key});

  @override
  State<SavedBooksScreen> createState() => _SavedBooksScreenState();
}

class _SavedBooksScreenState extends State<SavedBooksScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved books when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedBooksBloc>().add(const LoadSavedBooksEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Books'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Add explore/search button
          IconButton(
            icon: const Icon(Icons.explore),
            tooltip: 'Explore Books',
            onPressed: () {
              // Navigate to home screen with search tab selected
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialTabIndex: 0),
                ),
              );
            },
          ),
          BlocBuilder<SavedBooksBloc, SavedBooksState>(
            builder: (context, state) {
              if (state is SavedBooksLoaded && state.books.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<SavedBooksBloc>().add(const LoadSavedBooksEvent());
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<SavedBooksBloc, SavedBooksState>(
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  Widget _buildBody(SavedBooksState state) {
    if (state is SavedBooksLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is SavedBooksError) {
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
              onPressed: () => context
                  .read<SavedBooksBloc>()
                  .add(const LoadSavedBooksEvent()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is! SavedBooksLoaded) {
      return const Center(
        child: Text('No saved books'),
      );
    }

    if (state.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Icon(
                Icons.bookmark_border,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Saved Books',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Books you save will appear here.\nStart exploring to build your library!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to home screen with search tab selected
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(initialTabIndex: 0),
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text('Start Exploring'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Enhanced header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withValues(alpha: 0.1), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${state.books.length} Saved Book${state.books.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your personal library',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.60, // Slightly reduced to give more height and prevent overflow
              ),
              itemCount: state.books.length,
              itemBuilder: (context, index) {
                final book = state.books[index];
                return SavedBookCard(
                  book: book,
                  onTap: () => _navigateToBookDetails(book),
                  onRemove: () => _removeFromSaved(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  void _removeFromSaved(Book book) {
    context.read<SavedBooksBloc>().add(RemoveBookEvent(bookKey: book.key));
    
    // Show snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${book.title} removed from saved books'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            context.read<SavedBooksBloc>().add(SaveBookEvent(book: book));
          },
        ),
      ),
    );
  }
}
