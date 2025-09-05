import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'core/network/network_service.dart';
import 'core/database/database_service.dart';

import 'features/books/data/datasources/book_remote_data_source.dart';
import 'features/books/data/datasources/book_local_data_source.dart';
import 'features/books/data/repositories/book_repository_impl.dart';
import 'features/books/domain/repositories/book_repository.dart';

import 'features/books/domain/usecases/search_books_use_case.dart';
import 'features/books/domain/usecases/save_book_use_case.dart';
import 'features/books/domain/usecases/get_saved_books_use_case.dart';
import 'features/books/domain/usecases/get_book_details_use_case.dart';
import 'features/books/domain/usecases/remove_book_use_case.dart';

import 'features/books/presentation/bloc/book_search/book_search_bloc.dart';
import 'features/books/presentation/bloc/book_details/book_details_bloc.dart';
import 'features/books/presentation/bloc/saved_books/saved_books_bloc.dart';

import 'features/device_info/data/services/device_info_service.dart';
import 'features/device_info/presentation/bloc/device_info_bloc.dart';

import 'features/sensors/data/services/sensor_service.dart';
import 'features/sensors/presentation/bloc/sensor_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await initCore();
  await initFeaturesAsync();
}

Future<void> initCore() async {
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => NetworkService(client: sl()));
  sl.registerLazySingleton(() => DatabaseService());
}

Future<void> initFeaturesAsync() async {
  await Future.microtask(() => _initBooks());
  await Future.delayed(Duration.zero);
  await Future.microtask(() => _initDeviceInfo());
  await Future.delayed(Duration.zero);
  await Future.microtask(() => _initSensors());
}

Future<void> _initBooks() async {
  sl.registerLazySingleton<BookRemoteDataSource>(
    () => BookRemoteDataSourceImpl(networkService: sl()),
  );
  sl.registerLazySingleton<BookLocalDataSource>(
    () => BookLocalDataSourceImpl(databaseService: sl()),
  );

  sl.registerLazySingleton<BookRepository>(
    () => BookRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SearchBooksUseCase(sl()));
  sl.registerLazySingleton(() => SaveBookUseCase(sl()));
  sl.registerLazySingleton(() => GetSavedBooksUseCase(sl()));
  sl.registerLazySingleton(() => GetBookDetailsUseCase(sl()));
  sl.registerLazySingleton(() => RemoveBookUseCase(sl()));

  sl.registerFactory(() => BookSearchBloc(searchBooksUseCase: sl()));
  sl.registerFactory(() => BookDetailsBloc(
        getBookDetailsUseCase: sl(),
        saveBookUseCase: sl(),
        removeBookUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SavedBooksBloc(
        getSavedBooksUseCase: sl(),
        saveBookUseCase: sl(),
        removeBookUseCase: sl(),
      ));
}

Future<void> _initDeviceInfo() async {
  sl.registerLazySingleton(() => DeviceInfoService());
  sl.registerFactory(() => DeviceInfoBloc(deviceInfoService: sl()));
}

Future<void> _initSensors() async {
  sl.registerLazySingleton(() => SensorService());
  sl.registerFactory(() => SensorBloc(sensorService: sl()));
}
