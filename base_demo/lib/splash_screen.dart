import 'package:flutter/material.dart';
import 'injection_container.dart' as di;
import 'core/database/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
    
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_isInitialized) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      await Future.microtask(() async {
        await di.initFeaturesAsync();
        
        try {
          await Future.microtask(() async {
            await di.sl<DatabaseService>().preloadDatabase();
          });
        } catch (dbError) {
          // Continue anyway
        }
      });
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });

      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      });
      
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.85),
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          child: Center(
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              child: _buildStaticContent(primaryColor),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: child,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticContent(Color primaryColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.book,
            size: 60,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 30),
        
        const Text(
          'Book Finder',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        
        const Text(
          'Discover Amazing Books',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 50),
        
        if (!_isInitialized)
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
    );
  }
}
