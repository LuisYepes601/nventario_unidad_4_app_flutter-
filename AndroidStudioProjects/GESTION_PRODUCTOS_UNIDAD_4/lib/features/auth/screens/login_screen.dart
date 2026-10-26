import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'registro_screen.dart';
import '../../productos/screens/productos_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  // Imágenes de fondo dinámicas e iluminadas
  final List<String> _bgImages = [
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1553413077-190dd305871c?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1497366216548-37526070297c?q=80&w=1000&auto=format&fit=crop',
  ];

  int _currentBgIndex = 0;
  Timer? _bgTimer;

  @override
  void initState() {
    super.initState();
    // Animación de transición de imágenes cada 4 segundos
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final usuario = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (usuario != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡Bienvenido, ${usuario.nombre}!'),
          backgroundColor: const Color(0xFF047857),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProductosScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Credenciales incorrectas. Intenta de nuevo.'),
          backgroundColor: Colors.redAccent,
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
          // 1. Fondo Animado
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

          // 2. Capa de Degradado Luminoso
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

          // 3. Contenido Principal
          SafeArea(
            child: Column(
              children: [
                // Botón Regresar superior
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
                                  // Título principal
                                  const Text(
                                    'Iniciar Sesión',
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
                                    'Ingresa tus credenciales para acceder a la plataforma',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 28),

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
                                  const SizedBox(height: 16),

                                  // Campo Contraseña
                                  _buildCleanTextField(
                                    controller: _passwordController,
                                    label: 'Contraseña',
                                    icon: Icons.lock_outline_rounded,
                                    primaryColor: darkForestGreen,
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingresa tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  // Botón Iniciar Sesión
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _iniciarSesion,
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
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 18),

                                  // Redirección a Registro
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '¿No tienes cuenta?',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const RegistroScreen(),
                                            ),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 6),
                                          minimumSize: Size.zero,
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text(
                                          'Regístrate aquí',
                                          style: TextStyle(
                                            color: darkForestGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
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

  // Widget reutilizable para campos de texto limpios
  Widget _buildCleanTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color primaryColor,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
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