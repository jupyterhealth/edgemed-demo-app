import 'package:flutter/material.dart';

class ChartBox extends StatelessWidget {
  final Widget child;
  const ChartBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 255, 255, 255),
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }
}
