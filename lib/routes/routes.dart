import 'package:flutter/material.dart';
import 'package:kiddo_tracker/pages/addchildroute.dart';
import 'package:kiddo_tracker/pages/loginscreen.dart';
import 'package:kiddo_tracker/pages/mainscreen.dart';
import 'package:kiddo_tracker/pages/otpscreen.dart';
import 'package:kiddo_tracker/pages/signupscreen.dart';
import 'package:kiddo_tracker/pages/subscriptionscreen.dart';

class AppRoutes {
  static const String login = '/';
  static const String otp = '/otp';
  static const String signup = '/signup';
  static const String main = '/main';
  static const String subscribe = '/subscribe';
  static const String addRoute = '/addroute';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        final mobileNumber = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => OTPScreen(mobile: mobileNumber),
        );
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case subscribe:
        return MaterialPageRoute(builder: (_) => const SubscriptionScreen());
      case addRoute:
        final childName = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => AddChildRoutePage(nickName: childName),
        );
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
      otp: (context) => OTPScreen(),
      signup: (context) => const SignUpScreen(),
      main: (context) => const MainScreen(),
      subscribe: (context) => const SubscriptionScreen(),
      addRoute: (context) => AddChildRoutePage(),
    };
  }
}
