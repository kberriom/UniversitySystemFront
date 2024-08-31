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
  ///Admin users subtree
  adminUsers(routeName: '/adminUsers', userRole: UserRole.admin),
  ///Admin subjects subtree
  adminSubjects(routeName: '/adminSubjects', userRole: UserRole.admin),
  adminAddSubject(routeName: 'addSubject', userRole: UserRole.admin, isSubRoute: true),
  ///Admin curriculums subtree
  adminCurriculums(routeName: '/adminCurriculums', userRole: UserRole.admin),

  ///Start of the teacher navigation subtree
  teacherHome(routeName: '/teacherHome', userRole: UserRole.teacher),

  ///Start of the student navigation subtree
  studentHome(routeName: '/studentHome', userRole: UserRole.student),
  ;

  final String routeName;
  final UserRole? userRole;
  ///SubRoutes cannot have "/" in route name
  final bool isSubRoute;

  const GoRouterRoutes({required this.routeName, required this.userRole, this.isSubRoute = false});
}
