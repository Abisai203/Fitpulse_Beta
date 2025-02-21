import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'solicitud_page.dart';
import 'package:fitpulse_beta/screens/home_page.dart';
import 'package:fitpulse_beta/screens/horarios_page.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  final String tipo;
  final Map<String, dynamic> userData;

  const HomeScreen({
    Key? key,
    required this.token,
    required this.tipo,
    required this.userData,
  }) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> coaches = [];
  List<dynamic> filteredCoaches = [];
  TextEditingController searchController = TextEditingController();
  String userName = '';

  @override
  void initState() {
    super.initState();
    fetchCoaches();
    setUserName();
  }

  void setUserName() {
    setState(() {
      userName = widget.userData['nombre'] ?? '-----';
    });
  }

  Future<void> fetchCoaches() async {
    try {
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/entrenadores'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        setState(() {
          coaches = responseData;
          filteredCoaches = coaches;
        });
      } else {
        throw Exception(
            'Error en la petición: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con la API: $e')),
      );
    }
  }

  void navigateToSolicitudPage(Map<String, dynamic> coach) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SolicitudPage(
          coach: coach,
          token: widget.token,
          // Agregamos los datos del usuario
        ),
      ),
    );
  }

  void filterCoaches(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCoaches = coaches;
      } else {
        filteredCoaches = coaches.where((coach) {
          final fullName =
              '${coach['nombre']} ${coach['apellido_paterno']} ${coach['apellido_materno']}'
                  .toLowerCase();
          final email = coach['correo_electronico'].toString().toLowerCase();
          final description =
              coach['descripcion']?.toString().toLowerCase() ?? '';
          final searchLower = query.toLowerCase();

          return fullName.contains(searchLower) ||
              email.contains(searchLower) ||
              description.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: Text(
                                'Buscar Entrenador',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(width: 40),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText:
                                'Buscar por nombre, correo o descripción...',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (value) {
                            filterCoaches(value);
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredCoaches.length,
                      itemBuilder: (context, index) {
                        final coach = filteredCoaches[index];
                        return Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child:
                                  Icon(Icons.person, color: Colors.green[700]),
                            ),
                            title: Text(
                              '${coach['nombre']} ${coach['apellido_paterno']} ${coach['apellido_materno']}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coach['correo_electronico'] ?? 'Sin correo',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                if (coach['descripcion'] != null &&
                                    coach['descripcion'].toString().isNotEmpty)
                                  Text(
                                    coach['descripcion'],
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () {
                              Navigator.pop(context);
                              navigateToSolicitudPage(coach);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    if (widget.tipo == 'entrenador')
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
                    // Barra de búsqueda
                    GestureDetector(
                      onTap: _showSearchModal,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[600]),
                            SizedBox(width: 12),
                            Text(
                              'Buscar entrenadores...',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Sección de entrenamiento diario
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tu entrenamiento para hoy',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700])),
                        Text(DateTime.now().toString().split(' ')[0],
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10)),
                      child: Center(
                          child: Text('Sin rutinas',
                              style: TextStyle(
                                  color: Colors.grey[500], fontSize: 16))),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Sección de entrenadores destacados
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Entrenadores destacados',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: filteredCoaches.length,
                  itemBuilder: (context, index) {
                    final coach = filteredCoaches[index];
                    return GestureDetector(
                      onTap: () => navigateToSolicitudPage(coach),
                      child: Container(
                        width: 120,
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[300],
                                child: Icon(Icons.person, color: Colors.white)),
                            SizedBox(height: 5),
                            Text(
                              coach['nombre'],
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Edad: ${coach['edad']}',
                              style: TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              // Sección de categorías
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Otras Categorías',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                padding: EdgeInsets.all(16.0),
                children: [
                  _buildCategory('Fútbol', Icons.sports_soccer),
                  _buildCategory('Natación', Icons.pool),
                  _buildCategory('Basketbol', Icons.sports_basketball),
                  _buildCategory('Tennis', Icons.sports_tennis),
                  _buildCategory('Ciclismo', Icons.directions_bike),
                  _buildCategory('Boxeo', Icons.sports_mma),
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
              icon: Icon(Icons.fitness_center), label: 'Ejercicios'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 40, color: Colors.green),
        SizedBox(height: 5),
        Text(title, style: TextStyle(fontSize: 14)),
      ],
    );
  }
}
