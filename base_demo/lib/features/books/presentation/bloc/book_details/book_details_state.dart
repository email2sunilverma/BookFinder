import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class BookDetailsState extends Equatable {
  const BookDetailsState();

  @override
  List<Object?> get props => [];
}

class BookDetailsInitial extends BookDetailsState {
  const BookDetailsInitial();
}

class BookDetailsLoading extends BookDetailsState {
  const BookDetailsLoading();
}

class BookDetailsLoaded extends BookDetailsState {
  final Book book;
  final bool isSaving;

  const BookDetailsLoaded({
    required this.book,
    this.isSaving = false,
  });

  @override
  List<Object?> get props => [book, isSaving];

  BookDetailsLoaded copyWith({
    Book? book,
    bool? isSaving,
  }) {
    return BookDetailsLoaded(
      book: book ?? this.book,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class BookDetailsError extends BookDetailsState {
  final String message;

  const BookDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookDetailsSaving extends BookDetailsState {
  final Book book;

  const BookDetailsSaving({required this.book});

  @override
  List<Object?> get props => [book];
}

class BookDetailsSaved extends BookDetailsState {
  final Book book;

  const BookDetailsSaved({required this.book});

  @override
  List<Object?> get props => [book];
}
