import 'dart:developer';

import 'package:aquatracking/globals.dart';
import 'package:aquatracking/screen/home_screen.dart';
import 'package:aquatracking/screen/login_screen.dart';
import 'package:aquatracking/service/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

initSharedPreferences() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  String? refreshToken = prefs.getString('refresh_token');

  if(refreshToken != null) {
    AuthenticationService authenticationService = AuthenticationService();
    AuthenticationService.loggedIn = await authenticationService.checkLogin(refreshToken);
  }
}

void main() async {
  await initSharedPreferences();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      title: 'AquaTracking',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale("en"),
        Locale("fr"),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFFFFFFF),
        highlightColor: const Color(0xFF2ec1e2),
        backgroundColor: const Color(0xFF161616),

        fontFamily: 'Roboto'
      ),
      home: (AuthenticationService.loggedIn) ? const HomeScreen() : const LoginScreen(),
    );
  }
}
