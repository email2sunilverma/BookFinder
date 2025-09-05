class Book {
  final String key;
  final String title;
  final List<String> authors;
  final int? publishYear;
  final String? coverUrl;
  final bool isSaved;
  
  const Book({
    required this.key,
    required this.title,
    required this.authors,
    this.publishYear,
    this.coverUrl,
    this.isSaved = false,
  });
  
  Book copyWith({
    String? key,
    String? title,
    List<String>? authors,
    int? publishYear,
    String? coverUrl,
    bool? isSaved,
  }) {
    return Book(
      key: key ?? this.key,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      publishYear: publishYear ?? this.publishYear,
      coverUrl: coverUrl ?? this.coverUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Book && other.key == key;
  }
  
  @override
  int get hashCode => key.hashCode;
  
  @override
  String toString() {
    return 'Book(key: $key, title: $title, authors: $authors, publishYear: $publishYear, coverUrl: $coverUrl, isSaved: $isSaved)';
  }
}
