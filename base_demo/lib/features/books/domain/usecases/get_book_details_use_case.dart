import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBookDetailsUseCase {
  final BookRepository repository;
  
  GetBookDetailsUseCase(this.repository);
  
  Future<Book?> call(String key) async {
    if (key.trim().isEmpty) {
      throw ArgumentError('Book key cannot be empty');
    }
    
    return await repository.getBookDetails(key.trim());
  }
}
