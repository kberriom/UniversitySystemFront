import 'package:university_system_front/Model/credentials/bearer_token.dart';

enum GoRouterRoutes {
  ///Login screen without animations, used for token expired redirections
  login(routeName: '/', userRole: null),

  ///Login with hero animation
  animatedLogin(routeName: '/login', userRole: null),

  ///Widget that recreates the Android 12 splash screen, and is the entrypoint of auth
  loginSplash(routeName: '/loginSplash', userRole: null),

  ///Widget to indicate the expiration of the login token and redirection to [login]
  tokenExpiredInfo(routeName: '/sessionExpired', userRole: null),

  ///Start of the admin navigation subtree
  adminHome(routeName: '/adminHome', userRole: UserRole.admin),
  //Admin users subtree
  adminUsers(routeName: '/adminUsers', userRole: UserRole.admin),
  //Admin subjects subtree
  adminSubjects(routeName: '/adminSubjects', userRole: UserRole.admin),
  adminSubjectDetail(routeName: 'subjectDetail', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminSubjects),
  adminAddSubject(routeName: 'addSubject', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminSubjects),
  adminEditSubject(routeName: 'editSubject', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminSubjectDetail),
  //Admin curriculums subtree
  adminCurriculums(routeName: '/adminCurriculums', userRole: UserRole.admin),
  adminCurriculumDetail(routeName: 'curriculumDetail', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminCurriculums),
  adminAddCurriculum(routeName: 'addCurriculum', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminCurriculums),
  adminEditCurriculum(routeName: 'editCurriculum', userRole: UserRole.admin, isSubRoute: true, parent: GoRouterRoutes.adminCurriculumDetail),

  ///Start of the teacher navigation subtree
  teacherHome(routeName: '/teacherHome', userRole: UserRole.teacher),

  ///Start of the student navigation subtree
  studentHome(routeName: '/studentHome', userRole: UserRole.student),
  ;

  final String routeName;
  final UserRole? userRole;
  final GoRouterRoutes? parent;

  ///SubRoutes cannot have "/" in route name
  final bool isSubRoute;

  const GoRouterRoutes({required this.routeName, required this.userRole, this.isSubRoute = false, this.parent});
}
