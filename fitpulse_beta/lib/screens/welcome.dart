// ignore_for_file: deprecated_member_use

import 'package:fitpulse_beta/screens/login_page.dart';
import 'package:flutter/material.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/img/fondo.png', // Asegúrate de usar la extensión correcta
              fit: BoxFit.cover,
            ),
          ),
          // Filtro oscuro
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1 ),
            ),
          ),
          // Contenido
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: Container(
                  height: 400,
                  decoration: BoxDecoration(
                    color: const Color(0xFF363636).withOpacity(0.85),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Bienvenido",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 380,
                        height: 3,
                        color: Colors.white,
                        margin: EdgeInsets.only(top: 10),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        "En esta aplicación encontrarás entrenadores de diversas categorías ofreciendo sus servicios para ti. Además, tendrás la opción de convertirte en entrenador y ofrecer tus propios servicios. Todo está diseñado para conectar talentos y necesidades en un solo lugar, de forma fácil y eficiente.",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 46),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context)=>LoginPage())
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 84,
                          ),
                        ),
                        child: const Text(
                          "Comenzar",
                          style: TextStyle(fontSize: 28, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 0), // Espacio al final
            ],
          ),
        ],
      ),
    );
  }
}
