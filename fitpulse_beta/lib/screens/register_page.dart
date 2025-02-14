import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _selectedType;
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _sexo = 'Masculino';
  bool _isLoading = false;
  int? _idDeporteSeleccionado;

  List<Map<String, dynamic>> _deportes = [
    {"id": 1, "nombre": "Fútbol"},
    {"id": 2, "nombre": "Baloncesto"},
    {"id": 3, "nombre": "Natación"},
    {"id": 4, "nombre": "Tenis"},
    {"id": 5, "nombre": "Atletismo"},
    {"id": 6, "nombre": "Voleibol"},
    {"id": 7, "nombre": "Ciclismo"},
    {"id": 8, "nombre": "Boxeo"},
    {"id": 9, "nombre": "Artes Marciales"},
    {"id": 10, "nombre": "Béisbol"},
  ];

  Future<void> registerUser() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor selecciona el tipo de usuario.")),
      );
      return;
    }

    if (_selectedType == "Coach" && _idDeporteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor selecciona un deporte para entrenar.")),
      );
      return;
    }

    final String apiUrl = _selectedType == "Coach"
        ? "https://beta-fit-pulse.onrender.com/entrenadores"
        : "https://beta-fit-pulse.onrender.com/usuarios";

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> requestBody = {
        "nombre": _nombreController.text.trim(),
        "apellido_paterno": _apellidoPaternoController.text.trim(),
        "apellido_materno": _apellidoMaternoController.text.trim(),
        "edad": int.tryParse(_edadController.text.trim()) ?? 0,
        "correo_electronico": _emailController.text.trim(),
        "contrasena": _passwordController.text.trim(),
        "numero_telefonico": _telefonoController.text.trim(),
        "sexo": _sexo,
      };

      if (_selectedType == "Coach") {
        requestBody["id_deporte"] = _idDeporteSeleccionado!;
        requestBody["descripcion"] = _descripcionController.text.trim();
      } else {
        requestBody["deporte_prioritario_id"] = _idDeporteSeleccionado ?? 0;
      }

      print("Enviando datos: ${json.encode(requestBody)}"); // Para depuración

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registro exitoso")),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        String errorMessage = errorData.containsKey('error')
            ? errorData['error']
            : "Error desconocido";

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al conectar con el servidor.")),
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
      appBar: AppBar(title: Text("Registro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: _selectedType,
              items: [
                DropdownMenuItem(value: "Coach", child: Text("Entrenador")),
                DropdownMenuItem(value: "Alumno", child: Text("Alumno")),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value as String?;
                  _idDeporteSeleccionado = null; // Restablecer selección de deporte
                });
              },
              decoration: InputDecoration(labelText: "Tipo de Usuario"),
            ),
            TextField(controller: _nombreController, decoration: InputDecoration(labelText: "Nombre")),
            TextField(controller: _apellidoPaternoController, decoration: InputDecoration(labelText: "Apellido Paterno")),
            TextField(controller: _apellidoMaternoController, decoration: InputDecoration(labelText: "Apellido Materno")),
            TextField(controller: _edadController, decoration: InputDecoration(labelText: "Edad"), keyboardType: TextInputType.number),
            TextField(controller: _telefonoController, decoration: InputDecoration(labelText: "Número Telefónico"), keyboardType: TextInputType.phone),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Correo Electrónico"), keyboardType: TextInputType.emailAddress),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Contraseña"), obscureText: true),
            DropdownButtonFormField(
              value: _sexo,
              items: ["Masculino", "Femenino"].map((sexo) => DropdownMenuItem(value: sexo, child: Text(sexo))).toList(),
              onChanged: (value) => setState(() => _sexo = value as String),
              decoration: InputDecoration(labelText: "Sexo"),
            ),
            DropdownButtonFormField(
              value: _idDeporteSeleccionado,
              items: _deportes.map((deporte) {
                return DropdownMenuItem(
                  value: deporte["id"],
                  child: Text(deporte["nombre"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _idDeporteSeleccionado = value as int?;
                });
              },
              decoration: InputDecoration(labelText: _selectedType == "Coach" ? "Deporte a Entrenar" : "Deporte Favorito"),
            ),
            if (_selectedType == "Coach")
              TextField(controller: _descripcionController, decoration: InputDecoration(labelText: "Descripción")),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: registerUser,
                    child: Text("Registrar"),
                  ),
          ],
        ),
      ),
    );
  }
}
