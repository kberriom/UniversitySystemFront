import 'package:flutter/material.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/users/admin/admin_user_detail.dart';

class AdminStudentDetailWidget extends StatefulWidget {
  final Student student;

  const AdminStudentDetailWidget({
    super.key,
    required this.student,
  });

  @override
  State<AdminStudentDetailWidget> createState() => _AdminStudentDetailWidgetState();
}

class _AdminStudentDetailWidgetState extends State<AdminStudentDetailWidget> {
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
              context.goEditPage(GoRouterRoutes.adminEditStudent, widget.student);
            },
            child: const Icon(Icons.mode_edit)),
        body: UniSystemBackgroundDecoration(
          child: AdminUserDetail(
            user: widget.student,
            headerTitle: context.localizations.studentItemName,
          ),
        ),
      ),
    );
  }
}
