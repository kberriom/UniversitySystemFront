import 'package:flutter/material.dart';

class AdminCurriculumsWidget extends StatefulWidget {
  const AdminCurriculumsWidget({super.key});

  @override
  State<AdminCurriculumsWidget> createState() => _AdminCurriculumsWidgetState();
}

class _AdminCurriculumsWidgetState extends State<AdminCurriculumsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Placeholder(
        child: Center(
          child: Text('AdminCurriculumsWidget'),
        ),
      ),
    );
  }
}
