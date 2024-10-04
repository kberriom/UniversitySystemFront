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

class UniSystemDetailHeader extends StatelessWidget {
  const UniSystemDetailHeader({
    super.key,
    required this.header,
  });

  final Widget header;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
      width: double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
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

  const UniSystemDetailBody({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding),
          width: double.infinity,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }
}
