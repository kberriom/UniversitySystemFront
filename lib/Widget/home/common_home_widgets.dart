import 'package:flutter/material.dart';

class HomeTextTitle extends StatelessWidget {

  final String text;

  const HomeTextTitle({
    super.key, required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: FractionallySizedBox(
          widthFactor: 0.7,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16),
              child: Text(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text,
                style: const TextStyle(fontFamily: 'blazma', fontStyle: FontStyle.italic, fontSize: 32),
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.onSurface),
          ]),
        ),
      ),
    );
  }
}