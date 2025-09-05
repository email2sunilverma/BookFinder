import 'package:equatable/equatable.dart';

abstract class BookSearchEvent extends Equatable {
  const BookSearchEvent();

  @override
  List<Object> get props => [];
}

class SearchBooksEvent extends BookSearchEvent {
  final String query;
  final bool isRefresh;

  const SearchBooksEvent({
    required this.query,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [query, isRefresh];
}

class LoadMoreBooksEvent extends BookSearchEvent {
  const LoadMoreBooksEvent();
}

class ClearSearchEvent extends BookSearchEvent {
  const ClearSearchEvent();
}

class UpdateBookSaveStatusEvent extends BookSearchEvent {
  final String bookKey;
  final bool isSaved;

  const UpdateBookSaveStatusEvent({
    required this.bookKey,
    required this.isSaved,
  });

  @override
  List<Object> get props => [bookKey, isSaved];
}
