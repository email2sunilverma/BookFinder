import 'book.dart';

class BookSearchResult {
  final List<Book> books;
  final int totalResults;
  final int currentPage;
  final bool hasMore;
  
  const BookSearchResult({
    required this.books,
    required this.totalResults,
    required this.currentPage,
    required this.hasMore,
  });
  
  BookSearchResult copyWith({
    List<Book>? books,
    int? totalResults,
    int? currentPage,
    bool? hasMore,
  }) {
    return BookSearchResult(
      books: books ?? this.books,
      totalResults: totalResults ?? this.totalResults,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
