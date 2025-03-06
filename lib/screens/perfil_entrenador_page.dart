import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitpulse_beta/screens/home_entrenador_page.dart';
import 'package:fitpulse_beta/screens/horarios_page.dart';

class PerfilEntrenadorPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const PerfilEntrenadorPage({
    Key? key,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _PerfilEntrenadorPageState createState() => _PerfilEntrenadorPageState();
}

class _PerfilEntrenadorPageState extends State<PerfilEntrenadorPage> {
  int _currentIndex = 2; // Set to 2 as we're on the profile tab

  // Maneja la navegación según el índice del navbar
  void _onItemTapped(int index) {
    if (_currentIndex == index) return; // Don't navigate if we're already on the page
    
    setState(() {
      _currentIndex = index;
    });

    // Navegación a diferentes pantallas con transición personalizada
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeEntrenadorPage(
            token: widget.token,
            userData: widget.userData,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Slide from left
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HorariosPage(
            token: widget.token,
            userData: widget.userData,
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Slide from left
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _onItemTapped(0); // Return to home
          },
        ),
        title: Text(
          'Perfil de Entrenador',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: BackgroundPainter(),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    decoration: _boxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Avatar circular con foto de perfil
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.green[700],
                          child: CircleAvatar(
                            radius: 43,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 50, color: Colors.green[700]),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Nombre del entrenador
                        Text(
                          widget.userData['nombre'] ?? 'Noe',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.userData['correo_electronico'] ?? 'email@ejemplo.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(thickness: 1, color: Colors.black12),
                        const SizedBox(height: 10),
                        _buildMenuItem(Icons.edit, "Editar Perfil", () {
                          // Agregar lógica para editar el perfil
                        }),
                        _buildMenuItem(Icons.monetization_on, "Mis Pagos", () {
                          // Lógica para ver pagos
                        }),
                        _buildMenuItem(Icons.settings, "Configuración", () {
                          // Lógica para configuración
                        }),
                        _buildMenuItem(Icons.people, "Mis Estudiantes", () {
                          // Lógica para ver estudiantes
                        }),
                        _buildMenuItem(Icons.swap_horiz, "Cambiar a Cliente", () {
                          // Lógica para cambiar de rol
                        }),
                        _buildMenuItem(Icons.power_settings_new, "Cerrar sesión", () {
                          // Lógica para cerrar sesión
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.green[700],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Horarios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          spreadRadius: 2,
          offset: const Offset(2, 4),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.black.withOpacity(0.05)),
        ),
        child: ListTile(
          leading: Icon(icon, color: Colors.green[700]),
          title: Text(
            title,
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.green[700], size: 16),
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }
}

// Fondo con formas personalizadas
class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green[700] ?? Colors.green;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height * 0.15), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}