import 'package:flutter/material.dart';
import 'package:university_system_front/Theme/dimensions.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  final String text;
  final Icon icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(text),
      style: ButtonStyle(
        fixedSize: const WidgetStatePropertyAll(Size.fromHeight(60)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall))),
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainer),
      ),
    );
  }
}
