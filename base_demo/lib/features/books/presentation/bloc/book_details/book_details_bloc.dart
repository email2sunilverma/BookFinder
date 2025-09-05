import 'package:bloc/bloc.dart';
import '../../../domain/usecases/get_book_details_use_case.dart';
import '../../../domain/usecases/save_book_use_case.dart';
import 'book_details_event.dart';
import 'book_details_state.dart';

class BookDetailsBloc extends Bloc<BookDetailsEvent, BookDetailsState> {
  final GetBookDetailsUseCase getBookDetailsUseCase;
  final SaveBookUseCase saveBookUseCase;

  BookDetailsBloc({
    required this.getBookDetailsUseCase,
    required this.saveBookUseCase,
  }) : super(const BookDetailsInitial()) {
    on<LoadBookDetailsEvent>(_onLoadBookDetails);
    on<SetBookDetailsEvent>(_onSetBookDetails);
    on<ToggleBookSavedEvent>(_onToggleBookSaved);
    on<ClearBookDetailsEvent>(_onClearBookDetails);
  }

  Future<void> _onLoadBookDetails(
    LoadBookDetailsEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    emit(const BookDetailsLoading());

    try {
      final book = await getBookDetailsUseCase.call(event.bookKey);
      
      if (book != null) {
        emit(BookDetailsLoaded(book: book));
      } else {
        emit(const BookDetailsError(message: 'Book not found'));
      }
    } catch (e) {
      emit(BookDetailsError(message: e.toString()));
    }
  }

  void _onSetBookDetails(
    SetBookDetailsEvent event,
    Emitter<BookDetailsState> emit,
  ) {
    emit(BookDetailsLoaded(book: event.book));
  }

  Future<void> _onToggleBookSaved(
    ToggleBookSavedEvent event,
    Emitter<BookDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookDetailsLoaded) return;

    emit(currentState.copyWith(isSaving: true));

    try {
      final currentBook = currentState.book;
      
      if (currentBook.isSaved) {
        // Remove book logic would go here
        // For now, we'll just update the local state
        final updatedBook = currentBook.copyWith(isSaved: false);
        emit(BookDetailsLoaded(book: updatedBook, isSaving: false));
      } else {
        await saveBookUseCase.call(currentBook);
        final updatedBook = currentBook.copyWith(isSaved: true);
        emit(BookDetailsLoaded(book: updatedBook, isSaving: false));
      }
    } catch (e) {
      emit(currentState.copyWith(isSaving: false));
      emit(BookDetailsError(message: e.toString()));
    }
  }

  void _onClearBookDetails(
    ClearBookDetailsEvent event,
    Emitter<BookDetailsState> emit,
  ) {
    emit(const BookDetailsInitial());
  }
}
