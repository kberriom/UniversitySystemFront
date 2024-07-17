import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminUsersWidget extends ConsumerStatefulWidget {
  const AdminUsersWidget({super.key});

  @override
  ConsumerState createState() => _AdminUsersWidgetState();
}

class _AdminUsersWidgetState extends ConsumerState<AdminUsersWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: const Placeholder(
          child: Center(
            child: Text('AdminUSERSWidget'),
          ),
        ),
      ),
    );
  }
}
