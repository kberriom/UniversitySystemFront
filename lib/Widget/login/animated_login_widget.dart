import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_animations/animation_builder/play_animation_builder.dart';
import 'package:university_system_front/Widget/login/base_login_widget.dart';
import 'package:university_system_front/Widget/login/login_widget_form.dart';

class AnimatedLoginWidget extends ConsumerStatefulWidget {
  const AnimatedLoginWidget({super.key});

  @override
  ConsumerState createState() => _AnimatedLoginWidgetState();
}

class _AnimatedLoginWidgetState extends ConsumerState<AnimatedLoginWidget> {
  bool _isShowingHeroWidgetChild = true;

  Animation<double>? _heroAnimation;

  late final Image _heroChild;
  final GlobalKey _heroWidgetChildKey = GlobalKey();
  Future<Size>? _heroWidgetChildSize;

  @override
  void initState() {
    _heroChild = Image(image: const AssetImage('assets/logo.png'), key: _heroWidgetChildKey);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _heroWidgetChildSize = Future.value(_heroWidgetChildKey.currentContext?.size);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseLoginWidget(
      logoImageWidgetList: [
        Hero(
          tag: 'login_splash',
          child: Visibility(visible: _isShowingHeroWidgetChild, child: _heroChild),
          flightShuttleBuilder: (flightContext, animation, flightDirection, fromHeroContext, toHeroContext) {
            if (_heroAnimation == null) {
              _heroAnimation = animation;
              animation.addStatusListener(_heroAnimationCompleted);
            }
            return toHeroContext.widget;
          },
        ),
        //This Opacity widget keeps the LoginWidgetForm from jumping around.
        //Cannot be replaced with a SizedBox since the final image size is based on device pixel density
        //and size cannot be known until the first frame has been rendered.
        const Opacity(opacity: 0, child: Image(image: AssetImage('assets/logo_full_nobg_v1.png'))),
        Visibility(
          visible: !_isShowingHeroWidgetChild,
          child: LayoutBuilder(
            //Helps to find the full size the image will occupy
            builder: (context, constraints) => FutureBuilder(
              //Defers the build of the animation until the size of image is ready
              future: _heroWidgetChildSize,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    constraints.hasBoundedWidth &&
                    !_isShowingHeroWidgetChild) {
                  return PlayAnimationBuilder(
                    key: const ValueKey('logoAnimation'),
                    tween: Tween(begin: snapshot.data?.width, end: constraints.maxWidth),
                    duration: AnimatedLoginTimers.expandLogoAnimation.duration,
                    curve: Curves.decelerate,
                    builder: (context, value, child) {
                      return SizedBox(width: value, child: child);
                    },
                    child: const Image(image: AssetImage('assets/logo_full_nobg_v1.png')),
                  );
                } else {
                  return const Image(
                      image: AssetImage('assets/logo.png')); //Helps avoid a flash when the animation is swapped in
                }
              },
            ),
          ),
        ),
      ],
      loginWidgetForm: AnimatedOpacity(
        curve: Curves.easeInOut,
        opacity: _isShowingHeroWidgetChild ? 0 : 1,
        duration: AnimatedLoginTimers.loginFormAnimation.duration,
        child: const LoginWidgetForm(),
      ),
    );
  }

  void _heroAnimationCompleted(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _isShowingHeroWidgetChild = false;
      });
      _heroAnimation!.removeStatusListener(_heroAnimationCompleted);
    }
  }
}

enum AnimatedLoginTimers {
  ///Time the hero logo takes to expand to the final hi-res logo
  expandLogoAnimation(duration: Duration(milliseconds: 800)),

  ///Login fade-in animation duration
  loginFormAnimation(duration: Duration(milliseconds: 900)),

  ///Duration of the hero transition from the center to the top of the screen
  heroAnimation(duration: Duration(milliseconds: 850));

  final Duration duration;

  const AnimatedLoginTimers({required this.duration});
}
