import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HorariosPage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> userData;

  const HorariosPage({
    Key? key,
    required this.token,
    required this.userData,
  }) : super(key: key);

  @override
  _HorariosPageState createState() => _HorariosPageState();
}

class _HorariosPageState extends State<HorariosPage> {
  List<Map<String, dynamic>> horarios = [];
  bool isLoading = true;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String selectedDay = 'Lunes';
  int selectedCupo = 10;
  final List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  final List<int> cuposDisponibles = List.generate(20, (index) => index + 1);

  @override
  void initState() {
    super.initState();
    fetchHorarios();
  }

  String formatTimeString(String timeString) {
    // Extraer solo la hora y los minutos del formato "HH:MM:SS"
    return timeString.substring(0, 5);
  }
Future<void> fetchHorarios() async {
  try {
    final response = await http.get(
      Uri.parse('https://beta-fit-pulse.onrender.com/horarios/entrenador/${widget.userData['id_entrenador']}'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Verifica el formato de la respuesta
      List<dynamic> horariosEntrenador;
      
      if (data is Map<String, dynamic> && data.containsKey('horarios')) {
        // Si la respuesta es un objeto con una propiedad 'horarios'
        horariosEntrenador = data['horarios'];
      } else if (data is List<dynamic>) {
        // Si la respuesta ya es una lista
        horariosEntrenador = data;
      } else {
        // Para depurar, imprime la estructura de la respuesta
        print('Formato de respuesta inesperado: ${response.body}');
        throw Exception('Formato de respuesta no reconocido');
      }
      
      setState(() {
        horarios = List<Map<String, dynamic>>.from(horariosEntrenador);
        isLoading = false;
      });
    } else {
      throw Exception('Error al cargar horarios');
    }
  } catch (e) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar horarios: $e')),
    );
    // Para depuración
    print('Excepción completa: $e');
  }
}
Future<void> agregarHorario() async {
  if (startTime == null || endTime == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Por favor selecciona hora de inicio y fin')),
    );
    return;
  }

  final horarioNuevo = {
    "id_entrenador": widget.userData['id_entrenador'],
    "dia_semana": selectedDay,
    "hora_inicio": "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00",
    "hora_fin": "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00",
    "cupo": selectedCupo
  };

  try {
    final response = await http.post(
      Uri.parse('https://beta-fit-pulse.onrender.com/horarios'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${widget.token}",
      },
      body: json.encode(horarioNuevo),
    );

    if (response.statusCode == 201) {
      fetchHorarios();
      Navigator.pop(context); // Cierra la pantalla actual

      // Usa Future.delayed para esperar antes de mostrar el mensaje
      Future.delayed(Duration(milliseconds: 300), () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Horario creado exitosamente')),
        );
      });
    } else {
      throw Exception('Error al crear horario');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al crear horario: $e')),
    );
  }
}

  Future<void> actualizarHorario(int horarioId) async {
    if (startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona hora de inicio y fin')),
      );
      return;
    }

    final horarioActualizado = {
      "id_entrenador": widget.userData['id_entrenador'],
      "dia_semana": selectedDay,
      "hora_inicio": "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}:00",
      "hora_fin": "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}:00",
      "cupo": selectedCupo
    };

    try {
      final response = await http.put(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/$horarioId'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode(horarioActualizado),
      );

      if (response.statusCode == 200) {
        fetchHorarios();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Horario actualizado exitosamente')),
        );
      } else {
        throw Exception('Error al actualizar horario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar horario: $e')),
      );
    }
  }

  Future<void> eliminarHorario(int horarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/$horarioId'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        fetchHorarios();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Horario eliminado exitosamente')),
        );
      } else {
        throw Exception('Error al eliminar horario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar horario: $e')),
      );
    }
  }

  void _showHorarioModal({Map<String, dynamic>? horarioExistente}) {
    if (horarioExistente != null) {
      // Pre-fill the form with existing data
      selectedDay = horarioExistente['dia_semana'];
      final horaInicio = horarioExistente['hora_inicio'].toString().split(':');
      final horaFin = horarioExistente['hora_fin'].toString().split(':');
      
      startTime = TimeOfDay(
        hour: int.parse(horaInicio[0]),
        minute: int.parse(horaInicio[1])
      );
      endTime = TimeOfDay(
        hour: int.parse(horaFin[0]),
        minute: int.parse(horaFin[1])
      );
      selectedCupo = horarioExistente['cupo'];
    } else {
      // Reset form for new entry
      startTime = null;
      endTime = null;
      selectedCupo = 10;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    horarioExistente != null ? 'Editar Horario' : 'Agregar Nuevo Horario',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedDay,
                    decoration: InputDecoration(
                      labelText: 'Día de la semana',
                      border: OutlineInputBorder(),
                    ),
                    items: diasSemana.map((String dia) {
                      return DropdownMenuItem(
                        value: dia,
                        child: Text(dia),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setModalState(() {
                        selectedDay = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    title: Text('Hora de inicio'),
                    trailing: Text(startTime?.format(context) ?? 'Seleccionar'),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: startTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setModalState(() => startTime = time);
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Hora de fin'),
                    trailing: Text(endTime?.format(context) ?? 'Seleccionar'),
                    onTap: () async {
                      final TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: endTime ?? TimeOfDay.now(),
                      );
                      if (time != null) {
                        setModalState(() => endTime = time);
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    value: selectedCupo,
                    decoration: InputDecoration(
                      labelText: 'Cupo máximo',
                      border: OutlineInputBorder(),
                    ),
                    items: cuposDisponibles.map((int cupo) {
                      return DropdownMenuItem(
                        value: cupo,
                        child: Text(cupo.toString()),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      setModalState(() {
                        selectedCupo = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (horarioExistente != null) {
                        actualizarHorario(horarioExistente['id_horario']);
                      } else {
                        agregarHorario();
                      }
                    },
                    child: Text(horarioExistente != null ? 'Actualizar Horario' : 'Guardar Horario'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                  SizedBox(height: 20),
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
      appBar: AppBar(
        title: Text('Mis Horarios'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: diasSemana.length,
              itemBuilder: (context, index) {
                final dia = diasSemana[index];
                final horariosDelDia = horarios.where(
                  (horario) => horario['dia_semana'] == dia
                ).toList();

                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          dia,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (horariosDelDia.isEmpty)
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No hay horarios programados',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ...horariosDelDia.map((horario) => ListTile(
                        title: Text(
                          '${formatTimeString(horario['hora_inicio'])} - ${formatTimeString(horario['hora_fin'])}',
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          'Cupo: ${horario['cupo']} personas',
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showHorarioModal(horarioExistente: horario),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => eliminarHorario(horario['id_horario']),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showHorarioModal(),
        child: Icon(Icons.add),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}