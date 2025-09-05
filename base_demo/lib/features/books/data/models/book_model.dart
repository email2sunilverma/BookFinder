import '../../domain/entities/book.dart';

class BookModel extends Book {
  const BookModel({
    required super.key,
    required super.title,
    required super.authors,
    super.publishYear,
    super.coverUrl,
    super.isSaved,
  });
  
  factory BookModel.fromOpenLibraryJson(Map<String, dynamic> json) {
    final key = json['key'] as String? ?? '';
    final title = json['title'] as String? ?? 'Unknown Title';
    
    final authorNames = <String>[];
    if (json['author_name'] != null) {
      final authors = json['author_name'] as List;
      for (final author in authors) {
        final authorStr = author.toString();
        if (authorStr.isNotEmpty && authorStr.toLowerCase() != 'null') {
          authorNames.add(authorStr);
        }
      }
    }
    
    final publishYear = json['first_publish_year'] as int?;
    
    String? coverUrl;
    if (json['cover_i'] != null) {
      final coverId = json['cover_i'];
      coverUrl = 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
    }
    
    return BookModel(
      key: key,
      title: title,
      authors: authorNames,
      publishYear: publishYear,
      coverUrl: coverUrl,
    );
  }
  
  Map<String, dynamic> toDatabase() {
    // Filter out null/empty authors before joining
    final validAuthors = authors
        .where((author) => author.isNotEmpty && author.toLowerCase() != 'null')
        .toList();
    
    return {
      'key': key,
      'title': title,
      'author': validAuthors.isNotEmpty ? validAuthors.join(', ') : 'Unknown Author',
      'publish_year': publishYear,
      'cover_url': coverUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
  
  factory BookModel.fromDatabase(Map<String, dynamic> map) {
    // Parse authors with proper null handling
    List<String> authorsList = [];
    final authorString = map['author'] as String?;
    if (authorString != null && authorString.isNotEmpty && authorString.toLowerCase() != 'null') {
      authorsList = authorString.split(', ')
          .where((author) => author.isNotEmpty && author.toLowerCase() != 'null')
          .toList();
    }
    
    return BookModel(
      key: map['key'] as String,
      title: map['title'] as String,
      authors: authorsList,
      publishYear: map['publish_year'] as int?,
      coverUrl: map['cover_url'] as String?,
      isSaved: true,
    );
  }
  
  @override
  BookModel copyWith({
    String? key,
    String? title,
    List<String>? authors,
    int? publishYear,
    String? coverUrl,
    bool? isSaved,
  }) {
    return BookModel(
      key: key ?? this.key,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      publishYear: publishYear ?? this.publishYear,
      coverUrl: coverUrl ?? this.coverUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}
