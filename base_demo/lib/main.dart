import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'features/books/presentation/bloc/book_search/book_search_bloc.dart';
import 'features/books/presentation/bloc/book_details/book_details_bloc.dart';
import 'features/books/presentation/bloc/saved_books/saved_books_bloc.dart';
import 'features/device_info/presentation/bloc/device_info_bloc.dart';
import 'features/sensors/presentation/bloc/sensor_bloc.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize everything including features
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Finder',
      theme: _buildTheme(),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/home': (context) => _buildHome(),
      },
    );
  }
  
  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      fontFamily: null,
    );
  }
  
  Widget _buildHome() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<BookSearchBloc>(
          lazy: false,
          create: (_) => di.sl<BookSearchBloc>(),
        ),
        BlocProvider<BookDetailsBloc>(
          lazy: true,
          create: (_) => di.sl<BookDetailsBloc>(),
        ),
        BlocProvider.value(
          value: di.sl<SavedBooksBloc>(),
        ),
        BlocProvider<DeviceInfoBloc>(
          lazy: true,
          create: (_) => di.sl<DeviceInfoBloc>(),
        ),
        BlocProvider<SensorBloc>(
          lazy: true,
          create: (_) => di.sl<SensorBloc>(),
        ),
      ],
      child: const HomeScreen(),
    );
  }
}
