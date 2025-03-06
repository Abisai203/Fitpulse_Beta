import 'package:flutter/material.dart';
import 'package:fitpulse_beta/screens/home_alumno_page.dart'; // Import home page for navigation
import 'package:fitpulse_beta/screens/notificacion_page.dart';
import 'package:fitpulse_beta/screens/perfil_page.dart';
import 'package:fitpulse_beta/screens/home_entrenador_page.dart';

class PerfilPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const PerfilPage({
    Key? key,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _PerfilPageState createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  // Add a method to handle bottom navigation bar item taps
  void _onBottomNavBarTap(int index) {
    switch (index) {
      case 0:
        // Navigate back to Home page based on user type
        if (widget.userData['tipo'] == 'entrenador') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeEntrenadorPage(
                token: widget.token,
                userData: widget.userData,
              ),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeEntrenadorPage(
                token: widget.token,
                userData: widget.userData,
              ),
            ),
          );
        }
        break;
      case 1:
        // Navigate to Exercises page (you can replace with your actual exercises page)
        // Navigator.pushReplacement(...);
        break;
      case 2:
        // Already on Profile page, do nothing
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Mi Perfil',
          style: TextStyle(
            color: Colors.green[700], 
            fontWeight: FontWeight.bold
          )
        ),
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
                    tipo: widget.userData['tipo'] == 'entrenador' ? 'entrenador' : 'usuario',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.green[100],
                  child: Icon(
                    Icons.person, 
                    size: 80, 
                    color: Colors.green[700]
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '${widget.userData['nombre']} ${widget.userData['apellido_paterno'] ?? ''} ${widget.userData['apellido_materno'] ?? ''}',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700]
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  widget.userData['correo_electronico'] ?? 'Correo no disponible',
                  style: TextStyle(
                    fontSize: 16, 
                    color: Colors.grey[600]
                  ),
                ),
                SizedBox(height: 30),
                _buildProfileSection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 2, // Set current index to Profile
        onTap: _onBottomNavBarTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Ejercicios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        _buildProfileItem(
          icon: Icons.person_outline, 
          title: 'Información Personal',
          onTap: () {
            // Implement navigation to personal info edit screen
          },
        ),
        _buildProfileItem(
          icon: Icons.fitness_center, 
          title: 'Mis Deportes',
          onTap: () {
            // Implement navigation to sports selection/edit screen
          },
        ),
        _buildProfileItem(
          icon: Icons.settings, 
          title: 'Configuración',
          onTap: () {
            // Implement navigation to settings screen
          },
        ),
        _buildProfileItem(
          icon: Icons.logout, 
          title: 'Cerrar Sesión',
          onTap: () {
            // Implement logout functionality
          },
        ),
      ],
    );
  }

  Widget _buildProfileItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green[700]),
      title: Text(
        title, 
        style: TextStyle(
          color: Colors.grey[800], 
          fontSize: 16
        )
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        size: 16, 
        color: Colors.green[700]
      ),
      onTap: onTap,
    );
  }
}