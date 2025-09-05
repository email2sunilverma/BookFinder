import 'package:flutter/material.dart';

class AnimatedBookCover extends StatefulWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const AnimatedBookCover({
    super.key,
    this.imageUrl,
    this.width = 200,
    this.height = 300,
  });

  @override
  State<AnimatedBookCover> createState() => _AnimatedBookCoverState();
}

class _AnimatedBookCoverState extends State<AnimatedBookCover>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the animation
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.imageUrl != null
                  ? Image.network(
                      widget.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildPlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return _buildPlaceholder();
                      },
                    )
                  : _buildPlaceholder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Icon(
        Icons.book,
        size: 80,
        color: Colors.grey,
      ),
    );
  }
}
