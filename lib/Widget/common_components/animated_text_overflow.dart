import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:university_system_front/Util/platform_utils.dart';

class AnimatedTextOverFlow extends StatefulWidget {
  final Text child;

  const AnimatedTextOverFlow({
    super.key,
    required this.child,
  });

  @override
  State<AnimatedTextOverFlow> createState() => _AnimatedTextOverFlowState();
}

class _AnimatedTextOverFlowState extends State<AnimatedTextOverFlow> {
  late final TextPainter textPainter;
  late final Text text;
  final _textKey = GlobalKey();
  double? textHeight;
  bool animate = false;

  Text _copyText(Text text, {Key? key}) {
    return Text(
      key: key,
      text.data!,
      overflow: text.overflow,
      maxLines: text.maxLines,
      locale: text.locale,
      style: text.style,
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

  @override
  void didChangeDependencies() {
    assert(widget.child.maxLines == 1);
    textPainter = TextPainter(
      maxLines: 1,
      textAlign: widget.child.textAlign ?? TextAlign.left,
      textDirection: widget.child.textDirection ?? TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      text: TextSpan(text: widget.child.data, style: widget.child.style),
    );
    text = _copyText(widget.child, key: _textKey);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      textHeight = _textKey.currentContext?.size?.height;
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    textPainter.dispose();
    super.dispose();
  }

  void textPainterLayoutTest(BoxConstraints constraints) {
    textPainter.layout(maxWidth: constraints.maxWidth.floorToDouble() - 15);
  }

  @override
  Widget build(BuildContext context) {
    final layoutBuilder = LayoutBuilder(
      builder: (context, constraints) {
        textPainterLayoutTest(constraints);
        if (textPainter.didExceedMaxLines && animate && textHeight != null) {
          return SizedBox(
            width: constraints.maxWidth,
            height: textHeight,
            child: Marquee(
              textScaleFactor: textPainter.textScaler.scale(1),
              pauseAfterRound: const Duration(milliseconds: 3000),
              numberOfRounds: PlatformUtil.isAndroid ? 3 : null,
              onDone: PlatformUtil.isAndroid ? () => animate = false : null,
              text: widget.child.data!,
              style: widget.child.style,
              blankSpace: 16,
            ),
          );
        } else {
          return text;
        }
      },
    );

    if (PlatformUtil.isWindows) {
      return MouseRegion(
        onEnter: (_) => setState(() => animate = true),
        onExit: (_) => setState(() => animate = false),
        child: layoutBuilder,
      );
    } else {
      return GestureDetector(
        onLongPressDown: (_) {
          setState(() => animate = true);
        },
        child: layoutBuilder,
      );
    }
  }
}
