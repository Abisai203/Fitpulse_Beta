import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_page.dart'; // Importa la pantalla de inicio de sesión

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _selectedType; // Tipo de usuario seleccionado
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _sexo = 'Femenino';
  bool _isLoading = false;

  Future<void> registerUser() async {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor selecciona un tipo de usuario.")),
      );
      return;
    }

    final String apiUrl = _selectedType == "Coach"
        ? "https://fit-pulse-1w4q.onrender.com/coaches"
        : "https://fit-pulse-1w4q.onrender.com/alumnos";

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "nombre": _nombreController.text.trim(),
          "apellido": _apellidoController.text.trim(),
          "edad": int.tryParse(_edadController.text.trim()) ?? 0,
          if (_selectedType == "Coach")
            "especialidad": _especialidadController.text.trim(),
          "email": _emailController.text.trim(),
          "contraseña": _passwordController.text.trim(),
          "sexo": _sexo,
        }),
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
        final errorMessage =
            json.decode(response.body)['error'] ?? "Error desconocido";
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

  Widget _buildSelectionButtons() {
    List<Map<String, dynamic>> options = [
      {"label": "Entrenador", "icon": Icons.run_circle, "value": "Coach"},
      {"label": "Alumno", "icon": Icons.person, "value": "Alumno"},
      {
        "label": "Entrenador\nY Alumno",
        "icon": Icons.sports_gymnastics,
        "value": "CoachAlumno"
      }
    ];

    return Column(
      children: [
        Text(
          "Bienvenido",
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green[900]),
        ),
        SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: 1.8,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: options.map((option) {
            bool isSelected = _selectedType == option['value'];
            return GestureDetector(
              onTap: () => setState(() => _selectedType = option['value']),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green[200] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(option['icon'],
                        size: 40,
                        color: isSelected ? Colors.white : Colors.green),
                    SizedBox(height: 5),
                    Text(option['label'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.green))
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _selectedType == null
              ? null
              : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text("Siguiente",
              style: TextStyle(fontSize: 18, color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_selectedType == null)
              _buildSelectionButtons()
            else ...[
              Text(
                "Registro como $_selectedType",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: "Nombre"),
              ),
              TextField(
                controller: _apellidoController,
                decoration: InputDecoration(labelText: "Apellido"),
              ),
              TextField(
                controller: _edadController,
                decoration: InputDecoration(labelText: "Edad"),
                keyboardType: TextInputType.number,
              ),
              if (_selectedType == "Coach" || _selectedType == "CoachAlumno")
                TextField(
                  controller: _especialidadController,
                  decoration: InputDecoration(labelText: "Especialidad"),
                ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Correo Electrónico"),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Contraseña"),
                obscureText: true,
              ),
              DropdownButtonFormField(
                value: _sexo,
                items: ['Femenino', 'Masculino']
                    .map((sexo) =>
                        DropdownMenuItem(value: sexo, child: Text(sexo)))
                    .toList(),
                onChanged: (value) => setState(() => _sexo = value as String),
                decoration: InputDecoration(labelText: "Sexo"),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: registerUser,
                      child: Text("Registrar"),
                    ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () => setState(() => _selectedType = null),
                child: Text("Volver a selección"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
