import 'package:flutter/material.dart';
import 'package:university_system_front/Theme/dimensions.dart';

class QuickActionButton extends StatelessWidget {
  const QuickActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
    this.height = 60,
  });

  final String text;
  final Widget icon;
  final double height;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: Text(text),
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(height)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall))),
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainer),
      ),
    );
  }
}

class UniSystemDetailHeader extends StatelessWidget {
  const UniSystemDetailHeader({
    super.key,
    required this.header,
    this.alignment = Alignment.topCenter,
    this.backgroundColor,
  });

  final Widget header;
  final Alignment alignment;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
      width: double.infinity,
      color: backgroundColor ?? Theme.of(context).colorScheme.surfaceContainerLow,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, minWidth: 300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: header,
            ),
          ],
        ),
      ),
    );
  }
}

class UniSystemDetailBody extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const UniSystemDetailBody({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: padding,
          width: double.infinity,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
