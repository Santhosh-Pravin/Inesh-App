import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _onLogin() {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please fill all fields')));
      return;
    }
    final username = _userCtrl.text.trim();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => HomeScreen(username: username)));
    _userCtrl.clear(); _passCtrl.clear();
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.brand, width: 2)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBase,
      body: SingleChildScrollView(
        child: Column(
          children: [
        
            SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(child: Container(color: AppColors.brandDark)),
                  Positioned(
                    right: 0, bottom: 0,
                    child: ClipPath(
                      clipper: _DiagonalClipper(),
                      child: Container(width: 220, height: 280,
                          color: AppColors.brand),
                    ),
                  ),
                  Positioned(
                    right: 0, top: 0,
                    child: ClipPath(
                      clipper: _SmallDiagonalClipper(),
                      child: Container(width: 160, height: 160,
                          color: AppColors.brandLight),
                    ),
                  ),
                  Positioned(
                    bottom: 30, left: 20,
                    child: ClipOval(
                      child: Image.asset('assets/images/inesh_logo.png',
                          width: 75, height: 75, fit: BoxFit.cover),
                    ),
                  ),
                  const Positioned(
                    bottom: 40, left: 120,
                    child: Text('Login',
                        style: TextStyle(color: Colors.white, fontSize: 36,
                            fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome Back',
                      style: TextStyle(color: AppColors.textPrimary,
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Sign in to continue',
                      style: TextStyle(color: AppColors.textSecondary,
                          fontSize: 14)),
                  const SizedBox(height: 32),

                  TextField(
                    controller: _userCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dec('Username', Icons.person_outline),
                  ),
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: _dec('Password', Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                            color: AppColors.textSecondary),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('Forgot Password?',
                          style: TextStyle(color: AppColors.brand)),
                    ),
                  ),
                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity, height: 52,
                    child: ElevatedButton(
                      onPressed: _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brand,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('LOGIN',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width * 0.45, 0)..lineTo(s.width, 0)
    ..lineTo(s.width, s.height)..lineTo(0, s.height)..close();
  @override bool shouldReclip(_) => false;
}

class _SmallDiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..moveTo(s.width * 0.3, 0)..lineTo(s.width, 0)
    ..lineTo(s.width, s.height * 0.7)..close();
  @override bool shouldReclip(_) => false;
}