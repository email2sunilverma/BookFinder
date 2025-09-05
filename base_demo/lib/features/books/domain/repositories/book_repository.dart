import '../entities/book.dart';
import '../entities/book_search_result.dart';

abstract class BookRepository {
  Future<BookSearchResult> searchBooks({
    required String query,
    int page = 1,
    int limit = 20,
  });
  
  Future<Book?> getBookDetails(String key);
  
  Future<void> saveBook(Book book);
  
  Future<void> removeBook(String key);
  
  Future<List<Book>> getSavedBooks();
  
  Future<bool> isBookSaved(String key);
}
