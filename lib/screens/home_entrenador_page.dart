import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitpulse_beta/screens/horarios_page.dart';
import 'package:fitpulse_beta/screens/notificacion_page.dart';

class HomeEntrenadorPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const HomeEntrenadorPage({
    Key? key,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _HomeEntrenadorPageState createState() => _HomeEntrenadorPageState();
}

class _HomeEntrenadorPageState extends State<HomeEntrenadorPage> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    setUserName();
  }

  void setUserName() {
    setState(() {
      userName = widget.userData['nombre'] ?? '-----';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('FitPulse',
            style: TextStyle(
                color: Colors.green[700], fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.green[700]),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificacionPage(
                    token: widget.token,
                    userData: widget.userData,
                    tipo: 'entrenador',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hola, ${widget.userData['nombre']}',
                        style:
                            TextStyle(fontSize: 18, color: Colors.grey[800])),
                    SizedBox(height: 4),
                    Text('Bienvenido',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700])),
                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 16),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HorariosPage(
                                token: widget.token,
                                userData: widget.userData,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.calendar_today),
                        label: Text('Gestionar Horarios'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sección de solicitudes pendientes
                    Text('Solicitudes pendientes',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700])),
                    SizedBox(height: 10),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text('Sin solicitudes pendientes',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 16))),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Sección de estudiantes activos
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Mis estudiantes',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 150,
                child: Center(
                  child: Text(
                    'No hay estudiantes activos',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sección de sesiones programadas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sesiones programadas',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              SizedBox(height: 10),
              Container(
                height: 100,
                margin: EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'No hay sesiones programadas',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Sección de estadísticas
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Mis estadísticas',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildStatCard('Estudiantes', '0', Icons.people),
                  _buildStatCard('Sesiones', '0', Icons.fitness_center),
                  _buildStatCard('Valoración', '0.0', Icons.star),
                  _buildStatCard('Completadas', '0', Icons.check_circle),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Horarios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.green[700]),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700])),
            SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}