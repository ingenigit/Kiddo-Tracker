import 'package:flutter/material.dart';
import 'package:kiddo_tracker/routes/routes.dart';
import 'package:kiddo_tracker/services/children_provider.dart';
import 'package:kiddo_tracker/services/notification_service.dart';
import 'package:kiddo_tracker/widget/shareperference.dart';
import 'package:kiddo_tracker/pages/mainscreen.dart';
import 'package:kiddo_tracker/pages/loginscreen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize notifications
  await NotificationService.initialize();
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChildrenProvider())],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late Future<bool?> _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = SharedPreferenceHelper.getUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Roboto'),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
      home: FutureBuilder<bool?>(
        future: _isLoggedIn,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasData && snapshot.data == true) {
            return const MainScreen(); // User is logged in
          } else {
            return const LoginScreen(); // User is not logged in
          }
        },
      ),
    );
  }
}
