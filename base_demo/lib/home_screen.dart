import 'package:flutter/material.dart';
import 'features/books/presentation/pages/book_search_screen.dart';
import 'features/books/presentation/pages/saved_books_screen.dart';
import 'features/device_info/presentation/pages/dashboard_screen.dart';
import 'features/sensors/presentation/pages/sensor_info_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const HomeScreen({super.key, this.initialTabIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedIndex;

  static const List<Widget> _pages = <Widget>[
    BookSearchScreen(),
    SavedBooksScreen(),
    DashboardScreen(),
    SensorInfoScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTabIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Device',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensors',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
