import '../../domain/entities/book.dart';
import '../../domain/entities/book_search_result.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_data_source.dart';
import '../datasources/book_local_data_source.dart';
import '../models/book_model.dart';
import '../../../../core/error/exceptions.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;
  
  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<BookSearchResult> searchBooks({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final result = await remoteDataSource.searchBooks(
        query: query,
        page: page,
        limit: limit,
      );
      
      // Check which books are saved locally
      final booksWithSaveStatus = <Book>[];
      for (final book in result.books) {
        final isSaved = await localDataSource.isBookSaved(book.key);
        final bookModel = book as BookModel;
        booksWithSaveStatus.add(bookModel.copyWith(isSaved: isSaved));
      }
      
      return BookSearchResult(
        books: booksWithSaveStatus,
        totalResults: result.totalResults,
        currentPage: result.currentPage,
        hasMore: result.hasMore,
      );
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    } on NetworkException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unknown error: ${e.toString()}');
    }
  }
  
  @override
  Future<Book?> getBookDetails(String key) async {
    try {
      // First check if book is saved locally
      final localBook = await localDataSource.getBookByKey(key);
      if (localBook != null) {
        return localBook;
      }
      
      // If not found locally, fetch from remote
      final remoteBook = await remoteDataSource.getBookDetails(key);
      if (remoteBook != null) {
        final isSaved = await localDataSource.isBookSaved(key);
        return remoteBook.copyWith(isSaved: isSaved);
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get book details: ${e.toString()}');
    }
  }
  
  @override
  Future<void> saveBook(Book book) async {
    try {
      final bookModel = BookModel(
        key: book.key,
        title: book.title,
        authors: book.authors,
        publishYear: book.publishYear,
        coverUrl: book.coverUrl,
        isSaved: true,
      );
      
      await localDataSource.saveBook(bookModel);
    } on CacheException catch (e) {
      throw Exception('Cache error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to save book: ${e.toString()}');
    }
  }
  
  @override
  Future<void> removeBook(String key) async {
    try {
      await localDataSource.removeBook(key);
    } on CacheException catch (e) {
      throw Exception('Cache error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to remove book: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Book>> getSavedBooks() async {
    try {
      final books = await localDataSource.getSavedBooks();
      return books.cast<Book>();
    } on CacheException catch (e) {
      throw Exception('Cache error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get saved books: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> isBookSaved(String key) async {
    try {
      return await localDataSource.isBookSaved(key);
    } on CacheException catch (e) {
      throw Exception('Cache error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to check if book is saved: ${e.toString()}');
    }
  }
}
