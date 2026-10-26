import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  final List<String> _bgImages = [
    'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?q=80&w=1000&auto=format&fit=crop',
  ];

  int _currentBgIndex = 0;
  Timer? _bgTimer;

  @override
  void initState() {
    super.initState();
    _bgTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentBgIndex = (_currentBgIndex + 1) % _bgImages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _bgTimer?.cancel();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _registrarse() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final exito = await _authService.registro(
      _nombreController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Cuenta creada exitosamente! Inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al registrar usuario. Intenta con otro correo.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const darkForestGreen = Color(0xFF047857);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo con Transición Animada
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Image.network(
              _bgImages[_currentBgIndex],
              key: ValueKey<String>(_bgImages[_currentBgIndex]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFFE6F4EA),
              ),
            ),
          ),

          // 2. Degradado sutil
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.black.withOpacity(0.25),
                    Colors.black.withOpacity(0.55),
                  ],
                ),
              ),
            ),
          ),

          // 3. Contenido
          SafeArea(
            child: Column(
              children: [
                // Botón Regresar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Regresar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          shadows: [Shadow(blurRadius: 4, color: Colors.black45)],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.92),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Título principal sin badge superior
                                  const Text(
                                    'Crear Cuenta',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Ingresa tus datos para registrarte en la plataforma',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Campo Nombre Completo
                                  _buildCleanTextField(
                                    controller: _nombreController,
                                    label: 'Nombre completo',
                                    icon: Icons.person_outline_rounded,
                                    primaryColor: darkForestGreen,
                                    textCapitalization: TextCapitalization.words,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Ingresa tu nombre completo';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Campo Correo Electrónico
                                  _buildCleanTextField(
                                    controller: _emailController,
                                    label: 'Correo electrónico',
                                    icon: Icons.email_outlined,
                                    primaryColor: darkForestGreen,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Ingresa tu correo';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Ingresa un correo válido';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Campo Contraseña
                                  _buildCleanTextField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline_rounded,
                                    primaryColor: darkForestGreen,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa una contraseña';
                                      }
                                      if (value.length < 6) {
                                        return 'Mínimo 6 caracteres';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 14),

                                  // Campo Confirmar Contraseña
                                  _buildCleanTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirmar contraseña',
                                    icon: Icons.lock_reset_rounded,
                                    primaryColor: darkForestGreen,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirma tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Botón Registrarse
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _registrarse,
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size.fromHeight(52),
                                      backgroundColor: darkForestGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 3,
                                      shadowColor: darkForestGreen.withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}