import 'package:bloc/bloc.dart';
import '../../../domain/usecases/get_saved_books_use_case.dart';
import '../../../domain/usecases/save_book_use_case.dart';
import '../../../domain/usecases/remove_book_use_case.dart';
import 'saved_books_event.dart';
import 'saved_books_state.dart';

class SavedBooksBloc extends Bloc<SavedBooksEvent, SavedBooksState> {
  final GetSavedBooksUseCase getSavedBooksUseCase;
  final SaveBookUseCase saveBookUseCase;
  final RemoveBookUseCase removeBookUseCase;

  SavedBooksBloc({
    required this.getSavedBooksUseCase,
    required this.saveBookUseCase,
    required this.removeBookUseCase,
  }) : super(const SavedBooksInitial()) {
    on<LoadSavedBooksEvent>(_onLoadSavedBooks);
    on<SaveBookEvent>(_onSaveBook);
    on<RemoveBookEvent>(_onRemoveBook);
  }

  Future<void> _onLoadSavedBooks(
    LoadSavedBooksEvent event,
    Emitter<SavedBooksState> emit,
  ) async {
    emit(const SavedBooksLoading());

    try {
      final books = await getSavedBooksUseCase.call();
      emit(SavedBooksLoaded(books: books));
    } catch (e) {
      emit(SavedBooksError(message: e.toString()));
    }
  }

  Future<void> _onSaveBook(
    SaveBookEvent event,
    Emitter<SavedBooksState> emit,
  ) async {
    try {
      // Optimistic update - add book immediately to UI
      final currentState = state;
      if (currentState is SavedBooksLoaded) {
        final updatedBooks = [event.book, ...currentState.books];
        emit(SavedBooksLoaded(books: updatedBooks));
      }
      
      // Save to database
      await saveBookUseCase.call(event.book);
    } catch (e) {
      // Revert on error
      add(const LoadSavedBooksEvent());
      emit(SavedBooksError(message: e.toString()));
    }
  }

  Future<void> _onRemoveBook(
    RemoveBookEvent event,
    Emitter<SavedBooksState> emit,
  ) async {
    try {
      // Optimistic update - remove book immediately from UI
      final currentState = state;
      if (currentState is SavedBooksLoaded) {
        final updatedBooks = currentState.books
            .where((book) => book.key != event.bookKey)
            .toList();
        emit(SavedBooksLoaded(books: updatedBooks));
      }
      
      // Remove from database
      await removeBookUseCase.call(event.bookKey);
    } catch (e) {
      // Revert on error
      add(const LoadSavedBooksEvent());
      emit(SavedBooksError(message: e.toString()));
    }
  }
}
