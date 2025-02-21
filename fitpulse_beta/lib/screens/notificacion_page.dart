import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificacionPage extends StatefulWidget {
  final String token;

  const NotificacionPage({Key? key, required this.token}) : super(key: key);

  @override
  _NotificacionPageState createState() => _NotificacionPageState();
}

class _NotificacionPageState extends State<NotificacionPage> {
  List<dynamic> solicitudes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSolicitudes();
  }

  Future<void> fetchSolicitudes() async {
    try {
      final response = await http.get(
        Uri.parse('https://beta-fit-pulse.onrender.com/solicitudes/1'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          solicitudes = [json.decode(response.body)]; // Convertimos la respuesta única en una lista
          isLoading = false;
        });
      } else {
        throw Exception('Error al obtener solicitudes: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _actualizarEstadoSolicitud(int idSolicitud, String nuevoEstado) async {
    try {
      final response = await http.put(
        Uri.parse('https://beta-fit-pulse.onrender.com/solicitudes/$idSolicitud'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${widget.token}",
        },
        body: json.encode({
          "estado": nuevoEstado,
        }),
      );

      if (response.statusCode == 200) {
        fetchSolicitudes(); // Recargar la lista de solicitudes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado actualizado correctamente')),
        );
      } else {
        throw Exception('Error al actualizar estado: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return '#FFA500'; // Naranja
      case 'aceptada':
        return '#4CAF50'; // Verde
      case 'rechazada':
        return '#F44336'; // Rojo
      default:
        return '#757575'; // Gris
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        backgroundColor: Colors.green[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : solicitudes.isEmpty
              ? Center(
                  child: Text(
                    'No hay notificaciones',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: solicitudes.length,
                  itemBuilder: (context, index) {
                    final solicitud = solicitudes[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(
                          'Solicitud de Entrenamiento',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text('Fecha: ${DateTime.parse(solicitud['fecha_solicitud']).toString().split('.')[0]}'),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(int.parse(_getEstadoColor(solicitud['estado']).substring(1, 7), radix: 16) + 0xFF000000),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                solicitud['estado'],
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'Aceptada',
                              child: Text('Aceptar'),
                            ),
                            PopupMenuItem(
                              value: 'Rechazada',
                              child: Text('Rechazar'),
                            ),
                          ],
                          onSelected: (String value) {
                            _actualizarEstadoSolicitud(solicitud['id_solicitud'], value);
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}