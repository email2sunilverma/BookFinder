import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SaveBookUseCase {
  final BookRepository repository;
  
  SaveBookUseCase(this.repository);
  
  Future<void> call(Book book) async {
    await repository.saveBook(book);
  }
}
