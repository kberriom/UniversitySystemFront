enum GoRouterRoutes {
  login(routeName: '/'),
  home(routeName: '/home'),
  tokenExpiredInfo(routeName: '/sessionExpired');

  final String routeName;

  const GoRouterRoutes({required this.routeName});
}
