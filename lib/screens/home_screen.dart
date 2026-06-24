
import 'package:flutter/material.dart';
import 'package:login_app/theme/app_theme.dart';

class HomeScreen extends StatefulWidget{

  final String username;
  const HomeScreen({required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.bgInput,
      ),
    );
  }
}