import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;

  const SearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onSubmitted,
    this.onClear,
  });

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _showClearButton) {
      setState(() {
        _showClearButton = hasText;
      });
    }
    widget.onChanged(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearText,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
