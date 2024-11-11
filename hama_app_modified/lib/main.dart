import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



//importing pages
import 'package:hama_app/pages/register.dart';
import 'package:hama_app/pages/login.dart';
import 'package:hama_app/pages/dashboard.dart';
import 'package:hama_app/pages/search.dart';
import 'package:hama_app/pages/landing.dart';
import 'package:hama_app/pages/add_property.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);


  runApp(const HamaApp()); // Fixed class name
}

class HamaApp extends StatelessWidget {
  const HamaApp({super.key}); // Fixed constructor name
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hama Fast',
      theme: ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.teal,
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 10,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
     themeMode: ThemeMode.system,
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/register':(context) => const RegisterPage(),
        '/dashboard':(context) => const DashboardPage(),
        '/buy': (context) => const SearchPage(),
        '/sell': (context) =>  const AddPropertyPage(),
        '/login':(context) => const LoginPage(),
      },      
    );
  }
}
