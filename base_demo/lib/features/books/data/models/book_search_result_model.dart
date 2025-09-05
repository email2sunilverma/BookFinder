import '../../domain/entities/book_search_result.dart';
import 'book_model.dart';

class BookSearchResultModel extends BookSearchResult {
  const BookSearchResultModel({
    required super.books,
    required super.totalResults,
    required super.currentPage,
    required super.hasMore,
  });
  
  factory BookSearchResultModel.fromOpenLibraryResponse(
    Map<String, dynamic> json,
    int currentPage,
    int limit,
  ) {
    final docs = json['docs'] as List? ?? [];
    final totalResults = json['numFound'] as int? ?? 0;
    
    final books = docs
        .map((doc) => BookModel.fromOpenLibraryJson(doc))
        .toList();
    
    final hasMore = (currentPage * limit) < totalResults;
    
    return BookSearchResultModel(
      books: books,
      totalResults: totalResults,
      currentPage: currentPage,
      hasMore: hasMore,
    );
  }
}
