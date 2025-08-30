import 'package:flutter/material.dart';
import 'package:kiddo_tracker/pages/loginscreen.dart';
import 'package:kiddo_tracker/pages/mainscreen.dart';
import 'package:kiddo_tracker/pages/otpscreen.dart';
import 'package:kiddo_tracker/pages/signupscreen.dart';

class AppRoutes {
  static const String login = '/';
  static const String otp = '/otp';
  static const String signup = '/signup';
  static const String main = '/main';
  // static const String home = '/home';
  // static const String child = '/child';
  // static const String setting = '/settings';
  // static const String activities = '/activities';
  // static const String alerts = '/alerts';

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
      // case home:
      //   return MaterialPageRoute(builder: (_) => const HomeScreen());
      // case child:
      //   return MaterialPageRoute(builder: (_) => const AddChildScreen());
      // case activities:
      //   return MaterialPageRoute(builder: (_) => const ActivityScreen());
      // case setting:
      //   return MaterialPageRoute(builder: (_) => const SettingScreen());
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
      // home: (context) => const HomeScreen(),
      // child: (context) => const AddChildScreen(),
      // activities: (context) => const ActivityScreen(),
      // setting: (context) => const SettingScreen(),
    };
  }
}
