import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:university_system_front/Router/route_extra/admin_add_user_widget_extra.dart';
import 'package:university_system_front/Router/uni_system_router_tools.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:university_system_front/Util/platform_utils.dart';
import 'package:university_system_front/Router/go_router_routes.dart';
import 'package:university_system_front/Model/curriculum.dart';
import 'package:university_system_front/Model/subject.dart';
import 'package:university_system_front/Model/users/student.dart';
import 'package:university_system_front/Model/users/teacher.dart';
import 'package:university_system_front/Widget/users/admin/admin_add_user.dart';
import 'package:university_system_front/Widget/users/admin/student/admin_edit_student_widget.dart';
import 'package:university_system_front/Widget/users/admin/student/admin_student_detail_widget.dart';
import 'package:university_system_front/Widget/users/admin/teacher/admin_edit_teacher_widget.dart';
import 'package:university_system_front/Widget/users/admin/teacher/admin_teacher_detail_widget.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_add_curriculum_widget.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_curriculum_detail.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_curriculums_widget.dart';
import 'package:university_system_front/Widget/curriculums/admin/admin_edit_curriculum_widget.dart';
import 'package:university_system_front/Widget/home/admin/admin_home_widget.dart';
import 'package:university_system_front/Widget/navigation/base_scaffold_navigation/admin_scaffold_navigation_widget.dart';
import 'package:university_system_front/Widget/navigation/leading_widgets.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_add_subject_widget.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_edit_subject_widget.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_subject_detail.dart';
import 'package:university_system_front/Widget/subjects/admin/admin_subjects_widget.dart';
import 'package:university_system_front/Widget/users/admin/admin_users_widget.dart';

///Models must have its json mapper initialized for Router state restoration
void _initAdminMappers() {
  CurriculumMapper.ensureInitialized();
  SubjectMapper.ensureInitialized();
  StudentMapper.ensureInitialized();
  TeacherMapper.ensureInitialized();
  AdminAddUserWidgetExtraMapper.ensureInitialized();
}

StatefulShellRoute getAdminRouteTree(Ref ref) {
  _initAdminMappers();
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return AdminScaffoldNavigationWidget(navigationShell: navigationShell);
    },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(routes: [
        GoRoute(
          path: GoRouterRoutes.adminHome.routeName,
          name: GoRouterRoutes.adminHome.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
            key: ValueKey(GoRouterRoutes.adminHome.routeName),
            child: const AdminHomeWidget(),
          ),
        ),
      ]),
      _userStatefulShellBranch(ref),
      _subjectStatefulShellBranch(ref),
      _curriculumStatefulShellBranch(ref),
    ],
  );
}

StatefulShellBranch _userStatefulShellBranch(Ref ref) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
          path: GoRouterRoutes.adminUsers.routeName,
          name: GoRouterRoutes.adminUsers.routeName,
          pageBuilder: (context, state) => NoTransitionPage(
                key: ValueKey(GoRouterRoutes.adminUsers.routeName),
                child: const AdminUsersWidget(),
              ),
          routes: <GoRoute>[
            buildRootChildRouteWithExtra<AdminAddUserWidgetExtra>(
              ref: ref,
              route: GoRouterRoutes.adminAddUser,
              widgetBuilder: (extra) => AdminAddUser(key: ValueKey(extra), extra: extra),
              routes: [],
            ),
            buildRootChildRouteWithExtra<Student>(
              ref: ref,
              route: GoRouterRoutes.adminStudentDetail,
              widgetBuilder: (item) => AdminStudentDetailWidget(student: item),
              routes: [
                buildCloseButtonChildSubRoute<Student>(
                  ref: ref,
                  childSubRoute: GoRouterRoutes.adminEditStudent,
                  widgetBuilder: (item) => AdminEditStudentWidget(student: item),
                  parentSubRoute: GoRouterRoutes.adminStudentDetail,
                ),
              ],
            ),
            buildRootChildRouteWithExtra<Teacher>(
              ref: ref,
              route: GoRouterRoutes.adminTeacherDetail,
              widgetBuilder: (item) => AdminTeacherDetailWidget(teacher: item),
              routes: [
                buildCloseButtonChildSubRoute<Teacher>(
                  ref: ref,
                  childSubRoute: GoRouterRoutes.adminEditTeacher,
                  widgetBuilder: (item) => AdminEditTeacherWidget(teacher: item),
                  parentSubRoute: GoRouterRoutes.adminTeacherDetail,
                ),
              ],
            ),
          ]),
    ],
  );
}

StatefulShellBranch _subjectStatefulShellBranch(Ref ref) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: GoRouterRoutes.adminSubjects.routeName,
        name: GoRouterRoutes.adminSubjects.routeName,
        pageBuilder: (context, state) =>
            NoTransitionPage(key: ValueKey(GoRouterRoutes.adminSubjects.routeName), child: const AdminSubjectsWidget()),
        routes: [
          GoRoute(
            path: GoRouterRoutes.adminAddSubject.routeName,
            name: GoRouterRoutes.adminAddSubject.routeName,
            onExit: (context, state) {
              if (PlatformUtil.isWindows) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
              }
              return true;
            },
            pageBuilder: (context, state) {
              return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, const AddSubjectWidget()));
            },
          ),
          GoRoute(
            path: GoRouterRoutes.adminSubjectDetail.routeName,
            name: GoRouterRoutes.adminSubjectDetail.routeName,
            onExit: (context, state) {
              if (PlatformUtil.isWindows) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
              }
              return true;
            },
            pageBuilder: (context, state) {
              assert(state.extra != null);
              Subject subject = getExtra<Subject>(state, errorMsg: "invalid extra arg in adminSubjectDetail");
              return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, AdminSubjectDetailWidget(subject: subject)));
            },
            routes: <GoRoute>[
              GoRoute(
                path: GoRouterRoutes.adminEditSubject.routeName,
                name: GoRouterRoutes.adminEditSubject.routeName,
                onExit: (context, state) {
                  if (PlatformUtil.isWindows) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
                    VisibilityDetectorController.instance.notifyNow();
                  }
                  return true;
                },
                pageBuilder: (context, state) {
                  assert(state.extra != null);
                  Subject subject = getExtra<Subject>(state, errorMsg: "invalid extra arg in adminEditSubject");
                  return NoTransitionPage(
                    child: setLeadingOnWindows(
                      leading: UniSystemCloseButton(
                        route: '${GoRouterRoutes.adminSubjects.routeName}/${GoRouterRoutes.adminSubjectDetail.routeName}',
                        extra: subject,
                      ),
                      state.pageKey,
                      AdminEditSubjectWidget(subject: subject),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

StatefulShellBranch _curriculumStatefulShellBranch(Ref ref) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: GoRouterRoutes.adminCurriculums.routeName,
        name: GoRouterRoutes.adminCurriculums.routeName,
        pageBuilder: (context, state) => NoTransitionPage(
          key: ValueKey(GoRouterRoutes.adminCurriculums.routeName),
          child: const AdminCurriculumsWidget(),
        ),
        routes: [
          GoRoute(
            path: GoRouterRoutes.adminAddCurriculum.routeName,
            name: GoRouterRoutes.adminAddCurriculum.routeName,
            onExit: (context, state) {
              if (PlatformUtil.isWindows) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
              }
              return true;
            },
            pageBuilder: (context, state) {
              return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, const AdminAddCurriculumWidget()));
            },
          ),
          GoRoute(
            path: GoRouterRoutes.adminCurriculumDetail.routeName,
            name: GoRouterRoutes.adminCurriculumDetail.routeName,
            onExit: (context, state) {
              if (PlatformUtil.isWindows) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
              }
              return true;
            },
            pageBuilder: (context, state) {
              assert(state.extra != null);
              Curriculum curriculum = getExtra<Curriculum>(state, errorMsg: "invalid extra arg in adminCurriculumDetail");
              return NoTransitionPage(child: setLeadingOnWindows(state.pageKey, AdminCurriculumDetail(curriculum: curriculum)));
            },
            routes: <GoRoute>[
              GoRoute(
                path: GoRouterRoutes.adminEditCurriculum.routeName,
                name: GoRouterRoutes.adminEditCurriculum.routeName,
                onExit: (context, state) {
                  if (PlatformUtil.isWindows) {
                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => ref.invalidate(uniSystemAppBarLeadingProvider));
                    VisibilityDetectorController.instance.notifyNow();
                  }
                  return true;
                },
                pageBuilder: (context, state) {
                  assert(state.extra != null);
                  Curriculum curriculum = getExtra<Curriculum>(state, errorMsg: "invalid extra arg in adminEditCurriculum");
                  return NoTransitionPage(
                    child: setLeadingOnWindows(
                      leading: UniSystemCloseButton(
                        route: '${GoRouterRoutes.adminCurriculums.routeName}/${GoRouterRoutes.adminCurriculumDetail.routeName}',
                        extra: curriculum,
                      ),
                      state.pageKey,
                      AdminEditCurriculumWidget(curriculum: curriculum),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
