import 'dart:async';
import 'package:flutter/material.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Modern animated search bar with debouncing, clear button, and smooth
/// focus transitions. Glass-pill aesthetic, primary tint on focus.
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
    _debounce?.cancel();

    final hasText = _controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }

    _debounce = Timer(widget.debounceDuration, () {
      widget.onChanged?.call(_controller.text);
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      HapticService.light();
    }
    setState(() {});
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
    final isDark = theme.brightness == Brightness.dark;
    final isFocused = _focusNode.hasFocus;

    final baseFill = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLow;
    final focusedFill = isDark
        ? colorScheme.surfaceContainerHighest
        : colorScheme.surface;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isFocused ? focusedFill : baseFill,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFocused
              ? colorScheme.primary
              : colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isFocused ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? colorScheme.primary.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: isFocused ? 20 : 10,
            offset: Offset(0, isFocused ? 8 : 4),
            spreadRadius: isFocused ? 0.5 : 0,
          ),
        ],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.only(left: 10, right: 4),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFocused
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_rounded,
              size: 22,
              color: isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              cursorColor: colorScheme.primary,
              cursorWidth: 1.8,
              cursorRadius: const Radius.circular(2),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                  letterSpacing: 0.2,
                ),
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _showClearButton
                ? Padding(
                    key: const ValueKey('clear'),
                    padding: const EdgeInsets.only(right: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _onClear,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.08,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(
                    key: ValueKey('empty'),
                    width: 8,
                  ),
          ),
        ],
      ),
    );
  }
}
