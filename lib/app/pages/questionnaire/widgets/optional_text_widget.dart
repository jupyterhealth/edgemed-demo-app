import 'package:flutter/material.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class OptionalTextWidget extends StatefulWidget {
  final String question;
  final String description;
  final String? answer;
  final void Function(String answer) onAnswerChanged;

  const OptionalTextWidget({
    super.key,
    required this.question,
    required this.description,
    required this.answer,
    required this.onAnswerChanged,
  });

  @override
  State<OptionalTextWidget> createState() => _OptionalTextWidgetState();
}

class _OptionalTextWidgetState extends State<OptionalTextWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.answer ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: context.typography.headerMedium),
          const SizedBox(height: 4),
          Text(widget.description, style: context.typography.bodyLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: widget.onAnswerChanged,
            style: context.typography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Start typing...',
              hintStyle: context.typography.bodyLarge.copyWith(
                color: context.theme.textSecondary,
              ),
              filled: true,
              fillColor: context.theme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: context.theme.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: context.theme.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: context.theme.borderDark),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}
