class DatabaseConstants {
  static const String databaseName = 'books.db';
  static const int databaseVersion = 1;
  
  // Table names
  static const String booksTable = 'books';
  
  // Column names
  static const String idColumn = 'id';
  static const String titleColumn = 'title';
  static const String authorColumn = 'author';
  static const String publishYearColumn = 'publish_year';
  static const String coverUrlColumn = 'cover_url';
  static const String keyColumn = 'key';
  static const String createdAtColumn = 'created_at';
}
