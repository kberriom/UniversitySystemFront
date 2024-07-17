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
  adminUsers(routeName: '/adminUsers', userRole: UserRole.admin),
  teacherHome(routeName: '/teacherHome', userRole: UserRole.teacher),
  studentHome(routeName: '/studentHome', userRole: UserRole.student),
  ;

  final String routeName;
  final UserRole? userRole;

  const GoRouterRoutes({required this.routeName, required this.userRole});
}
