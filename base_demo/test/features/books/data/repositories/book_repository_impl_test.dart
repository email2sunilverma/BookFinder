import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:base_demo/features/books/data/repositories/book_repository_impl.dart';
import 'package:base_demo/features/books/data/datasources/book_remote_data_source.dart';
import 'package:base_demo/features/books/data/datasources/book_local_data_source.dart';
import 'package:base_demo/features/books/data/models/book_model.dart';
import 'package:base_demo/features/books/data/models/book_search_result_model.dart';
import 'package:base_demo/features/books/domain/entities/book.dart';
import 'package:base_demo/core/error/exceptions.dart';

import 'book_repository_impl_test.mocks.dart';

@GenerateMocks([BookRemoteDataSource, BookLocalDataSource])
void main() {
  late BookRepositoryImpl repository;
  late MockBookRemoteDataSource mockRemoteDataSource;
  late MockBookLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockBookRemoteDataSource();
    mockLocalDataSource = MockBookLocalDataSource();
    repository = BookRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('searchBooks', () {
    const testQuery = 'flutter';
    const testPage = 1;
    const testLimit = 20;

    final testBookModel = BookModel(
      key: '/works/test1',
      title: 'Test Book',
      authors: const ['Test Author'],
      publishYear: 2023,
      coverUrl: 'https://example.com/cover.jpg',
    );

    final testSearchResult = BookSearchResultModel(
      books: [testBookModel],
      totalResults: 1,
      currentPage: testPage,
      hasMore: false,
    );

    test('should return search results when remote call is successful', () async {
      // arrange
      when(mockRemoteDataSource.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      )).thenAnswer((_) async => testSearchResult);
      
      when(mockLocalDataSource.isBookSaved(testBookModel.key))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      );

      // assert
      expect(result.books.length, 1);
      expect(result.books.first.key, testBookModel.key);
      expect(result.books.first.isSaved, false);
      expect(result.totalResults, 1);
      expect(result.currentPage, testPage);
      expect(result.hasMore, false);
      
      verify(mockRemoteDataSource.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      ));
      verify(mockLocalDataSource.isBookSaved(testBookModel.key));
    });

    test('should mark books as saved when they exist locally', () async {
      // arrange
      when(mockRemoteDataSource.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      )).thenAnswer((_) async => testSearchResult);
      
      when(mockLocalDataSource.isBookSaved(testBookModel.key))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      );

      // assert
      expect(result.books.first.isSaved, true);
      verify(mockLocalDataSource.isBookSaved(testBookModel.key));
    });

    test('should throw exception when remote data source fails', () async {
      // arrange
      when(mockRemoteDataSource.searchBooks(
        query: testQuery,
        page: testPage,
        limit: testLimit,
      )).thenThrow(const ServerException('Server error'));

      // act & assert
      expect(
        () async => await repository.searchBooks(
          query: testQuery,
          page: testPage,
          limit: testLimit,
        ),
        throwsException,
      );
    });
  });

  group('saveBook', () {
    final testBook = Book(
      key: '/works/test1',
      title: 'Test Book',
      authors: const ['Test Author'],
      publishYear: 2023,
      coverUrl: 'https://example.com/cover.jpg',
    );

    test('should save book successfully', () async {
      // arrange
      when(mockLocalDataSource.saveBook(any))
          .thenAnswer((_) async => {});

      // act
      await repository.saveBook(testBook);

      // assert
      verify(mockLocalDataSource.saveBook(any));
    });

    test('should throw exception when local data source fails', () async {
      // arrange
      when(mockLocalDataSource.saveBook(any))
          .thenThrow(const CacheException('Cache error'));

      // act & assert
      expect(
        () async => await repository.saveBook(testBook),
        throwsException,
      );
    });
  });

  group('getSavedBooks', () {
    final testBooks = [
      BookModel(
        key: '/works/test1',
        title: 'Test Book 1',
        authors: const ['Test Author 1'],
        isSaved: true,
      ),
      BookModel(
        key: '/works/test2',
        title: 'Test Book 2',
        authors: const ['Test Author 2'],
        isSaved: true,
      ),
    ];

    test('should return saved books from local data source', () async {
      // arrange
      when(mockLocalDataSource.getSavedBooks())
          .thenAnswer((_) async => testBooks);

      // act
      final result = await repository.getSavedBooks();

      // assert
      expect(result.length, 2);
      expect(result.first.key, testBooks.first.key);
      expect(result.last.key, testBooks.last.key);
      verify(mockLocalDataSource.getSavedBooks());
    });

    test('should throw exception when local data source fails', () async {
      // arrange
      when(mockLocalDataSource.getSavedBooks())
          .thenThrow(const CacheException('Cache error'));

      // act & assert
      expect(
        () async => await repository.getSavedBooks(),
        throwsException,
      );
    });
  });

  group('isBookSaved', () {
    const testKey = '/works/test1';

    test('should return true when book is saved', () async {
      // arrange
      when(mockLocalDataSource.isBookSaved(testKey))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.isBookSaved(testKey);

      // assert
      expect(result, true);
      verify(mockLocalDataSource.isBookSaved(testKey));
    });

    test('should return false when book is not saved', () async {
      // arrange
      when(mockLocalDataSource.isBookSaved(testKey))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.isBookSaved(testKey);

      // assert
      expect(result, false);
      verify(mockLocalDataSource.isBookSaved(testKey));
    });
  });
}
