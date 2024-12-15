import 'package:bibliora/screens/profile_screen.dart';
import 'package:bibliora/service/config_manager.dart';
import 'package:bibliora/service/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigManager.loadConfig();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Bibliora',
      routes: {
        "/profile": (context) => ProfileScreen(),
      },
      home: HomeScreen(),
    );
  }
}
