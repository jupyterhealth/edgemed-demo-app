import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StyledTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final void Function(String value)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final String? errorText;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;

  const StyledTextField({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    this.errorText,
    this.inputFormatters,
    this.readOnly = false,
  });

  @override
  State<StyledTextField> createState() => _StyledTextFieldState();
}

class _StyledTextFieldState extends State<StyledTextField> {
  static const _borderRadius = 20.0;

  late final FocusNode _focusNode;
  var _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(canRequestFocus: !widget.readOnly)
      ..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant StyledTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.readOnly != widget.readOnly) {
      _focusNode.canRequestFocus = !widget.readOnly;
    }
  }

  void _handleFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    if (hasFocus == _isFocused) return;
    setState(() => _isFocused = hasFocus);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          if (_isFocused)
            BoxShadow(
              color: context.theme.backgroundSecondary,
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 4,
            ),
        ],
      ),
      child: TextField(
        readOnly: widget.readOnly,
        enableInteractiveSelection: !widget.readOnly,
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLength: widget.maxLength,
        inputFormatters: widget.inputFormatters,
        style: context.typography.bodyLarge,
        obscuringCharacter: '●',
        decoration: InputDecoration(
          suffixIcon: widget.suffixIcon,
          errorText: widget.errorText,
          errorStyle: context.typography.bodySmall.copyWith(
            color: context.theme.error,
          ),
          hintText: widget.hintText,
          hintStyle: context.typography.bodyLarge.copyWith(
            color: context.theme.textSecondary,
          ),
          filled: true,
          fillColor: context.theme.surface,
          counterText: widget.maxLength == null ? null : '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide(color: context.theme.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide(color: context.theme.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide(color: context.theme.borderActive),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_borderRadius),
            borderSide: BorderSide(color: context.theme.error),
          ),
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }
}
