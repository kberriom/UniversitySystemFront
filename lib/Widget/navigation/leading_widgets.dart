import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Theme/theme_mode_provider.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

part 'leading_widgets.g.dart';

@riverpod
class UniSystemAppBarLeading extends _$UniSystemAppBarLeading {
  @override
  Widget? build() {
    if (PlatformUtil.isWindows) {
      return IconButton(
        onPressed: () {
          ref.read(currentThemeModeProvider.notifier).changeThemeMode();
        },
        icon: Icon(ref.watch(currentThemeModeProvider) == ThemeMode.light ? Icons.sunny : Icons.nightlight_round_sharp),
      );
    }
    return null;
  }

  void setLeading(Widget? leading) {
    if (!PlatformUtil.isAndroid) {
      state = leading;
    }
  }
}

class VisibilityLeadingWrapper extends ConsumerWidget {
  const VisibilityLeadingWrapper({super.key, required this.pageKey, required this.leading, required this.widget});

  final ValueKey pageKey;
  final Widget widget;
  final Widget leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return VisibilityDetector(
      key: pageKey,
      onVisibilityChanged: (VisibilityInfo info) {
        if (info.visibleFraction > 0 && ref.read(uniSystemAppBarLeadingProvider) is! UniSystemBackButton) {
          _setPostFrameLeadingChange(ref, leading);
        }
      },
      child: Builder(builder: (context) {
        _setPostFrameLeadingChange(ref, leading);
        return widget;
      }),
    );
  }

  void _setPostFrameLeadingChange(WidgetRef ref, Widget leading) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(uniSystemAppBarLeadingProvider.notifier).setLeading(leading);
    });
  }
}

class UniSystemBackButton extends ConsumerWidget {
  const UniSystemBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BackButton(onPressed: () {
      ref.read(goRouterInstanceProvider).routerDelegate.pop();
    });
  }
}
