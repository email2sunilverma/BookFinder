import '../repositories/book_repository.dart';

class RemoveBookUseCase {
  final BookRepository repository;
  
  RemoveBookUseCase(this.repository);
  
  Future<void> call(String bookKey) async {
    if (bookKey.trim().isEmpty) {
      throw ArgumentError('Book key cannot be empty');
    }
    
    await repository.removeBook(bookKey.trim());
  }
}
