import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../FirebaseObjects/FbUsuario.dart';
import '../Singletone/DataHolder.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TableCalendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  FbUsuario perfil = FbUsuario(
      nombre: "nombre", apellidos: "apellidos", id: "id", shint: "shint");
  DataHolder conexion = DataHolder();

  @override
  void initState() {
    super.initState();
    conseguirUsuario();
  }

  Future<void> conseguirUsuario() async {
    print("Fetching user: " +
        perfil.nombre +
        perfil.shint +
        perfil.id +
        perfil.apellidos);

    FbUsuario usuario = await conexion.fbadmin.conseguirUsuario();
    setState(() {
      perfil = usuario;
    });

    print("Fetched user: " +
        perfil.nombre +
        perfil.shint +
        perfil.id +
        perfil.apellidos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar Example'),
      ),
      body: perfil.id != "id"
          ? Center(
        child: TableBasicsExample(userId: perfil.id),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class TableBasicsExample extends StatefulWidget {
  final String userId;

  TableBasicsExample({required this.userId});

  @override
  _TableBasicsExampleState createState() => _TableBasicsExampleState();
}

class _TableBasicsExampleState extends State<TableBasicsExample> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _eventController = TextEditingController();

  // Mapa de eventos, donde cada día está asociado con una lista de eventos
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEventsFromFirebase(); // Cargar eventos desde Firebase al iniciar
  }

  // Obtiene los eventos para un día específico
  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  // Añade un evento para un día específico
  void _addEvent(DateTime day, Event event) {
    setState(() {
      if (_events.containsKey(day)) {
        _events[day]!.add(event);
      } else {
        _events[day] = [event];
      }
    });
  }

  // Guarda todos los eventos en Firebase
  Future<void> _saveEventsToFirebase() async {
    final userEventsCollection = FirebaseFirestore.instance
        .collection('event')
        .doc(widget.userId)
        .collection('events');

    for (var entry in _events.entries) {
      await userEventsCollection.doc(entry.key.toIso8601String()).set({
        'date': entry.key.toIso8601String(),
        'events': entry.value.map((e) => e.title).toList(),
      });
    }
  }

  // Cargar eventos desde Firebase
  Future<void> _loadEventsFromFirebase() async {
    final userEventsCollection = FirebaseFirestore.instance
        .collection('event')
        .doc(widget.userId)
        .collection('events');

    final snapshot = await userEventsCollection.get();
    final eventsMap = <DateTime, List<Event>>{};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final date = DateTime.parse(data['date']);
      final events = (data['events'] as List<dynamic>)
          .map((e) => Event(e as String))
          .toList();
      eventsMap[date] = events;
    }

    setState(() {
      _events = eventsMap;
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar<Event>(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _getEventsForDay,
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
          ),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            _selectedEvents.value = _getEventsForDay(selectedDay);
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _eventController,
            decoration: InputDecoration(
              labelText: 'Título del Evento',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () {
            if (_eventController.text.isNotEmpty) {
              // Añade un evento al día seleccionado
              _addEvent(_selectedDay!, Event(_eventController.text));
              // Actualiza la lista de eventos para el día seleccionado
              _selectedEvents.value = _getEventsForDay(_selectedDay!);
              // Borra el texto del controlador del campo de texto
              _eventController.clear();
            }
          },
          child: Text('Añadir Evento'),
        ),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: () async {
            // Guarda todos los eventos en Firebase
            await _saveEventsToFirebase();
          },
          child: Text('Guardar en Firebase'),
        ),
        const SizedBox(height: 8.0),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${value[index].title}'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _eventController.dispose(); // Libera el controlador del campo de texto
    super.dispose();
  }
}

class Event {
  final String title;
  Event(this.title);
}