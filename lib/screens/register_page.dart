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
  final TextEditingController _apellidoPaternoController =
      TextEditingController();
  final TextEditingController _apellidoMaternoController =
      TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _sexo = 'Masculino';
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  int? _idDeporteSeleccionado;
  final _formKey = GlobalKey<FormState>();

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
    // Validar el formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor selecciona el tipo de usuario.")),
      );
      return;
    }

    if (_idDeporteSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_selectedType == "Coach"
                ? "Por favor selecciona un deporte para entrenar."
                : "Por favor selecciona tu deporte favorito.")),
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
        requestBody["deporte_prioritario_id"] = _idDeporteSeleccionado!;
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
        SnackBar(content: Text("Error al conectar con el servidor: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función para validar email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Función para validar teléfono (10 dígitos)
  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registro"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tipo de usuario
              DropdownButtonFormField(
                value: _selectedType,
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona el tipo de usuario';
                  }
                  return null;
                },
                items: [
                  DropdownMenuItem(value: "Coach", child: Text("Entrenador")),
                  DropdownMenuItem(value: "Alumno", child: Text("Alumno")),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value as String?;
                    _idDeporteSeleccionado =
                        null; // Restablecer selección de deporte
                  });
                },
                decoration: InputDecoration(
                  labelText: "Tipo de Usuario ",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
              ),
              SizedBox(height: 16),

              // Nombre
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: "Nombre ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Apellido Paterno
              TextFormField(
                controller: _apellidoPaternoController,
                decoration: InputDecoration(
                  labelText: "Apellido Paterno ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El apellido paterno es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Apellido Materno
              TextFormField(
                controller: _apellidoMaternoController,
                decoration: InputDecoration(
                  labelText: "Apellido Materno ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El apellido materno es obligatorio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Edad
              TextFormField(
                controller: _edadController,
                decoration: InputDecoration(
                  labelText: "Edad ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La edad es obligatoria';
                  }
                  int? edad = int.tryParse(value);
                  if (edad == null || edad <= 0 || edad > 120) {
                    return 'Ingresa una edad válida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Número telefónico
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(
                  labelText: "Número Telefónico ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                  hintText: "10 dígitos",
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El número telefónico es obligatorio';
                  }
                  if (!_isValidPhone(value.trim())) {
                    return 'Ingresa un número telefónico válido de 10 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Correo Electrónico
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "Correo Electrónico ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El correo electrónico es obligatorio';
                  }
                  if (!_isValidEmail(value.trim())) {
                    return 'Ingresa un correo electrónico válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Contraseña con visibilidad
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Contraseña ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Sexo
              DropdownButtonFormField(
                value: _sexo,
                items: ["Masculino", "Femenino"]
                    .map((sexo) =>
                        DropdownMenuItem(value: sexo, child: Text(sexo)))
                    .toList(),
                onChanged: (value) => setState(() => _sexo = value as String),
                decoration: InputDecoration(
                  labelText: "Sexo ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Por favor selecciona tu sexo';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Deporte
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
                decoration: InputDecoration(
                  labelText: _selectedType == "Coach"
                      ? "Deporte a Entrenar "
                      : "Deporte Favorito ",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sports),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                validator: (value) {
                  if (value == null) {
                    return _selectedType == "Coach"
                        ? 'Por favor selecciona un deporte para entrenar'
                        : 'Por favor selecciona tu deporte favorito';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Campo de descripción solo para entrenadores
              if (_selectedType == "Coach")
                TextFormField(
                  controller: _descripcionController,
                  decoration: InputDecoration(
                    labelText: "Descripción ",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                    hintText: "Describe tu experiencia como entrenador",
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (_selectedType == "Coach" &&
                        (value == null || value.trim().isEmpty)) {
                      return 'La descripción es obligatoria para entrenadores';
                    }
                    return null;
                  },
                ),
              if (_selectedType == "Coach") SizedBox(height: 16),

              // Nota sobre campos obligatorios
              Text(
                "* Campos obligatorios",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(height: 20),

              // Botón de registro
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: registerUser,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          "REGISTRAR",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
