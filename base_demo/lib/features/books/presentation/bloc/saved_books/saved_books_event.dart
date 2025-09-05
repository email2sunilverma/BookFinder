import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class SavedBooksEvent extends Equatable {
  const SavedBooksEvent();

  @override
  List<Object> get props => [];
}

class LoadSavedBooksEvent extends SavedBooksEvent {
  const LoadSavedBooksEvent();
}

class SaveBookEvent extends SavedBooksEvent {
  final Book book;

  const SaveBookEvent({required this.book});

  @override
  List<Object> get props => [book];
}

class RemoveBookEvent extends SavedBooksEvent {
  final String bookKey;

  const RemoveBookEvent({required this.bookKey});

  @override
  List<Object> get props => [bookKey];
}
