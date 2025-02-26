import 'package:fitpulse_beta/screens/welcome.dart';
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Controlador para la animación de la primera pantalla (Fade)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // Animación Principal
    );

    // Animación de Fade
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Iniciar la animación de la primera pantalla
    _controller.forward().whenComplete(() {
      // Esperar un poco después de la animación para iniciar la transición más sutil
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToHome();
      });
    });
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(_customTransition(const WelcomeScreen()));
  }

  Route _customTransition(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 800), // Duración más suave
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Solo Fade para la transición final
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Usando Image.asset para el fondo
          Positioned.fill(
            child: Image.asset(
              "assets/img/fondo.png",
              fit: BoxFit.cover,
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/img/Logo3.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "FITPULSE",
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Bienvenido",
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
