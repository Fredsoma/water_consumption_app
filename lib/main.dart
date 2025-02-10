import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:water_consumption_app/screens/login_screen.dart';
import 'package:water_consumption_app/screens/home_screen.dart';
import 'package:water_consumption_app/services/auth_service.dart';
import 'package:water_consumption_app/services/navigation_service.dart';
import 'package:water_consumption_app/services/water_service.dart'; // Import WaterService
import 'package:water_consumption_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}

Future<void> registerServices() async {
  final getIt = GetIt.instance;

  // Register Firestore instance (FirebaseFirestore)
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Register NavigationService
  getIt.registerLazySingleton<NavigationService>(() => NavigationService());

  // Register AuthService
  getIt.registerLazySingleton<AuthService>(() => AuthService());

  // Register WaterService with FirebaseFirestore dependency
  getIt.registerLazySingleton<WaterService>(() => WaterService(firestore: firestore));

  // Add other services as necessary
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;

  late NavigationService _navigationService;
  late AuthService _authService;

  MyApp({super.key}) {
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.montserratTextTheme(),
      ),
      initialRoute: _authService.user != null ? "/home" : "/login", // Adjust initial route based on auth state
      routes: _navigationService.routes,
    );
  }
}
