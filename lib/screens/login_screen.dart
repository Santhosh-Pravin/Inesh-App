import 'package:flutter/material.dart';
//import 'home_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onLogin(){
    if(_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content : Text("Please fill all the fields")));
      return;
    }
    final username = _userCtrl.text.trim();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(username : username)) 
    );
    _userCtrl.clear();
    _passCtrl.clear();
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}){
    InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary,),
      suffixIcon: suffix,
      filled: true,
      fillColor: AppColors.bgInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border)
      ),  
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.brand, width: 2),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}