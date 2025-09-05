import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class BookDetailsEvent extends Equatable {
  const BookDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadBookDetailsEvent extends BookDetailsEvent {
  final String bookKey;

  const LoadBookDetailsEvent({required this.bookKey});

  @override
  List<Object> get props => [bookKey];
}

class SetBookDetailsEvent extends BookDetailsEvent {
  final Book book;

  const SetBookDetailsEvent({required this.book});

  @override
  List<Object> get props => [book];
}

class ToggleBookSavedEvent extends BookDetailsEvent {
  const ToggleBookSavedEvent();
}

class ClearBookDetailsEvent extends BookDetailsEvent {
  const ClearBookDetailsEvent();
}
