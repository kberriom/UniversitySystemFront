import 'package:flutter/material.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class AnimatedStatusBarColor extends StatefulWidget {
  ///Expected to not have any clients
  final ScrollController scrollController;
  final Widget child;

  const AnimatedStatusBarColor({super.key, required this.scrollController, required this.child});

  @override
  State<AnimatedStatusBarColor> createState() => _AnimatedStatusBarColorState();
}

class _AnimatedStatusBarColorState extends State<AnimatedStatusBarColor> {
  final double appBarHeight = const UniSystemSliverAppBar().preferredSize.height;
  Color? animatedStatusBarColor;
  late Brightness _brightness;
  bool isScrollFullUp = true;

  @override
  void dispose() {
    widget.scrollController.removeListener(() {});
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (PlatformUtil.isAndroid) {
      _brightness = Theme.of(context).brightness;
      //On first build the scroll will be on top
      animatedStatusBarColor ??= switch (_brightness) {
        Brightness.dark => Theme.of(context).colorScheme.surfaceBright,
        Brightness.light => Theme.of(context).colorScheme.outlineVariant,
      };
      //If user switches the theme the color of the status bar has to be evaluated again
      if (widget.scrollController.hasClients) {
        if (widget.scrollController.position.pixels > appBarHeight) {
          //On scroll down past appbar
          setState(() {
            isScrollFullUp = false;
            animatedStatusBarColor = Theme.of(context).colorScheme.surfaceContainerLow;
          });
        } else if (widget.scrollController.position.pixels <= appBarHeight) {
          //On scroll full up
          setState(() {
            isScrollFullUp = true;
            animatedStatusBarColor = switch (_brightness) {
              Brightness.dark => Theme.of(context).colorScheme.surfaceBright,
              Brightness.light => Theme.of(context).colorScheme.outlineVariant,
            };
          });
        }
      }
    }
    super.didChangeDependencies();
  }

  void setScrollExtentStatusBarColorListener(BuildContext context) {
    if (!widget.scrollController.hasClients && context.isAndroid) {
      //On the first frame scrollController doesn't have any clients so the listener only gets registered once.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.scrollController.addListener(() {
          if (widget.scrollController.position.pixels > appBarHeight && isScrollFullUp) {
            //On scroll down past appbar
            setState(() {
              isScrollFullUp = false;
              animatedStatusBarColor = Theme.of(context).colorScheme.surfaceContainerLow;
            });
          } else if (widget.scrollController.position.pixels <= appBarHeight && !isScrollFullUp) {
            //On scroll full up
            setState(() {
              isScrollFullUp = true;
              animatedStatusBarColor = switch (_brightness) {
                Brightness.dark => Theme.of(context).colorScheme.surfaceBright,
                Brightness.light => Theme.of(context).colorScheme.outlineVariant,
              };
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Set the status bar color depending on scroll extent to create seamless appbar/searchBar
    setScrollExtentStatusBarColorListener(context);
    return AnimatedContainer(
      color: animatedStatusBarColor,
      duration: Durations.short1,
      child: widget.child,
    );
  }
}
