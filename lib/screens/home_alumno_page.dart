import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fitpulse_beta/screens/solicitud_page.dart';
import 'package:fitpulse_beta/screens/notificacion_page.dart';
import 'package:fitpulse_beta/screens/perfil_page.dart';

class HomeAlumnoPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const HomeAlumnoPage({
    Key? key,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _HomeAlumnoPageState createState() => _HomeAlumnoPageState();
}

class _HomeAlumnoPageState extends State<HomeAlumnoPage> {
  
  List<dynamic> coaches = [];
  List<dynamic> filteredCoaches = [];
  TextEditingController searchController = TextEditingController();
  String userName = '';
  // Mapa para relacionar IDs de deportes con sus nombres
  Map<int, String> deportesMap = {
    1: "Fútbol",
    2: "Baloncesto",
    3: "Natación",
    4: "Tenis",
    5: "Atletismo",
    6: "Voleibol",
    7: "Ciclismo",
    8: "Boxeo",
    9: "Artes Marciales",
    10: "Béisbol",
  };
  String deporteFavorito = '';
  void _onBottomNavBarTap(int index) {
    switch (index) {
      case 0:
        // Already on Home page, do nothing
        break;
      case 1:
        // Navigate to Exercises page (you can replace with your actual exercises page)
        // Navigator.pushReplacement(...);
        break;
      case 2:
        // Navigate to Profile page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilPage(
              token: widget.token,
              userData: widget.userData,
            ),
          ),
        );
        break;
    }
  }
 

  @override
  void initState() {
    super.initState();
    fetchCoaches();
    setUserName();
    setDeporteFavorito();
  }

  void setUserName() {
    setState(() {
      userName = widget.userData['nombre'] ?? '-----';
    });
  }

  void setDeporteFavorito() {
    if (widget.userData.containsKey('deporte_prioritario_id')) {
      final deporteId = widget.userData['deporte_prioritario_id'];
      setState(() {
        deporteFavorito = deportesMap[deporteId] ?? 'Deporte no especificado';
      });
    }
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
          
          // Filtrar entrenadores por deporte prioritario del usuario
          if (widget.userData.containsKey('deporte_prioritario_id')) {
            final userSportId = widget.userData['deporte_prioritario_id'];
            filteredCoaches = coaches.where((coach) => 
              coach['id_deporte'] == userSportId
            ).toList();
          } else {
            filteredCoaches = coaches;
          }
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

  // Función para obtener el nombre del deporte a partir de su ID
  String getDeporteName(int deporteId) {
    return deportesMap[deporteId] ?? 'Deporte no especificado';
  }

  void navigateToSolicitudPage(Map<String, dynamic> coach) {
    if (widget.userData != null && widget.token != null) {
      print("Datos de usuario que se pasarán: ${widget.userData}");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SolicitudPage(
            key: UniqueKey(),
            coach: coach,
            token: widget.token,
            userData: widget.userData,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Datos de usuario no disponibles'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
void filterCoaches(String query) {
  setState(() {
    if (query.isEmpty) {
      // Si el filtro está vacío, mostramos los entrenadores del deporte del usuario
      if (widget.userData.containsKey('deporte_prioritario_id')) {
        final userSportId = widget.userData['deporte_prioritario_id'];
        filteredCoaches = coaches.where((coach) => 
          coach['id_deporte'] == userSportId
        ).toList();
      } else {
        filteredCoaches = coaches;
      }
    } else {
      // Si hay texto de búsqueda, filtramos por nombre, correo, descripción o deporte
      filteredCoaches = coaches.where((coach) {
        final fullName =
            '${coach['nombre']} ${coach['apellido_paterno']} ${coach['apellido_materno']}'
                .toLowerCase();
        final email = coach['correo_electronico'].toString().toLowerCase();
        final description =
            coach['descripcion']?.toString().toLowerCase() ?? '';
        
        // Obtener el nombre del deporte para este entrenador
        final deporteName = getDeporteName(coach['id_deporte']).toLowerCase();
        
        final searchLower = query.toLowerCase();

        return fullName.contains(searchLower) ||
            email.contains(searchLower) ||
            description.contains(searchLower) ||
            deporteName.contains(searchLower); // Añadir búsqueda por deporte
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
                            onPressed: () {
                              // Reset search text and filtered list when closing
                              searchController.clear();
                              filterCoaches('');
                              Navigator.pop(context);
                            },
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
                          hintText: 'Buscar por nombre, correo, deporte o descripción...',
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
                      final deporteName = getDeporteName(coach['id_deporte']);
                      
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
                                '$deporteName',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                            // Clear search when selecting a coach
                            searchController.clear();
                            filterCoaches('');
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
  ).then((_) {
    // This runs when the modal is closed by any means
    // (including tapping outside or back button)
    searchController.clear();
    filterCoaches('');
  });
  
}
  @override
Widget build(BuildContext context) { // ajsdbajbdhasdhagdasdadasdasdfsdgdfhfhdfasdffdasfasfasffsd
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
                  tipo: 'alumno',
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
                    SizedBox(height: 8),
                    // Mostrar el deporte favorito
                    if (deporteFavorito.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fitness_center, size: 16, color: Colors.green[700]),
                            SizedBox(width: 4),
                            Text(
                              'Tu deporte: $deporteFavorito',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Entrenadores destacados',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    // Indicador de filtrado
                    if (widget.userData.containsKey('deporte_prioritario_id'))
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Filtrado por: $deporteFavorito',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 180, // Incrementado para acomodar nueva información
                child: filteredCoaches.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No hay entrenadores disponibles para $deporteFavorito',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: filteredCoaches.length,
                        itemBuilder: (context, index) {
                          final coach = filteredCoaches[index];
                          final deporteName = getDeporteName(coach['id_deporte']);
                          
                          return GestureDetector(
                            onTap: () => navigateToSolicitudPage(coach),
                            child: Container(
                              width: 150,
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
                                      backgroundColor: Colors.green[300],
                                      child: Icon(Icons.person, color: Colors.white, size: 36)),
                                  SizedBox(height: 8),
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
                                  SizedBox(height: 4),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.green[200]!),
                                    ),
                                    child: Text(
                                      deporteName,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
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
                  _buildCategory('Baloncesto', Icons.sports_basketball),
                  _buildCategory('Tenis', Icons.sports_tennis),
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
      currentIndex: 0, // Set current index to Home
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