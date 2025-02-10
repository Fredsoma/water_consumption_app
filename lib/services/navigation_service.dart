import 'package:flutter/material.dart';
import 'package:water_consumption_app/screens/home_screen.dart';
import 'package:water_consumption_app/screens/login_screen.dart';
import 'package:water_consumption_app/screens/register_screen.dart';


class NavigationService {

  late GlobalKey<NavigatorState> _navigatorKey;

  final Map<String, Widget Function(BuildContext)> _routes = {
    "/login": (context) => LoginScreen(),
    "/register": (context) => RegisterScreen(),
    "/home": (context) => HomeScreen(),
  };

  GlobalKey<NavigatorState>? get navigatorKey {
    return _navigatorKey;
  }

  Map<String, Widget Function(BuildContext)> get routes {
    return _routes;
  }

  NavigationService() {
    _navigatorKey = GlobalKey<NavigatorState>();
  }

  void pushedNamed(String routeName) {
    _navigatorKey.currentState?.pushNamed(routeName);
  }

   void pushReplacementNamed(String routeName) {
    _navigatorKey.currentState?.pushReplacementNamed(routeName);
  }

  void goback() {
    _navigatorKey.currentState?.pop();
  }
}