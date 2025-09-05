import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/network_service.dart';
import '../models/book_search_result_model.dart';
import '../models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<BookSearchResultModel> searchBooks({
    required String query,
    int page = 1,
    int limit = ApiConstants.defaultLimit,
  });
  
  Future<BookModel?> getBookDetails(String key);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final NetworkService networkService;
  
  BookRemoteDataSourceImpl({required this.networkService});
  
  @override
  Future<BookSearchResultModel> searchBooks({
    required String query,
    int page = 1,
    int limit = ApiConstants.defaultLimit,
  }) async {
    final offset = (page - 1) * limit;
    
    final url = '${ApiConstants.baseUrl}${ApiConstants.searchEndpoint}'
        '?${ApiConstants.queryParam}=${Uri.encodeComponent(query)}'
        '&${ApiConstants.limitParam}=$limit'
        '&${ApiConstants.offsetParam}=$offset';
    final response = await networkService.get(url);
    return BookSearchResultModel.fromOpenLibraryResponse(response, page, limit);
  }
  
  @override
  Future<BookModel?> getBookDetails(String key) async {
    try {
      final url = '${ApiConstants.baseUrl}$key.json';
      final response = await networkService.get(url);
      
      // Extract author names from the detailed book response
      final authorNames = <String>[];
      
      // Method 1: Check if authors array exists (with author keys)
      if (response['authors'] != null) {
        final authors = response['authors'] as List;
        for (final author in authors) {
          if (author is Map<String, dynamic> && author['key'] != null) {
            // This is an author reference, we'd need another API call to get the name
            // For now, extract the author key and format it
            final authorKey = author['key'] as String;
            final authorName = authorKey.split('/').last.replaceAll('_', ' ');
            authorNames.add(authorName);
          }
        }
      }
      
      // Method 2: Check for author_name directly (from search results)
      if (authorNames.isEmpty && response['author_name'] != null) {
        final authors = response['author_name'] as List;
        authorNames.addAll(authors.map((author) => author.toString()));
      }
      
      // Method 3: Check for by_statement (publication statement with author info)
      if (authorNames.isEmpty && response['by_statement'] != null) {
        authorNames.add(response['by_statement'].toString());
      }
      
      // If still no authors found, try to get from the first author key
      if (authorNames.isEmpty && response['authors'] != null) {
        final authors = response['authors'] as List;
        if (authors.isNotEmpty && authors.first is Map) {
          final firstAuthor = authors.first as Map<String, dynamic>;
          if (firstAuthor['key'] != null) {
            // Extract author name from the key path
            final authorKey = firstAuthor['key'] as String;
            final parts = authorKey.split('/');
            if (parts.length > 2) {
              authorNames.add(_toTitleCase(parts.last.replaceAll('_', ' ')));
            }
          }
        }
      }
      
      // Transform the detailed response to match our model
      final transformedResponse = {
        'key': key,
        'title': response['title'] ?? 'Unknown Title',
        'author_name': authorNames.isNotEmpty ? authorNames : ['Unknown Author'],
        'first_publish_year': response['first_publish_date'] != null 
            ? int.tryParse(response['first_publish_date'].toString().substring(0, 4))
            : response['publish_date'] != null
            ? int.tryParse(response['publish_date'].toString().substring(0, 4))
            : null,
        'cover_i': response['covers']?.isNotEmpty == true ? response['covers'][0] : null,
      };
      
      return BookModel.fromOpenLibraryJson(transformedResponse);
    } catch (e) {
      return null;
    }
  }
  
  String _toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
