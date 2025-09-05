class ApiConstants {
  static const String baseUrl = 'https://openlibrary.org';
  static const String searchEndpoint = '/search.json';
  static const String booksEndpoint = '/books';
  
  // Query parameters
  static const String queryParam = 'q';  // Generic query parameter
  static const String titleParam = 'title';
  static const String authorParam = 'author';
  static const String limitParam = 'limit';
  static const String offsetParam = 'offset';
  
  // Default values
  static const int defaultLimit = 20;
  static const int maxRetries = 3;
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  
}
