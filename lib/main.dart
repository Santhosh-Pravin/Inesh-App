import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'screens/login_screen.dart';
import 'theme/app_theme.dart';
void main(){
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inesh Smart Energy',
      theme: AppTheme.dark,
      //home: const LoginScreen(),
    );
  }
}