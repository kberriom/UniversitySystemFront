import 'package:flutter/material.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/users/admin/admin_user_detail.dart';

class AdminTeacherDetailWidget extends StatefulWidget {
  final Teacher teacher;

  const AdminTeacherDetailWidget({
    super.key,
    required this.teacher,
  });

  @override
  State<AdminTeacherDetailWidget> createState() => _AdminTeacherDetailWidgetState();
}

class _AdminTeacherDetailWidgetState extends State<AdminTeacherDetailWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: getAppBarAndroid(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.goEditPage(GoRouterRoutes.adminEditTeacher, widget.teacher);
            },
            child: const Icon(Icons.mode_edit)),
        body: UniSystemBackgroundDecoration(
          child: AdminUserDetail(
            user: widget.teacher,
            headerTitle: context.localizations.teacherItemName,
            underlineBannerWidgets: [
              Tooltip(
                message: context.localizations.adminTeacherDetailDepartmentTooltip,
                child: const Icon(Icons.account_balance_outlined),
              ),
              Text(widget.teacher.department),
            ],
          ),
        ),
      ),
    );
  }
}
