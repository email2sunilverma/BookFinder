import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/database_constants.dart';

class DatabaseService {
  static Database? _database;
  static bool _isInitializing = false;
  
  /// Get database instance with lazy initialization
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Prevent multiple concurrent initializations
    if (_isInitializing) {
      while (_isInitializing) {
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return _database!;
    }
    
    _isInitializing = true;
    try {
      _database = await _initDatabase();
      return _database!;
    } finally {
      _isInitializing = false;
    }
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), DatabaseConstants.databaseName);
    
    return await openDatabase(
      path,
      version: DatabaseConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      // Optimize database performance
      readOnly: false,
      singleInstance: true,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DatabaseConstants.booksTable} (
        ${DatabaseConstants.idColumn} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DatabaseConstants.keyColumn} TEXT UNIQUE NOT NULL,
        ${DatabaseConstants.titleColumn} TEXT NOT NULL,
        ${DatabaseConstants.authorColumn} TEXT,
        ${DatabaseConstants.publishYearColumn} INTEGER,
        ${DatabaseConstants.coverUrlColumn} TEXT,
        ${DatabaseConstants.createdAtColumn} TEXT NOT NULL
      )
    ''');
    
    // Create indexes for better query performance
    await db.execute('''
      CREATE INDEX idx_books_key ON ${DatabaseConstants.booksTable}(${DatabaseConstants.keyColumn})
    ''');
    
    await db.execute('''
      CREATE INDEX idx_books_created_at ON ${DatabaseConstants.booksTable}(${DatabaseConstants.createdAtColumn})
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here if needed
    if (oldVersion < 2) {
      // Example: Add indexes if they don't exist
      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_books_key ON ${DatabaseConstants.booksTable}(${DatabaseConstants.keyColumn})
      ''');
    }
  }
  
  /// Preload database in background to avoid first-access delay
  Future<void> preloadDatabase() async {
    try {
      // Use microtask to avoid blocking main thread
      await Future.microtask(() async {
        await database;
        // Add a small delay to yield control back to UI thread
        await Future.delayed(Duration.zero);
      });
    } catch (e) {
      // Silently handle preload errors - database will be initialized on first actual use
    }
  }
  
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
