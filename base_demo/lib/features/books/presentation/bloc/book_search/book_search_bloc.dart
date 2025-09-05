import 'package:bloc/bloc.dart';
import '../../../domain/usecases/search_books_use_case.dart';
import '../../../domain/entities/book.dart';
import 'book_search_event.dart';
import 'book_search_state.dart';

class BookSearchBloc extends Bloc<BookSearchEvent, BookSearchState> {
  final SearchBooksUseCase searchBooksUseCase;

  BookSearchBloc({required this.searchBooksUseCase}) : super(const BookSearchInitial()) {
    on<SearchBooksEvent>(_onSearchBooks);
    on<LoadMoreBooksEvent>(_onLoadMoreBooks);
    on<ClearSearchEvent>(_onClearSearch);
    on<UpdateBookSaveStatusEvent>(_onUpdateBookSaveStatus);
  }

  Future<void> _onSearchBooks(
    SearchBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    if (event.query.trim().isEmpty) return;

    final currentState = state;
    final isRefresh = event.isRefresh || 
        (currentState is! BookSearchLoaded && currentState is! BookSearchLoadingMore) ||
        (currentState is BookSearchLoaded && currentState.currentQuery != event.query);

    if (isRefresh) {
      emit(const BookSearchLoading());
    } else if (currentState is BookSearchLoaded) {
      emit(BookSearchLoadingMore(
        books: currentState.books,
        currentPage: currentState.currentPage,
        currentQuery: currentState.currentQuery,
      ));
    }

    try {
      final page = isRefresh ? 1 : (currentState is BookSearchLoaded ? currentState.currentPage + 1 : 1);
      
      final result = await searchBooksUseCase.call(
        query: event.query.trim(),
        page: page,
      );

      if (result.books.isEmpty && page == 1) {
        emit(BookSearchEmpty(query: event.query.trim()));
        return;
      }

      final books = isRefresh 
          ? result.books 
          : (currentState is BookSearchLoaded ? [...currentState.books, ...result.books] : result.books);

      emit(BookSearchLoaded(
        books: books,
        hasMore: result.hasMore,
        currentPage: page,
        currentQuery: event.query.trim(),
      ));
    } catch (e) {
      final books = currentState is BookSearchLoaded ? currentState.books : <Book>[];
      final page = currentState is BookSearchLoaded ? currentState.currentPage : 0;
      final query = currentState is BookSearchLoaded ? currentState.currentQuery : event.query.trim();
      
      emit(BookSearchError(
        message: e.toString(),
        books: books,
        currentPage: page,
        currentQuery: query,
      ));
    }
  }

  Future<void> _onLoadMoreBooks(
    LoadMoreBooksEvent event,
    Emitter<BookSearchState> emit,
  ) async {
    final currentState = state;
    if (currentState is BookSearchLoaded && currentState.hasMore) {
      add(SearchBooksEvent(query: currentState.currentQuery));
    }
  }

  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<BookSearchState> emit,
  ) {
    emit(const BookSearchCleared());
  }

  void _onUpdateBookSaveStatus(
    UpdateBookSaveStatusEvent event,
    Emitter<BookSearchState> emit,
  ) {
    final currentState = state;
    if (currentState is BookSearchLoaded) {
      final updatedBooks = currentState.books.map((book) {
        if (book.key == event.bookKey) {
          return book.copyWith(isSaved: event.isSaved);
        }
        return book;
      }).toList();

      // Add timestamp to ensure the state is recognized as different
      emit(BookSearchLoaded(
        books: updatedBooks,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
        currentQuery: currentState.currentQuery,
        lastUpdated: DateTime.now(),
      ));
    }
  }
}
