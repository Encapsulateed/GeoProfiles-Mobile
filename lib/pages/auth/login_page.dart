import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _storage = const FlutterSecureStorage();

  bool _loading = false;
  bool _obscurePassword = true;

  // -------------------- init --------------------
  @override
  void initState() {
    super.initState();
    _prefillEmail();
  }

  Future<void> _prefillEmail() async {
    final savedMail = await _storage.read(key: 'last_email');
    if (savedMail != null) _emailCtrl.text = savedMail;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // -------------------- utils --------------------
  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
  );

  Widget _textField({
    required String label,
    required TextEditingController controller,
    bool isPassword = false,
    bool? obscure,
    VoidCallback? toggleObscure,
    required String? Function(String?) validator,
  }) => TextFormField(
    controller: controller,
    decoration: _decoration(label).copyWith(
      suffixIcon: isPassword
          ? IconButton(
        icon: Icon((obscure ?? false)
            ? Icons.visibility_off_rounded
            : Icons.visibility_rounded),
        onPressed: toggleObscure,
      )
          : null,
    ),
    keyboardType: label == 'Email'
        ? TextInputType.emailAddress
        : TextInputType.text,
    obscureText: obscure ?? false,
    validator: validator,
  );

  // -------------------- action --------------------
  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final hashed = _hashPassword(_passwordCtrl.text);

    try {
      final api = context.read<ApiService>();
      final TokenDto tokens = await api
          .login(
        username: _emailCtrl.text.trim(), // бек требует username+email, кидаем одинаковое
        email: _emailCtrl.text.trim(),
        passwordHash: hashed,
      )
          .timeout(const Duration(seconds: 10));

      await _storage.write(key: 'jwt_token', value: tokens.token);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
      await _storage.write(key: 'last_email', value: _emailCtrl.text.trim());

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/projects');
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сервер не ответил вовремя, попробуйте ещё раз.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при входе: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // -------------------- ui --------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'GeoResearch',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _textField(
                          label: 'Email',
                          controller: _emailCtrl,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Введите email';
                            final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            return re.hasMatch(v) ? null : 'Неверный формат';
                          },
                        ),
                        const SizedBox(height: 24),
                        _textField(
                          label: 'Password',
                          controller: _passwordCtrl,
                          isPassword: true,
                          obscure: _obscurePassword,
                          toggleObscure: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                          validator: (v) => (v != null && v.length >= 6)
                              ? null
                              : 'Минимум 6 символов',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _loading ? null : _onLogin,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2979FF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.6,
                                color: Colors.white,
                              ),
                            )
                                : const Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushReplacementNamed('/register'),
                          child: const Text(
                            'Registration',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2979FF),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
