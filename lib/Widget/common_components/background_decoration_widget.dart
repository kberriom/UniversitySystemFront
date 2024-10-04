import 'package:flutter/material.dart';

class UniSystemBackgroundDecoration extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const UniSystemBackgroundDecoration({super.key, required this.child}) : backgroundColor = null;

  const UniSystemBackgroundDecoration.backgroundColor({super.key, required this.child, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: Container(
        decoration: const BoxDecoration(
          image:
              DecorationImage(image: AssetImage('assets/logo_no_shadow_rotated.png'), repeat: ImageRepeat.repeat, opacity: 0.05),
        ),
        child: child,
      ),
    );
  }
}
