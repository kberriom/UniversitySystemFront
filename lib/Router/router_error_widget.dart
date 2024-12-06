import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Router/go_router_config.dart';
import 'package:university_system_front/Service/login_service.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';

class RouterErrorWidget extends ConsumerWidget {
  const RouterErrorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const DynamicUniSystemAppBar(isInLogin: true, forceShowLogo: true),
      body: SizedBox.expand(
        child: UniSystemBackgroundDecoration(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outlined, size: 64),
              const SizedBox(height: 16),
              Text(context.localizations.verboseError),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  return ref.read(userRoleRedirectionProvider.call(await ref.read(loginServiceProvider.future)));
                },
                child: Text(context.localizations.navDestHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
