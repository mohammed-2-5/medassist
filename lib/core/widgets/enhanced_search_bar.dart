import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Enhanced search bar with debouncing, clear button, and animations
class EnhancedSearchBar extends StatefulWidget {

  const EnhancedSearchBar({
    this.hintText = 'Search...',
    this.onChanged,
    this.onClear,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.controller,
    this.autofocus = false,
    this.focusNode,
    super.key,
  });
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final bool autofocus;
  final FocusNode? focusNode;

  @override
  State<EnhancedSearchBar> createState() => _EnhancedSearchBarState();
}

class _EnhancedSearchBarState extends State<EnhancedSearchBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _debounce;
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);

    _showClearButton = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    // Cancel previous timer
    _debounce?.cancel();

    // Update clear button visibility
    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }

    // Debounce the search
    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      HapticService.light();
    }
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
    HapticService.light();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colorScheme.primary
              : colorScheme.outline.withOpacity(0.3),
          width: _focusNode.hasFocus ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Icon(
            Icons.search,
            color: _focusNode.hasFocus
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _onClear,
                  tooltip: 'Clear search',
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    )
        .animate(target: _focusNode.hasFocus ? 1 : 0)
        .scaleXY(
          begin: 1,
          end: 1.02,
          duration: 200.ms,
        )
        .shimmer(
          delay: 200.ms,
          duration: 600.ms,
          color: colorScheme.primary.withOpacity(0.1),
        );
  }
}
