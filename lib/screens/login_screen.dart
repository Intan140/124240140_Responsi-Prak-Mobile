import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _isRegister = false, _hide = true, _busy = false;

  void _msg(String t, Color c) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(t), backgroundColor: c));

  Future<void> _submit() async {
    final u = _user.text.trim(), p = _pass.text;
    if (u.isEmpty || p.isEmpty) {
      _msg('Username dan password wajib diisi', Colors.red);
      return;
    }
    setState(() => _busy = true);
    if (_isRegister) {
      final ok = await DB.register(u, p);
      if (!mounted) return;
      setState(() => _busy = false);
      if (ok) {
        _msg('Registrasi berhasil, silakan login', Colors.green);
        setState(() => _isRegister = false);
      } else {
        _msg('Username sudah digunakan', Colors.red);
      }
      return;
    }
    final ok = await DB.login(u, p);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!ok) {
      _msg('Username atau password salah', Colors.red);
      return;
    }
    await DB.setSession(u);
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen(username: u)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: 300,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.brown, AppColors.brownLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
            ),
            child: SafeArea(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: const BoxDecoration(
                      color: AppColors.cream, shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_bag_rounded,
                      size: 48, color: AppColors.brown),
                ),
                const SizedBox(height: 14),
                const Text('ShoppingHub',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Belanja jadi lebih mudah',
                    style: TextStyle(color: AppColors.cream)),
              ]),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.brown.withAlpha(46),
                        blurRadius: 24,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_isRegister ? 'Buat Akun' : 'Selamat Datang',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown)),
                  const SizedBox(height: 4),
                  Text(
                      _isRegister
                          ? 'Daftar untuk mulai menyimpan wishlist'
                          : 'Masuk untuk melanjutkan belanja',
                      style: const TextStyle(color: AppColors.brownLight)),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _user,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      fillColor: AppColors.cream.withAlpha(128),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      fillColor: AppColors.cream.withAlpha(128),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : Text(_isRegister ? 'Daftar' : 'Login',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _isRegister = !_isRegister),
                      child: Text(
                          _isRegister
                              ? 'Sudah punya akun? Login'
                              : 'Belum punya akun? Daftar',
                          style: const TextStyle(color: AppColors.brown)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}