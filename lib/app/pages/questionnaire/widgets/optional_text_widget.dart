import 'package:flutter/material.dart';
import 'package:jupyter_health/app/common/widgets/styled_text_field.dart';
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
      clipBehavior: Clip.none,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.question, style: context.typography.headerMedium),
          const SizedBox(height: 4),
          Text(widget.description, style: context.typography.bodyLarge),
          const SizedBox(height: 16),
          StyledTextField(
            controller: _controller,
            onChanged: widget.onAnswerChanged,
            hintText: 'Start typing...',
          ),
        ],
      ),
    );
  }
}
