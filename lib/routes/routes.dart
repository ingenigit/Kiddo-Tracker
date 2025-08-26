import 'package:flutter/material.dart';
import 'package:kiddo_tracker/pages/loginscreen.dart';

class AppRoutes {
  static const String login = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginScreen(),
    };
  }
}
