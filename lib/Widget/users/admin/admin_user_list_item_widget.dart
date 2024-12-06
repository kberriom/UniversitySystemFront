import 'package:flutter/material.dart';
import 'package:university_system_front/Model/credentials/bearer_token.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Model/users/user.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/animated_text_overflow.dart';
import 'package:university_system_front/Widget/common_components/infinite_list_widgets.dart';
import 'package:university_system_front/Widget/users/admin/admin_user_list_widget.dart';

class UserListItem extends StatelessWidget {
  const UserListItem({
    super.key,
    required this.data,
    required this.itemConstraints,
    this.userSelectionCallback,
  });

  final User data;
  final UserSelectionCallback? userSelectionCallback;
  final FixedExtentItemConstraints itemConstraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey<int>(data.id),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(
              minWidth: itemConstraints.cardMinWidthConstraints,
              maxWidth: itemConstraints.cardMaxWidthConstraints,
              minHeight: itemConstraints.cardHeight,
              maxHeight: itemConstraints.cardHeight),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadiusSmall)),
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            onPressed: () {
              final UserRole role = switch (data) {
                Student() => UserRole.student,
                Teacher() => UserRole.teacher,
                User() => throw UnimplementedError(),
              };
              if (userSelectionCallback != null) {
                switch (role) {
                  case UserRole.admin:
                    throw UnimplementedError();
                  case UserRole.student || UserRole.teacher:
                    userSelectionCallback!(data, role);
                }
              } else {
                switch (role) {
                  case UserRole.student:
                    context.goDetailPage(GoRouterRoutes.adminStudentDetail, data);
                  case UserRole.teacher:
                    context.goDetailPage(GoRouterRoutes.adminTeacherDetail, data);
                  case _:
                    throw UnimplementedError();
                }
              }
            },
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: AnimatedTextOverFlow(
                          child: Text(
                            "${data.name} ${data.lastName}",
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            Tooltip(message: context.localizations.idTooltip, child: const Icon(Icons.badge_outlined)),
                            Text(" ${data.id}", overflow: TextOverflow.ellipsis),
                            const SizedBox(width: 5),
                            Tooltip(message: context.localizations.usernameTooltip, child: const Icon(Icons.account_circle)),
                            Flexible(
                              child: AnimatedTextOverFlow(
                                child: Text(
                                  " ${data.username}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (data.role == UserRole.student.roleName) ...[
                      const Icon(Icons.school),
                      Text(context.localizations.userTypeNameStudent(1)),
                    ],
                    if (data.role == UserRole.teacher.roleName) ...[
                      const Icon(Icons.hail),
                      Text(context.localizations.userTypeNameTeacher(1)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
