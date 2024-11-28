import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:university_system_front/Controller/users/admin_student_detail_controller.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Theme/dimensions.dart';
import 'package:university_system_front/Util/localization_utils.dart';
import 'package:university_system_front/Util/router_utils.dart';
import 'package:university_system_front/Widget/common_components/background_decoration_widget.dart';
import 'package:university_system_front/Widget/common_components/loading_widgets.dart';
import 'package:university_system_front/Widget/common_components/title_widgets.dart';
import 'package:university_system_front/Widget/navigation/uni_system_appbars.dart';
import 'package:university_system_front/Widget/subjects/subject_for_result_widget.dart';
import 'package:university_system_front/Widget/users/admin/admin_user_detail.dart';

class AdminStudentDetailWidget extends ConsumerStatefulWidget {
  final Student student;

  const AdminStudentDetailWidget({
    super.key,
    required this.student,
  });

  @override
  ConsumerState<AdminStudentDetailWidget> createState() => _AdminStudentDetailWidgetState();
}

class _AdminStudentDetailWidgetState extends ConsumerState<AdminStudentDetailWidget> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    final subjectListFuture = ref.watch(subjectListByStudentIdProvider.call(widget.student.id).future);
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
          child: Column(
            children: [
              AdminUserDetail(
                user: widget.student,
                headerTitle: context.localizations.studentItemName,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: kBodyHorizontalPadding, vertical: 8),
                width: double.infinity,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Row(
                  children: [
                    AnimatedRefreshButton(onPressed: () {
                      return ref.refresh(subjectListByStudentIdProvider.call(widget.student.id).future);
                    }),
                    const SizedBox(width: 8),
                    Text(
                      context.localizations.registeredSubjectsForUser,
                      style: downTextStyle.copyWith(fontSize: 24),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              Expanded(
                child: SubjectForResultWidget(
                  key: ObjectKey(subjectListFuture),
                  listCallback: () {
                    return subjectListFuture;
                  },
                  onResultCallback: (subject) {
                    context.goDetailPage(GoRouterRoutes.adminSubjectDetail, subject);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
