import 'package:chat_app_socket_flutter/screens/dashboard.dart';
import 'package:chat_app_socket_flutter/screens/register_page.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Preferences.dart';
import 'package:chat_app_socket_flutter/services/SharedServices/Sharedservices.dart';
import 'package:chat_app_socket_flutter/services/provider/provider_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  preferences = await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ProviderServices(),
        )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: SharedServices.isLoggedIn() ? const Dashboard() : RegisterPage(),
      ),
    );
  }
}
