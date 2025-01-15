import 'package:flutter/material.dart';

class DynamicTextSize extends StatefulWidget {
  final Text child;
  final double toleranceSize;
  final double minSize;

  const DynamicTextSize({
    super.key,
    this.toleranceSize = 7,
    this.minSize = 0,
    required this.child,
  });

  @override
  State<DynamicTextSize> createState() => _DynamicTextSizeState();
}

class _DynamicTextSizeState extends State<DynamicTextSize> {
  late final TextPainter textPainter;
  late double fontSize;
  double? lastMaxWidth;

  @override
  void didChangeDependencies() {
    fontSize = widget.child.style!.fontSize!;
    textPainter = TextPainter(
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: widget.child.maxLines,
      textAlign: widget.child.textAlign ?? TextAlign.left,
      textDirection: widget.child.textDirection ?? TextDirection.ltr,
      text: buildTextSpan(),
    );
    super.didChangeDependencies();
  }

  TextSpan buildTextSpan({TextStyle? style}) {
    return TextSpan(text: widget.child.data, style: style ?? widget.child.style);
  }

  @override
  void dispose() {
    textPainter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(builder: (context, constraints) {
        lastMaxWidth ??= constraints.maxWidth;
        TextStyle? textStyle;

        if (constraints.maxWidth > lastMaxWidth!) {
          fontSize = widget.child.style!.fontSize!;
          textStyle = widget.child.style!.copyWith(fontSize: fontSize);
          updateTextPainter(textStyle, constraints);
        }

        textPainterLayoutTest(constraints);
        lastMaxWidth = constraints.maxWidth;

        while (textPainter.didExceedMaxLines && fontSize > 0 && !(fontSize <= widget.minSize)) {
          fontSize = (fontSize - 2).clamp(0, widget.child.style!.fontSize!);
          textStyle = widget.child.style!.copyWith(fontSize: fontSize);

          updateTextPainter(textStyle, constraints);
          textPainterLayoutTest(constraints);
        }

        textStyle ??= widget.child.style!.copyWith(fontSize: fontSize);
        return copyText(widget.child, key: ValueKey(fontSize), style: textStyle);
      }),
    );
  }

  void textPainterLayoutTest(BoxConstraints constraints) {
    textPainter.layout(maxWidth: constraints.maxWidth.floorToDouble() - widget.toleranceSize);
  }

  void updateTextPainter(TextStyle textStyle, BoxConstraints constraints) {
    textPainter.text = buildTextSpan(style: textStyle);
  }

  Text copyText(Text text, {Key? key, TextStyle? style}) {
    return Text(
      key: key,
      text.data!,
      overflow: text.overflow,
      maxLines: text.maxLines,
      locale: text.locale,
      style: style ?? text.style,
      selectionColor: text.selectionColor,
      semanticsLabel: text.semanticsLabel,
      softWrap: text.softWrap,
      strutStyle: text.strutStyle,
      textAlign: text.textAlign,
      textDirection: text.textDirection,
      textHeightBehavior: text.textHeightBehavior,
      textScaler: text.textScaler,
      textWidthBasis: text.textWidthBasis,
    );
  }
}
