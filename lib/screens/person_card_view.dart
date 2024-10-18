import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Für die Datumformatierung

class PersonCardView extends StatefulWidget {
  const PersonCardView({super.key});

  @override
  _PersonCardViewState createState() => _PersonCardViewState();
}

class _PersonCardViewState extends State<PersonCardView> {
  // Liste der Notizen
  final List<Note> _notizenListe = [
    Note(date: '01.01.2023', text: 'Erste Notiz'),
    Note(date: '02.01.2023', text: 'Zweite Notiz'),
    Note(date: '03.01.2023', text: 'Dritte Notiz'),
  ];

  // Methode zum Hinzufügen einer neuen Notiz
  void _addNotiz(String newText) {
    setState(() {
      String formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
      _notizenListe.add(Note(date: formattedDate, text: newText));
    });
  }

  // Methode zum Anzeigen eines Dialogs, um den Benutzer nach dem Notiztext zu fragen
  Future<void> _showAddNoteDialog() async {
  String noteText = '';
  bool isError = false; // Zum Überwachen des Fehlerstatus

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Neue Notiz hinzufügen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Notiz eingeben",
                    errorText: isError ? 'Notiz darf nicht leer sein' : null, // Fehlermeldung anzeigen, wenn leer
                  ),
                  onChanged: (value) {
                    setState(() {
                      noteText = value;
                      if (value.isNotEmpty) {
                        isError = false; // Fehlerstatus zurücksetzen, wenn Text eingegeben wird
                      }
                    });
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Abbrechen'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Hinzufügen'),
                onPressed: () {
                  if (noteText.isEmpty) {
                    // Fehlerstatus aktivieren und den Dialog nicht schließen
                    setState(() {
                      isError = true;
                    });
                  } else {
                    _addNotiz(noteText);
                    Navigator.of(context).pop(); // Dialog schließen, wenn die Eingabe korrekt ist
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    // Greife auf das Farbschema des übergeordneten Themas zu
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Detail View'),
        backgroundColor: colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Bearbeiten-Funktion
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto der Person (Platzhalter)
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 100, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Jannis Neuhaus",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16), // Abstand zwischen den Elementen

              // Box mit allgemeinen Informationen
              SizedBox(
                width: double.infinity, // Maximale Breite der Box
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Allgemeine Informationen:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow("Geburtsdatum", "01.01.1990", colorScheme),
                        const SizedBox(height: 8),
                        _buildInfoRow("Wohnort", "Berlin", colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Box mit einer Liste von Skills
              SizedBox(
                width: double.infinity, // Maximale Breite der Box
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Skills:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('- Flutter Development'),
                        const Text('- Dart Programming'),
                        const Text('- UI/UX Design'),
                        const Text('- C Programmierung'),
                        const Text('- Objektorientierte Programmierung'),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Box mit Notizen
              SizedBox(
                width: double.infinity, // Maximale Breite der Box
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notizen:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _notizenListe.length,
                          itemBuilder: (context, index) {
                            final notiz = _notizenListe[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    notiz.date,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      notiz.text,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        backgroundColor: colorScheme.primaryContainer,
        child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
      ),
    );
  }

  // Hilfsmethode zum Erstellen von Info-Reihen
  Widget _buildInfoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            "$label:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// Klasse für die Notizen
class Note {
  final String date;
  final String text;

  Note({required this.date, required this.text});
}
