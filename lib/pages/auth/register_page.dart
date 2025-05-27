import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

import '../../api/api.swagger.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _storage = const FlutterSecureStorage();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // -------------------- utils --------------------
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString(); // алгоритм не критичен
  }

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
  }) =>
      TextFormField(
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
        keyboardType:
            label == 'Email' ? TextInputType.emailAddress : TextInputType.text,
        obscureText: obscure ?? false,
        validator: validator,
      );

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final hashedPwd = _hashPassword(_passwordCtrl.text);

    try {
      final api = context.read<ApiService>();

      await api
          .register(
            username: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            passwordHash: hashedPwd,
          )
          .timeout(const Duration(seconds: 5));

      final TokenDto tokens = await api
          .login(
            username: _nameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            passwordHash: hashedPwd,
          )
          .timeout(const Duration(seconds: 5));

      await _storage.write(key: 'jwt_token', value: tokens.token);
      await _storage.write(key: 'refresh_token', value: tokens.refreshToken);
      await _storage.write(key: 'last_email', value: _emailCtrl.text.trim());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добро пожаловать!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

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
          content: Text('Ошибка при регистрации: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
                          label: 'Name',
                          controller: _nameCtrl,
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Введите имя' : null,
                        ),
                        const SizedBox(height: 24),
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
                          toggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          validator: (v) => (v != null && v.length >= 6)
                              ? null
                              : 'Минимум 6 символов',
                        ),
                        const SizedBox(height: 24),
                        _textField(
                          label: 'Confirm Password',
                          controller: _confirmCtrl,
                          isPassword: true,
                          obscure: _obscureConfirm,
                          toggleObscure: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          validator: (v) => (v == _passwordCtrl.text)
                              ? null
                              : 'Пароли не совпадают',
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 52,
                          child: FilledButton(
                            onPressed: _loading ? null : _onRegister,
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
                                    'REGISTER',
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
                              .pushReplacementNamed('/login'),
                          child: const Text(
                            'Login',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
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
