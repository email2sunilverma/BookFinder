import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/book_search/book_search_bloc.dart';
import '../bloc/book_search/book_search_event.dart';
import '../bloc/book_search/book_search_state.dart';
import '../bloc/saved_books/saved_books_bloc.dart';
import '../bloc/saved_books/saved_books_event.dart';
import '../../domain/entities/book.dart';
import '../widgets/search_bar_widget.dart' as custom;
import '../widgets/book_card.dart';
import '../widgets/book_shimmer.dart';
import 'book_details_screen.dart';

class BookSearchScreen extends StatefulWidget {
  const BookSearchScreen({super.key});

  @override
  State<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends State<BookSearchScreen> {
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Start with cleared state instead of loading default books
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = context.read<BookSearchBloc>().state;
      
      // If we're in initial state, emit cleared state for a clean start
      if (currentState is BookSearchInitial) {
        context.read<BookSearchBloc>().add(const ClearSearchEvent());
      } else if (currentState is BookSearchLoaded) {
        // If we already have data, just update the current query to match the loaded state
        _currentQuery = currentState.currentQuery;
      } else if (currentState is BookSearchLoadingMore) {
        // If we're loading more, use the current query from that state
        _currentQuery = currentState.currentQuery;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<BookSearchBloc>().add(const LoadMoreBooksEvent());
    }
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty && query != _currentQuery) {
      _currentQuery = query;
      context.read<BookSearchBloc>().add(SearchBooksEvent(query: query, isRefresh: true));
    }
  }

  void _onRefresh() {
    if (_currentQuery.isNotEmpty) {
      context.read<BookSearchBloc>().add(SearchBooksEvent(query: _currentQuery, isRefresh: true));
    }
  }

  void _onClear() {
    _currentQuery = '';
    context.read<BookSearchBloc>().add(const ClearSearchEvent());
  }

  void _onBookTap(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book: book),
      ),
    );
  }

  void _onBookSave(Book book) async {
    if (book.isSaved) {
      // Remove from saved
      context.read<SavedBooksBloc>().add(RemoveBookEvent(bookKey: book.key));
      
      // Update the book's save status in the search results
      context.read<BookSearchBloc>().add(UpdateBookSaveStatusEvent(
        bookKey: book.key,
        isSaved: false,
      ));
    } else {
      // Save the book
      context.read<SavedBooksBloc>().add(SaveBookEvent(book: book));
      
      // Update the book's save status in the search results
      context.read<BookSearchBloc>().add(UpdateBookSaveStatusEvent(
        bookKey: book.key,
        isSaved: true,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Finder'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          custom.SearchBar(
            hint: 'Search for books by title...',
            onChanged: (value) {
              // Debounce search - you might want to add a timer here
            },
            onSubmitted: _onSearch,
            onClear: _onClear,
          ),

          // Results
          Expanded(
            child: BlocBuilder<BookSearchBloc, BookSearchState>(
              builder: (context, state) {
                return _buildSearchResults(state);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BookSearchState state) {
    if (state is BookSearchLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading popular books...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state is BookSearchInitial) {
      return const BookListShimmer();
    }

    if (state is BookSearchCleared) {
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
                Icons.search,
                size: 64,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Search for Books',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a book title, author, or topic\nto discover amazing books!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is BookSearchError && state.books.isEmpty) {
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
              onPressed: _onRefresh,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is BookSearchEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No books found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Handle loaded states
    final books = state is BookSearchLoaded ? state.books : 
                  state is BookSearchLoadingMore ? state.books :
                  state is BookSearchError ? state.books : <Book>[];
    
    final hasMore = state is BookSearchLoaded ? state.hasMore : false;
    final isLoadingMore = state is BookSearchLoadingMore;

    return RefreshIndicator(
      onRefresh: () async => _onRefresh(),
      child: Column(
        children: [
          // Book list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              itemCount: books.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= books.length) {
                  return isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }

                final book = books[index];
                return BookCard(
                  book: book,
                  onTap: () => _onBookTap(book),
                  onSave: () => _onBookSave(book),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
