import 'package:flutter/material.dart';

class AdminSubjectWidget extends StatefulWidget {
  const AdminSubjectWidget({super.key});

  @override
  State<AdminSubjectWidget> createState() => _AdminSubjectWidgetState();
}

class _AdminSubjectWidgetState extends State<AdminSubjectWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Placeholder(
        child: Center(
          child: Text('AdminSubjectWidget'),
        ),
      ),
    );
  }
}
