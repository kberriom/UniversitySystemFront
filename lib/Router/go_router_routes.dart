enum GoRouterRoutes {
  ///Regular login screen without animations intended for token expired redirections
  login(routeName: '/'),
  ///Login with hero animation for cold start
  animatedLogin(routeName: '/login'),
  ///Widget that recreates the Android 12 splash screen
  loginSplash(routeName: '/loginSplash'),
  tokenExpiredInfo(routeName: '/sessionExpired'),
  home(routeName: '/home');

  final String routeName;

  const GoRouterRoutes({required this.routeName});
}
