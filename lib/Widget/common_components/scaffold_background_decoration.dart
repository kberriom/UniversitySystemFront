import 'package:flutter/material.dart';

class ScaffoldBackgroundDecoration extends StatelessWidget {
  final Widget child;

  const ScaffoldBackgroundDecoration({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage('assets/logo_no_shadow_rotated.png'), repeat: ImageRepeat.repeat, opacity: 0.05),
      ),
      child: child,
    );
  }
}
