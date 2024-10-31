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
  adminStudentDetail(routeName: 'studentDetail', userRole: UserRole.admin, parent: GoRouterRoutes.adminUsers),
  adminTeacherDetail(routeName: 'teacherDetail', userRole: UserRole.admin, parent: GoRouterRoutes.adminUsers),
  adminAddUser(routeName: 'addUser', userRole: UserRole.admin, parent: GoRouterRoutes.adminUsers),
  adminEditStudent(routeName: 'editStudent', userRole: UserRole.admin, parent: GoRouterRoutes.adminStudentDetail),
  adminEditTeacher(routeName: 'editTeacher', userRole: UserRole.admin, parent: GoRouterRoutes.adminTeacherDetail),
  //Admin subjects subtree
  adminSubjects(routeName: '/adminSubjects', userRole: UserRole.admin),
  adminSubjectDetail(routeName: 'subjectDetail', userRole: UserRole.admin, parent: GoRouterRoutes.adminSubjects),
  adminAddSubject(routeName: 'addSubject', userRole: UserRole.admin, parent: GoRouterRoutes.adminSubjects),
  adminEditSubject(routeName: 'editSubject', userRole: UserRole.admin, parent: GoRouterRoutes.adminSubjectDetail),
  //Admin curriculums subtree
  adminCurriculums(routeName: '/adminCurriculums', userRole: UserRole.admin),
  adminCurriculumDetail(routeName: 'curriculumDetail', userRole: UserRole.admin, parent: GoRouterRoutes.adminCurriculums),
  adminAddCurriculum(routeName: 'addCurriculum', userRole: UserRole.admin, parent: GoRouterRoutes.adminCurriculums),
  adminEditCurriculum(routeName: 'editCurriculum', userRole: UserRole.admin, parent: GoRouterRoutes.adminCurriculumDetail),

  ///Start of the teacher navigation subtree
  teacherHome(routeName: '/teacherHome', userRole: UserRole.teacher),

  ///Start of the student navigation subtree
  studentHome(routeName: '/studentHome', userRole: UserRole.student),
  ;

  final String routeName;
  final UserRole? userRole;

  ///routes with a parent cannot have "/" in route name
  final GoRouterRoutes? parent;

  const GoRouterRoutes({required this.routeName, required this.userRole, this.parent});
}
