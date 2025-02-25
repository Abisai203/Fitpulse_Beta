import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SolicitudPage extends StatefulWidget {
  final Map<String, dynamic> coach;
  final String token;
  final Map<String, dynamic> userData;

  const SolicitudPage({
    Key? key,
    required this.coach,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _SolicitudPageState createState() => _SolicitudPageState();
}

class _SolicitudPageState extends State<SolicitudPage> {
  List<Map<String, dynamic>> horarios = [];
  bool isLoading = true;
  Map<String, dynamic>? selectedHorario;

  @override
  void initState() {
    super.initState();
    print('Iniciando SolicitudPage');
    print('Coach data: ${widget.coach}');
    print('Coach ID: ${widget.coach['id_entrenador']}');
    print('Token disponible: ${widget.token.isNotEmpty}');
    fetchHorarios();
  }

  Future<void> fetchHorarios() async {
    try {
      print('Iniciando fetchHorarios');
      print('Token completo: ${widget.token}');
      
      // Asegurarse de usar id_entrenador según la estructura de datos proporcionada
      final coachId = widget.coach['id_entrenador'];
      print('Coach ID: $coachId');

      // URL correcta según la estructura de datos que has proporcionado
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/entrenador/$coachId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      print('Status code de la respuesta: ${response.statusCode}');
      print('Headers de la respuesta: ${response.headers}');
      print('Cuerpo de la respuesta: ${response.body}');
      
      if (response.statusCode == 200) {
        print('Respuesta exitosa');
        
        // Corregido: Manejamos tanto si la respuesta es un Map como si es una List
        final dynamic responseData = json.decode(response.body);
        List<dynamic> coachHorarios = [];
        
        if (responseData is Map<String, dynamic>) {
          // Si la respuesta es un Map, verificamos si tiene una propiedad que contiene la lista
          // (ajusta esto según la estructura real de tu respuesta)
          if (responseData.containsKey('horarios')) {
            coachHorarios = responseData['horarios'];
          } else if (responseData.containsKey('data')) {
            coachHorarios = responseData['data'];
          } else {
            // Si no tiene una propiedad específica, intentamos convertir los valores del mapa
            coachHorarios = responseData.values.toList();
          }
        } else if (responseData is List<dynamic>) {
          // Si ya es una lista, la usamos directamente
          coachHorarios = responseData;
        }
        
        print('Total de horarios recibidos: ${coachHorarios.length}');
        
        if (coachHorarios.isNotEmpty) {
          print('Ejemplo del primer horario:');
          print(json.encode(coachHorarios.first));
        }
        
        setState(() {
          horarios = List<Map<String, dynamic>>.from(
            coachHorarios.map((item) => 
              item is Map<String, dynamic> ? item : <String, dynamic>{}
            )
          );
          isLoading = false;
        });
        
        print('Estado actualizado. Horarios disponibles: ${horarios.length}');
      } else {
        print('Error en la respuesta:');
        print('Status code: ${response.statusCode}');
        print('Cuerpo del error: ${response.body}');
        setState(() => isLoading = false);
      }
    } catch (e, stackTrace) {
      print('Error en fetchHorarios:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar horarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _solicitarEntrenador(BuildContext context) async {
    if (selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un horario')),
      );
      return;
    }

    try {
      print('Iniciando solicitud de entrenador');
      
      // Usando la estructura correcta según tu ejemplo
      final solicitud = {
        "id_usuario": widget.userData['id'],
        "id_horario": selectedHorario!['id_horario'],
        "estado": "Pendiente",
        "fecha_solicitud": DateTime.now().toIso8601String()
      };
      
      print('Datos de la solicitud:');
      print(json.encode(solicitud));

      final response = await http.post(
        Uri.parse('https://beta-fit-pulse.onrender.com/solicitudes'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode(solicitud),
      );

      print('Respuesta de la solicitud:');
      print('Status code: ${response.statusCode}');
      print('Cuerpo: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud enviada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Error al enviar la solicitud: Status ${response.statusCode}, Respuesta: ${response.body}');
      }
    } catch (e) {
      print('Error al solicitar entrenador: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar la solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String formatTimeString(String timeString) {
    try {
      // Manejo seguro para el formato de tiempo hh:mm:ss
      return timeString.substring(0, 5);  // Retorna solo hh:mm
    } catch (e) {
      return timeString; // Si hay error, devuelve el string original
    }
  }

  Widget _buildHorariosSection() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (horarios.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Este entrenador no tiene horarios disponibles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchHorarios,
              child: Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    Map<String, List<Map<String, dynamic>>> horariosPorDia = {};
    for (var horario in horarios) {
      if (horario.containsKey('dia_semana')) {
        String dia = horario['dia_semana'] ?? 'Sin día';
        if (!horariosPorDia.containsKey(dia)) {
          horariosPorDia[dia] = [];
        }
        horariosPorDia[dia]!.add(horario);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Horarios Disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...horariosPorDia.entries.map((entry) {
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                ...entry.value.map((horario) {
                  bool isSelected = selectedHorario == horario;
                  return ListTile(
                    title: Text(
                      '${formatTimeString(horario['hora_inicio'] ?? '--:--')} - ${formatTimeString(horario['hora_fin'] ?? '--:--')}',
                      style: TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Cupo disponible: ${horario['cupo'] ?? 'N/A'} personas',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green[700])
                      : Icon(Icons.radio_button_unchecked),
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedHorario = isSelected ? null : horario;
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil del Entrenador'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[700],
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${widget.coach['nombre'] ?? ''} ${widget.coach['apellido_paterno'] ?? ''} ${widget.coach['apellido_materno'] ?? ''}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.coach['correo_electronico'] ?? 'No disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información Personal', [
                    _buildInfoRow('Edad', '${widget.coach['edad'] ?? 'N/A'} años'),
                    _buildInfoRow('Sexo', widget.coach['sexo'] ?? 'N/A'),
                    _buildInfoRow('Teléfono', widget.coach['numero_telefonico'] ?? 'N/A'),
                  ]),
                  SizedBox(height: 20),
                  _buildInfoSection('Descripción', [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.coach['descripcion'] ?? 'Sin descripción disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            _buildHorariosSection(),
            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _solicitarEntrenador(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            selectedHorario == null 
              ? 'Selecciona un horario' 
              : 'Solicitar Entrenador',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}