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
  final List<String> diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  @override
  void initState() {
    super.initState();
    fetchHorarios();
  }

  Future<void> fetchHorarios() async {
    try {
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/${widget.userData['id']}'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          horarios = List<Map<String, dynamic>>.from(data);
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
      "dia": selectedDay,
      "hora_inicio": "${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}",
      "hora_fin": "${endTime!.hour}:${endTime!.minute.toString().padLeft(2, '0')}",
      "entrenador_id": widget.userData['id']
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
        Navigator.pop(context);
      } else {
        throw Exception('Error al crear horario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear horario: $e')),
      );
    }
  }

  Future<void> eliminarHorario(String horarioId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://beta-fit-pulse.onrender.com/horarios/$horarioId'),
        headers: {
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        fetchHorarios();
      } else {
        throw Exception('Error al eliminar horario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar horario: $e')),
      );
    }
  }

  void _showAddHorarioModal() {
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
                    'Agregar Nuevo Horario',
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
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: agregarHorario,
                    child: Text('Guardar Horario'),
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
                  (horario) => horario['dia'] == dia
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
                          '${horario['hora_inicio']} - ${horario['hora_fin']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => eliminarHorario(horario['id'].toString()),
                        ),
                      )).toList(),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddHorarioModal,
        child: Icon(Icons.add),
        backgroundColor: Colors.green[700],
      ),
    );
  }
}