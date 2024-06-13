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
    FbUsuario usuario = await conexion.fbadmin.conseguirUsuario();
    setState(() {
      perfil = usuario;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendario de Eventos'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
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
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEventsFromFirebase();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

  void _addEvent(DateTime day, Event event) {
    setState(() {
      if (_events.containsKey(day)) {
        _events[day]!.add(event);
      } else {
        _events[day] = [event];
      }
    });
  }

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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar<Event>(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                if (_eventController.text.isNotEmpty) {
                  _addEvent(_selectedDay!, Event(_eventController.text));
                  _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  _eventController.clear();
                }
              },
              child: Text('Añadir Evento'),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                await _saveEventsToFirebase();
              },
              child: Text('Guardar Cambios'),
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8.0),
            ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text('${value[index].title}'),
                        leading: Icon(Icons.event, color: Colors.deepPurple),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }
}

class Event {
  final String title;
  Event(this.title);
}