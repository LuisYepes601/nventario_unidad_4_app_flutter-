import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'registro_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final List<String> _images = [
    'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1553413077-190dd305871c?q=80&w=1000&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1616401784845-180882ba9ba8?q=80&w=1000&auto=format&fit=crop',
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _images.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const darkForestGreen = Color(0xFF047857);
    const accentMint = Color(0xFF6EE7B7);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo Animado
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1200),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Image.network(
              _images[_currentIndex],
              key: ValueKey<String>(_images[_currentIndex]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                color: const Color(0xFF022C22),
              ),
            ),
          ),

          // 2. Capa de degradado
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.25, 0.65, 1.0],
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.88),
                    Colors.black.withOpacity(0.98),
                  ],
                ),
              ),
            ),
          ),

          // 3. Contenido Principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26.0, vertical: 18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN SUPERIOR: BADGE LIMPIO SIN PUNTO ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: accentMint.withOpacity(0.3), width: 1),
                    ),
                    child: const Text(
                      'GESTIÓN DE INVENTARIOS',
                      style: TextStyle(
                        color: accentMint,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- SECCIÓN CENTRAL ---
                  Text(
                    'Control Total en\nTiempo Real',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: -0.5,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Optimiza la logística de tu negocio. Sincroniza productos, categorías y marcas de forma intuitiva, rápida y segura.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 15.5,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.1,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 1),
                          blurRadius: 6,
                          color: Colors.black.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 3),

                  // --- SECCIÓN INFERIOR ---
                  Row(
                    children: List.generate(
                      _images.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 6,
                        width: _currentIndex == index ? 30 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? accentMint
                              : Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _currentIndex == index
                              ? [
                            BoxShadow(
                              color: accentMint.withOpacity(0.5),
                              blurRadius: 6,
                            )
                          ]
                              : [],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: darkForestGreen,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: darkForestGreen.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistroScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: BorderSide(color: Colors.white.withOpacity(0.85), width: 1.5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Crear una Cuenta',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}