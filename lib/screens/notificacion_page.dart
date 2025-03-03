import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class NotificacionPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;
  final String tipo;

  const NotificacionPage({
    Key? key,
    required this.token,
    required this.userData,
    required this.tipo,
  }) : super(key: key);

  @override
  _NotificacionPageState createState() => _NotificacionPageState();
}

class _NotificacionPageState extends State<NotificacionPage> {
  List<Map<String, dynamic>> solicitudes = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';
  Map<int, Map<String, dynamic>> horariosCache = {};
  Map<int, Map<String, dynamic>> usuariosCache = {};
  Map<int, Map<String, dynamic>> entrenadoresCache = {};

  @override
  void initState() {
    super.initState();
    fetchSolicitudes();
  }

  Future<void> fetchSolicitudes() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      final id = widget.userData['id'] ??
          widget.userData['id_usuario'] ??
          widget.userData['id_entrenador'];

      if (id == null) {
        throw Exception('No se pudo encontrar el ID del usuario');
      }

      String endpoint;
      if (widget.tipo == 'entrenador') {
        endpoint =
            'https://beta-fit-pulse.onrender.com/solicitudes/entrenador/$id';
      } else {
        endpoint =
            'https://beta-fit-pulse.onrender.com/solicitudes/usuario/$id';
      }

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        List<dynamic> solicitudesList = [];

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('solicitudes')) {
            solicitudesList = responseData['solicitudes'];
          } else if (responseData.containsKey('data')) {
            solicitudesList = responseData['data'];
          } else {
            solicitudesList = responseData.values.first is List
                ? responseData.values.first
                : [responseData];
          }
        } else if (responseData is List<dynamic>) {
          solicitudesList = responseData;
        }

        // Convertir a Lista de Maps
        List<Map<String, dynamic>> solicitudesMaps =
            List<Map<String, dynamic>>.from(solicitudesList.map((item) =>
                item is Map<String, dynamic> ? item : <String, dynamic>{}));

        // Ordenar solicitudes por fecha (más recientes primero)
        solicitudesMaps.sort((a, b) {
          DateTime dateA = DateTime.parse(a['fecha_solicitud'] ?? '2000-01-01');
          DateTime dateB = DateTime.parse(b['fecha_solicitud'] ?? '2000-01-01');
          return dateB.compareTo(dateA);
        });

        setState(() {
          solicitudes = solicitudesMaps;
          isLoading = false;
        });

        // Obtener detalles adicionales para cada solicitud
        for (var solicitud in solicitudes) {
          await _fetchAdditionalData(solicitud);
        }
      } else {
        throw Exception(
            'Error en la petición: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = 'Error al cargar solicitudes: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchAdditionalData(Map<String, dynamic> solicitud) async {
    // Fetch horario details
    if (solicitud['id_horario'] != null) {
      await _fetchHorarioDetails(solicitud['id_horario']);
    }

    // Fetch usuario details if we're an entrenador
    if (widget.tipo == 'entrenador' && solicitud['id_usuario'] != null) {
      await _fetchUsuarioDetails(solicitud['id_usuario']);
    }

    // Fetch entrenador details if we're a usuario
    if (widget.tipo != 'entrenador' && solicitud['id_entrenador'] != null) {
      await _fetchEntrenadorDetails(solicitud['id_entrenador']);
    }
  }

  Future<void> _fetchHorarioDetails(int horarioId) async {
    // Skip if we already have this horario cached
    if (horariosCache.containsKey(horarioId)) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/$horarioId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> horarioData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('horario')) {
            horarioData = responseData['horario'];
          } else if (responseData.containsKey('data')) {
            horarioData = responseData['data'];
          } else {
            horarioData = responseData;
          }
        } else {
          throw Exception('Formato de respuesta inesperado');
        }

        setState(() {
          horariosCache[horarioId] = horarioData;
        });
      }
    } catch (e) {
      print('Error al obtener detalles del horario $horarioId: $e');
    }
  }

  Future<void> _fetchUsuarioDetails(int usuarioId) async {
    // Skip if we already have this usuario cached
    if (usuariosCache.containsKey(usuarioId)) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/usuarios/$usuarioId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> usuarioData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('usuario')) {
            usuarioData = responseData['usuario'];
          } else if (responseData.containsKey('data')) {
            usuarioData = responseData['data'];
          } else {
            usuarioData = responseData;
          }
        } else {
          throw Exception('Formato de respuesta inesperado');
        }

        setState(() {
          usuariosCache[usuarioId] = usuarioData;
        });
      }
    } catch (e) {
      print('Error al obtener detalles del usuario $usuarioId: $e');
    }
  }

  Future<void> _fetchEntrenadorDetails(int entrenadorId) async {
    // Skip if we already have this entrenador cached
    if (entrenadoresCache.containsKey(entrenadorId)) {
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://beta-fit-pulse.onrender.com/entrenadores/$entrenadorId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Handle different response structures
        Map<String, dynamic> entrenadorData;
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('entrenador')) {
            entrenadorData = responseData['entrenador'];
          } else if (responseData.containsKey('data')) {
            entrenadorData = responseData['data'];
          } else {
            entrenadorData = responseData;
          }
        } else {
          throw Exception('Formato de respuesta inesperado');
        }

        setState(() {
          entrenadoresCache[entrenadorId] = entrenadorData;
        });
      }
    } catch (e) {
      print('Error al obtener detalles del entrenador $entrenadorId: $e');
    }
  }

  Future<void> _actualizarEstadoSolicitud(
      int solicitudId, String nuevoEstado) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://beta-fit-pulse.onrender.com/solicitudes/$solicitudId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode({
          "estado": nuevoEstado,
        }),
      );

      if (response.statusCode == 200) {
        // Actualizar el estado localmente
        setState(() {
          for (var i = 0; i < solicitudes.length; i++) {
            if (solicitudes[i]['id_solicitud'] == solicitudId) {
              solicitudes[i]['estado'] = nuevoEstado;
              break;
            }
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Solicitud $nuevoEstado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(
            'Error al actualizar: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la solicitud: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Fecha desconocida';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aceptada':
        return Colors.green;
      case 'rechazada':
        return Colors.red;
      case 'pendiente':
        return Colors.orange;
      case 'completada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildHorarioInfo(int? horarioId) {
    if (horarioId == null) return const Text('Horario no disponible');

    final horario = horariosCache[horarioId];
    if (horario == null)
      return const Text('Cargando información del horario...');

    // Formatear horas y obtener el día
    String horaInicio = horario['hora_inicio'] != null
        ? horario['hora_inicio'].toString().substring(0, 5)
        : '--:--';
    String horaFin = horario['hora_fin'] != null
        ? horario['hora_fin'].toString().substring(0, 5)
        : '--:--';
    String dia = horario['dia_semana'] ?? 'No especificado';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              dia,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text('$horaInicio - $horaFin'),
          ],
        ),
      ],
    );
  }

  Widget _buildPersonInfo(int? personId, bool isEntrenador) {
    if (personId == null) {
      return const Text('Información no disponible');
    }

    final personData =
        isEntrenador ? entrenadoresCache[personId] : usuariosCache[personId];

    if (personData == null) {
      return const Text('Cargando información...');
    }

    String nombre = personData['nombre'] ?? '';
    String apellidoP = personData['apellido_paterno'] ?? '';
    String apellidoM = personData['apellido_materno'] ?? '';
    String nombreCompleto = '$nombre $apellidoP $apellidoM'.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person, size: 16, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              nombreCompleto.isNotEmpty
                  ? nombreCompleto
                  : 'Nombre no disponible',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (personData['correo_electronico'] != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.email, size: 16, color: Colors.green[700]),
              const SizedBox(width: 4),
              Text(personData['correo_electronico']),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildNoSolicitudes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 70,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes solicitudes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.tipo == 'entrenador'
                  ? 'Cuando los usuarios te soliciten, aparecerán aquí'
                  : 'Cuando solicites un entrenador, aparecerán aquí',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: fetchSolicitudes,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.green[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchSolicitudes,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ocurrió un error',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: fetchSolicitudes,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reintentar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                )
              : solicitudes.isEmpty
                  ? _buildNoSolicitudes()
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: solicitudes.length,
                      itemBuilder: (context, index) {
                        final solicitud = solicitudes[index];
                        final estado = solicitud['estado'] ?? 'Desconocido';
                        final fechaSolicitud =
                            _formatDate(solicitud['fecha_solicitud']);
                        final solicitudId = solicitud['id_solicitud'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.tipo == 'entrenador'
                                            ? 'Solicitud de entrenamiento'
                                            : 'Tu solicitud de entrenamiento',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(estado)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: _getStatusColor(estado),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        estado,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: _getStatusColor(estado),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                const Text(
                                  'Detalles de la solicitud:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Mostrar información según el tipo de usuario
                                if (widget.tipo == 'entrenador') ...[
                                  // Si somos entrenador, mostramos datos del alumno
                                  const Text(
                                    'Solicitado por:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildPersonInfo(
                                      solicitud['id_usuario'], false),
                                ] else ...[
                                  // Si somos alumno, mostramos datos del entrenador
                                  const Text(
                                    'Entrenador:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  _buildPersonInfo(
                                      solicitud['id_entrenador'], true),
                                ],

                                const SizedBox(height: 12),
                                const Text(
                                  'Horario solicitado:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                _buildHorarioInfo(solicitud['id_horario']),

                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Solicitud realizada: $fechaSolicitud',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),

                                // Botones de acción solo para entrenadores y solicitudes pendientes
                                if (widget.tipo == 'entrenador' &&
                                    estado.toLowerCase() == 'pendiente') ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () =>
                                            _actualizarEstadoSolicitud(
                                                solicitudId, 'Rechazada'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                              color: Colors.red),
                                        ),
                                        child: const Text('Rechazar'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () =>
                                            _actualizarEstadoSolicitud(
                                                solicitudId, 'Aceptada'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green[700],
                                        ),
                                        child: const Text('Aceptar'),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
