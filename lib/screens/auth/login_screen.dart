import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/ui.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                shrinkWrap: true,
                children: [
                  Lottie.asset('assets/login_animation.json'),
                  gap(8),
                  const Text('TienditaMejorada',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const Text('Sistema de Inventario y Ventas',
                      textAlign: TextAlign.center),
                  gap(24),
                  const Text('Iniciar Sesión',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  gap(16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: appInput('Correo Electrónico', Icons.email),
                          validator: (value) {
                            final v = value?.trim() ?? '';
                            if (v.isEmpty) return 'El correo electrónico es obligatorio.';
                            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            if (!emailRegex.hasMatch(v)) {
                              return 'Por favor, introduce un formato de correo electrónico válido (ej. nombre@dominio.com).';
                            }
                            return null;
                          },
                        ),
                        gap(12),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: true,
                          decoration: appInput('Contraseña ._.', Icons.lock),
                          validator: (value) {
                            final v = value ?? '';
                            if (v.isEmpty) return 'La contraseña no puede estar vacía.';
                            if (v.length < 6) return 'La contraseña debe tener al menos 6 caracteres.';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  gap(16),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      final isLoading = auth.status == LoginStatus.loading;
                      final isFailure = auth.status == LoginStatus.failure;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (auth.status == LoginStatus.success && mounted) {
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        }
                      });
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FilledButton.icon(
                            onPressed: isLoading ? null : () async {
                              if (!(_formKey.currentState?.validate() ?? false)) {
                                return;
                              }
                              final err = await context.read<AuthProvider>()
                                  .login(_emailCtrl.text.trim(), _passCtrl.text);
                              if (err != null && mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                                context.read<AuthProvider>().clearError();
                              }
                            },
                            icon: isLoading
                                ? const SizedBox(
                                    width: 18, height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.login),
                            label: Text(isLoading ? 'Entrando...' : 'Iniciar Sesión'),
                          ),
                          if (isFailure && (auth.lastError?.isNotEmpty ?? false)) ...[
                            gap(8),
                            Text(
                              auth.lastError!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ]
                        ],
                      );
                    },
                  ),
                  gap(12),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('¿No tienes cuenta? Regístrate aquí'),
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
