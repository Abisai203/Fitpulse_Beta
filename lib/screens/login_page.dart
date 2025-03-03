import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fitpulse_beta/screens/register_page.dart';
import 'package:fitpulse_beta/screens/home_entrenador_page.dart'; // Importamos la página del entrenador
import 'package:fitpulse_beta/screens/home_alumno_page.dart'; // Importamos la página del alumno

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> login() async {
    // Validar campos antes de intentar iniciar sesión
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu correo electrónico"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, ingresa tu contraseña"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String apiUrl = "https://beta-fit-pulse.onrender.com/auth/login";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "correo_electronico": _emailController.text.trim(),
          "contrasena": _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final String token = data['token'];
        final String tipo = data['tipo'];
        final Map<String, dynamic> userData =
            Map<String, dynamic>.from(data['userData']);

        // Procesar la foto de perfil si existe
        if (userData['foto_perfil'] != null) {
          try {
            if (userData['foto_perfil'] is Map &&
                userData['foto_perfil'].containsKey('data') &&
                userData['foto_perfil']['data'] is List) {
              List<int> bufferData =
                  List<int>.from(userData['foto_perfil']['data']);
              String base64Image = base64Encode(bufferData);
              userData['foto_perfil'] = base64Image;
            } else {
              // Si no está en el formato esperado, establecer como null
              userData['foto_perfil'] = null;
            }
          } catch (e) {
            print('Error procesando la foto de perfil: $e');
            userData['foto_perfil'] = null;
          }
        }

        // Validar que todos los campos necesarios estén presentes
        final requiredFields = [
          'id',
          'nombre',
          'apellido_paterno',
          'apellido_materno',
          'edad',
          'correo_electronico',
          'numero_telefonico',
          'sexo',
          'deporte_prioritario_id'
        ];

        for (var field in requiredFields) {
          if (!userData.containsKey(field)) {
            userData[field] = null;
          }
        }

        // Redireccionar según el tipo de usuario
        if (tipo == 'entrenador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeEntrenadorPage(
                token: token,
                userData: userData,
              ),
            ),
          );
        } else if (tipo == 'usuario') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeAlumnoPage(
                token: token,
                userData: userData,
              ),
            ),
          );
        } else {
          // Si hay un tipo no reconocido, mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("usuario no reconocido"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? "Error desconocido";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error en el login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Error al conectar con el servidor. Por favor, intenta de nuevo."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Inicio de Sesión"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Text(
                      "Bienvenido",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Inicia sesión para continuar",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Campo de correo electrónico
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Correo Electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de contraseña con botón para mostrar/ocultar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta? '),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Colors.green,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}