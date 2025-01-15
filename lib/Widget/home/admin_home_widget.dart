import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Router/route_extra/admin_add_user_widget_extra.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/button_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';

class AdminHomeWidget extends ConsumerStatefulWidget {
  const AdminHomeWidget({super.key});

  @override
  ConsumerState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<AdminHomeWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBarAndroid(),
      body: UniSystemBackgroundDecoration(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedTextTitle(text: context.localizations.upperCaseHomeTitleAndUserName('ADMIN')),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.localizations.homeQuickAccess, style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 18),
                        QuickAccessIconButton(
                          text: context.localizations.adminQuickAccessAddStudent,
                          icon: const BigIconWithCompanion(mainIcon: Icons.person, companionIcon: Icons.plus_one),
                          onPressed: () {
                            context.goDetailPage(
                              GoRouterRoutes.adminAddUser,
                              AdminAddUserWidgetExtra(selectedUserType: <UserRole>{UserRole.student}),
                            );
                          },
                        ),
                        const SizedBox(height: 18),
                        QuickAccessIconButton(
                          text: context.localizations.adminQuickAccessAddTeacher,
                          icon: const BigIconWithCompanion(mainIcon: Icons.school, companionIcon: Icons.plus_one),
                          onPressed: () {
                            context.goDetailPage(
                              GoRouterRoutes.adminAddUser,
                              AdminAddUserWidgetExtra(selectedUserType: <UserRole>{UserRole.teacher}),
                            );
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
