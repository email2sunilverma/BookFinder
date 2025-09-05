import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/database_constants.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/error/exceptions.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<void> saveBook(BookModel book);
  Future<void> removeBook(String key);
  Future<List<BookModel>> getSavedBooks();
  Future<bool> isBookSaved(String key);
  Future<BookModel?> getBookByKey(String key);
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  final DatabaseService databaseService;
  
  BookLocalDataSourceImpl({required this.databaseService});
  
  @override
  Future<void> saveBook(BookModel book) async {
    try {
      final db = await databaseService.database;
      await db.insert(
        DatabaseConstants.booksTable,
        book.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw CacheException('Failed to save book: ${e.toString()}');
    }
  }
  
  @override
  Future<void> removeBook(String key) async {
    try {
      final db = await databaseService.database;
      await db.delete(
        DatabaseConstants.booksTable,
        where: '${DatabaseConstants.keyColumn} = ?',
        whereArgs: [key],
      );
    } catch (e) {
      throw CacheException('Failed to remove book: ${e.toString()}');
    }
  }
  
  @override
  Future<List<BookModel>> getSavedBooks() async {
    try {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.booksTable,
        orderBy: '${DatabaseConstants.createdAtColumn} DESC',
      );
      
      return maps.map((map) => BookModel.fromDatabase(map)).toList();
    } catch (e) {
      throw CacheException('Failed to get saved books: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> isBookSaved(String key) async {
    try {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.booksTable,
        where: '${DatabaseConstants.keyColumn} = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw CacheException('Failed to check if book is saved: ${e.toString()}');
    }
  }
  
  @override
  Future<BookModel?> getBookByKey(String key) async {
    try {
      final db = await databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        DatabaseConstants.booksTable,
        where: '${DatabaseConstants.keyColumn} = ?',
        whereArgs: [key],
        limit: 1,
      );
      
      if (maps.isNotEmpty) {
        return BookModel.fromDatabase(maps.first);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get book by key: ${e.toString()}');
    }
  }
}
