import '../entities/book_search_result.dart';
import '../repositories/book_repository.dart';

class SearchBooksUseCase {
  final BookRepository repository;
  
  SearchBooksUseCase(this.repository);
  
  Future<BookSearchResult> call({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) {
      throw ArgumentError('Search query cannot be empty');
    }
    
    return await repository.searchBooks(
      query: query.trim(),
      page: page,
      limit: limit,
    );
  }
}
