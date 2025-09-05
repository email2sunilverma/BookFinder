import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class SavedBooksState extends Equatable {
  const SavedBooksState();

  @override
  List<Object> get props => [];
}

class SavedBooksInitial extends SavedBooksState {
  const SavedBooksInitial();
}

class SavedBooksLoading extends SavedBooksState {
  const SavedBooksLoading();
}

class SavedBooksLoaded extends SavedBooksState {
  final List<Book> books;

  const SavedBooksLoaded({required this.books});

  @override
  List<Object> get props => [books];
}

class SavedBooksError extends SavedBooksState {
  final String message;

  const SavedBooksError({required this.message});

  @override
  List<Object> get props => [message];
}
