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
  bool isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    fetchHorarios();
  }

  Future<void> fetchHorarios() async {
    setState(() {
      isLoading = true;
    });

    try {
      final coachId = widget.coach['id_entrenador'];

      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/entrenador/$coachId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> coachHorarios = [];

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('horarios')) {
            coachHorarios = responseData['horarios'];
          } else if (responseData.containsKey('data')) {
            coachHorarios = responseData['data'];
          } else {
            coachHorarios = responseData.values.toList();
          }
        } else if (responseData is List<dynamic>) {
          coachHorarios = responseData;
        }

        setState(() {
          horarios = List<Map<String, dynamic>>.from(
            coachHorarios.map((item) =>
                item is Map<String, dynamic> ? item : <String, dynamic>{})
          );
          isLoading = false;
        });
      } else {
        throw Exception('Error en la petición: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar horarios: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _solicitarEntrenador() async {
    if (selectedHorario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un horario'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isSendingRequest = true;
    });

    try {
      // Verificar que los datos necesarios estén disponibles
      // Buscamos el ID de usuario usando la clave correcta (id_usuario)
      final userId = widget.userData['id_usuario'];
      if (userId == null) {
        // Intentar con otras posibles claves si id_usuario no está disponible
        final alternativeId = widget.userData['id'];
        
        if (alternativeId == null) {
          throw Exception('ID de usuario no disponible en los datos de usuario');
        }
        
        // Si encontramos un ID alternativo, lo usamos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usando ID alternativo del usuario'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
      final int scheduleId = selectedHorario!['id_horario'];
      final int coachId = widget.coach['id_entrenador'];
      
      // Imprimir datos para depuración
      print('Datos de usuario: ${widget.userData}');
      print('ID de usuario encontrado: $userId');
      print('ID de horario seleccionado: $scheduleId');
      print('ID de entrenador: $coachId');
      
      // Crear la estructura de la solicitud
      final Map<String, dynamic> solicitudData = {
        "id_usuario": userId,
        "id_horario": scheduleId,
        "id_entrenador": coachId,
        "estado": "Pendiente",
        "fecha_solicitud": DateTime.now().toIso8601String(),
      };

      print('Datos de solicitud a enviar: $solicitudData');

      // Enviar la solicitud al servidor
      final response = await http.post(
        Uri.parse('https://beta-fit-pulse.onrender.com/solicitudes'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode(solicitudData),
      );

      print('Respuesta del servidor: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Solicitud creada con éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Solicitud enviada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        // Esperar un momento para que el usuario vea el mensaje
        await Future.delayed(const Duration(seconds: 1));
        // Regresar a la pantalla anterior
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'] ?? 'Error al enviar la solicitud';
        throw Exception(errorMessage);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSendingRequest = false;
        });
      }
    }
  }

  String formatTimeString(String? timeString) {
    if (timeString == null) return '--:--';
    try {
      return timeString.substring(0, 5); // Extraer solo hh:mm
    } catch (e) {
      return timeString;
    }
  }

  Widget _buildHorariosSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (horarios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Este entrenador no tiene horarios disponibles actualmente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchHorarios,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    // Organizar horarios por día de la semana
    Map<String, List<Map<String, dynamic>>> horariosPorDia = {};
    
    // Orden de los días de la semana
    final ordenDias = {
      'Lunes': 1,
      'Martes': 2,
      'Miércoles': 3,
      'Jueves': 4,
      'Viernes': 5,
      'Sábado': 6,
      'Domingo': 7,
    };

    for (var horario in horarios) {
      String dia = horario['dia_semana'] ?? 'Sin día';
      if (!horariosPorDia.containsKey(dia)) {
        horariosPorDia[dia] = [];
      }
      horariosPorDia[dia]!.add(horario);
    }

    // Ordenar los días de la semana
    var diasOrdenados = horariosPorDia.keys.toList()
      ..sort((a, b) => (ordenDias[a] ?? 99).compareTo(ordenDias[b] ?? 99));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            'Horarios Disponibles',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        
        // Mostrar cada día con sus horarios
        ...diasOrdenados.map((dia) {
          final horariosDelDia = horariosPorDia[dia]!;
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            elevation: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[700],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    dia,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                ...horariosDelDia.map((horario) {
                  final bool isSelected = selectedHorario == horario;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedHorario = isSelected ? null : horario;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green[50] : Colors.transparent,
                        border: isSelected 
                            ? Border.all(color: Colors.green, width: 1) 
                            : null,
                        borderRadius: isSelected
                            ? BorderRadius.circular(4)
                            : null,
                      ),
                      child: ListTile(
                        title: Text(
                          '${formatTimeString(horario['hora_inicio'])} - ${formatTimeString(horario['hora_fin'])}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'Cupo: ${horario['cupo'] ?? 'No especificado'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle, color: Colors.green[700], size: 24)
                            : const Icon(Icons.circle_outlined, color: Colors.grey, size: 24),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }).toList(),
        
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil del Entrenador'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Perfil del entrenador
            Container(
              width: double.infinity,
              color: Colors.green[100],
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[700],
                    child: const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${widget.coach['nombre'] ?? ''} ${widget.coach['apellido_paterno'] ?? ''} ${widget.coach['apellido_materno'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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
            
            // Información personal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('Información Personal', [
                    _buildInfoRow('Edad', '${widget.coach['edad'] ?? 'N/A'} años'),
                    _buildInfoRow('Sexo', widget.coach['sexo'] ?? 'N/A'),
                    _buildInfoRow('Teléfono', widget.coach['numero_telefonico'] ?? 'N/A'),
                    _buildInfoRow('ID Entrenador', '${widget.coach['id_entrenador'] ?? 'N/A'}'),
                  ]),
                  const SizedBox(height: 20),
                  _buildInfoSection('Descripción', [
                    Container(
                      padding: const EdgeInsets.all(12),
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
            
            // Horarios
            _buildHorariosSection(),
            
            // Espacio para no quedar oculto por el botón
            const SizedBox(height: 80),
          ],
        ),
      ),
      
      // Botón para solicitar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isSendingRequest ? null : _solicitarEntrenador,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            disabledBackgroundColor: Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: isSendingRequest
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Procesando...',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
              : Text(
                  selectedHorario == null
                      ? 'Selecciona un horario'
                      : 'Solicitar Entrenador',
                  style: const TextStyle(
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
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}