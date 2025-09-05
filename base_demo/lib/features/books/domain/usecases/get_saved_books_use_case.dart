import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetSavedBooksUseCase {
  final BookRepository repository;
  
  GetSavedBooksUseCase(this.repository);
  
  Future<List<Book>> call() async {
    return await repository.getSavedBooks();
  }
}
