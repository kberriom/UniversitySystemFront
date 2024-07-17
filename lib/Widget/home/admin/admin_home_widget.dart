import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Placeholder(
        child: Center(
          child: Text('AdminHOMEWidget'),
        ),
      ),
    );
  }
}
