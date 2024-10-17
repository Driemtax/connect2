import 'package:flutter/material.dart';

class PersonCardView extends StatelessWidget {
  const PersonCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Detail View'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Bearbeiten-Funktion
              // Implementiere hier deine Logik zum Bearbeiten der Daten
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Scrollable Container
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Foto der Person (Platzhalter als leeres Rechteck)
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3, // 1/3 der Bildschirmhöhe
                color: Colors.grey[300], // Platzhalter Farbe
                child: const Center(
                  child: Icon(Icons.person, size: 100, color: Colors.grey), // Person Icon als Platzhalter
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text("Jannis Neuhaus", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16), // Abstand zwischen den Elementen

              // Box mit allgemeinen Informationen
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green[100], // Farbe der Box
                  borderRadius: BorderRadius.circular(10), // Abgerundete Ecken
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                  'Allgemeine Informationen:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Name: ", style: TextStyle(fontSize: 14),
                ),
                Text(
                  "Vorname: ", style: TextStyle(fontSize: 14),
                ),
                Text(
                  "Geburtsdatum: ", style: TextStyle(fontSize: 14),
                ),
                Text(
                  "Wohnort: ", style: TextStyle(fontSize: 14),
                )]
                ) ,
              ),
              const SizedBox(height: 16), // Abstand zwischen den Boxen

              // Box mit einer Liste von Skills
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skills:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    // Beispielhafte Auflistung von Skills
                    Text('- Flutter Development'),
                    Text('- Dart Programming'),
                    Text('- UI/UX Design'),
                    Text('- C Programmierung'),
                    Text('- Objektorientierte Programmierung'),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Abstand zwischen den Boxen

              // Box mit Notizen und kleinem Plus-Button unten rechts
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notizen:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('1. Erste Notiz'),
                        Text('2. Zweite Notiz'),
                        Text('3. Zweite Notiz'),
                        Text('4. Zweite Notiz'),
                        Text('5. Zweite Notiz'),
                        Text('6. Zweite Notiz'),
                        Text('7. Zweite Notiz'),
                        Text('8. Zweite Notiz'),
                        Text('9. Zweite Notiz')
                      ],
                    ),
                    // Kleiner Plus-Button unten rechts
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: FloatingActionButton(
                        mini: true, // Kleiner Button
                        onPressed: () {
                          // Logik zum Hinzufügen einer neuen Notiz
                        },
                        child: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PersonCardView(),
    debugShowCheckedModeBanner: false,
  ));
}
