import 'package:equatable/equatable.dart';
import '../../../domain/entities/book.dart';

abstract class BookSearchState extends Equatable {
  const BookSearchState();

  @override
  List<Object> get props => [];
}

class BookSearchInitial extends BookSearchState {
  const BookSearchInitial();
}

class BookSearchLoading extends BookSearchState {
  const BookSearchLoading();
}

class BookSearchLoadingMore extends BookSearchState {
  final List<Book> books;
  final int currentPage;
  final String currentQuery;

  const BookSearchLoadingMore({
    required this.books,
    required this.currentPage,
    required this.currentQuery,
  });

  @override
  List<Object> get props => [books, currentPage, currentQuery];
}

class BookSearchLoaded extends BookSearchState {
  final List<Book> books;
  final bool hasMore;
  final int currentPage;
  final String currentQuery;
  final DateTime? lastUpdated; // Add timestamp to force rebuilds

  const BookSearchLoaded({
    required this.books,
    required this.hasMore,
    required this.currentPage,
    required this.currentQuery,
    this.lastUpdated,
  });

  @override
  List<Object> get props => [books, hasMore, currentPage, currentQuery, lastUpdated ?? 0];
}

class BookSearchError extends BookSearchState {
  final String message;
  final List<Book> books;
  final int currentPage;
  final String currentQuery;

  const BookSearchError({
    required this.message,
    this.books = const [],
    this.currentPage = 0,
    this.currentQuery = '',
  });

  @override
  List<Object> get props => [message, books, currentPage, currentQuery];
}

class BookSearchEmpty extends BookSearchState {
  final String query;

  const BookSearchEmpty({required this.query});

  @override
  List<Object> get props => [query];
}

class BookSearchCleared extends BookSearchState {
  const BookSearchCleared();

  @override
  List<Object> get props => [];
}
