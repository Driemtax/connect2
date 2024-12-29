import 'dart:io';
import 'package:connect2/helper/contact_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connect2/models/note.dart';
import 'package:connect2/main.dart';

class PersonCardView extends StatefulWidget {
  final int contactId;
  const PersonCardView({Key? key, required this.contactId}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _PersonCardViewState createState() => _PersonCardViewState();
}

class _PersonCardViewState extends State<PersonCardView> {
  late int contactId;
  late ContactManager _contactManager;
  bool _isLoading = true;
  late TextEditingController _residenceController;
  late TextEditingController _employerController;
  
  String _name = "";
  DateTime? _birthDate;
  String _residence = "";
  String _employer = "";
  // Notes
  final List<Note> _noteList = [];

  // Skills
  final List<String> _skills = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    contactId = widget.contactId;
    _contactManager = ContactManager.withId(contactId);
    _initializeData();
    
  }

  @override
  void dispose() {
    _residenceController.dispose();
    _employerController.dispose();
    super.dispose();
  }
  
  Future<void> _initializeData() async {
    await _contactManager.loadContactFromDatabase();
    setState(() {
      _name = _contactManager.contactData["name"] ?? "";
      _birthDate = _contactManager.contactData["birthDate"];
      _residence = _contactManager.contactData["residence"] ?? "";
      _employer = _contactManager.contactData["employer"] ?? "";

      // Controller
      _residenceController = TextEditingController(text: _residence);
      _employerController = TextEditingController(text: _employer);

      // Notes
      _noteList.clear();
      final List<Map<String, dynamic>> notesFromDb = _contactManager.contactData["notes"] ?? [];
      for (var noteData in notesFromDb) {
        _noteList.add(Note(
          date: noteData["date"] ?? "",
          text: noteData["text"] ?? "",
        ));
      }


      // Skills
      _skills.clear();
      final List<String> skillsFromDb = _contactManager.contactData["skills"] ?? [];
      _skills.addAll(skillsFromDb);

      _isLoading = false;
    });
  }

  Future<void> _pickBirthDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context, 
      initialDate: _birthDate ?? DateTime.now(), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      );

    if (pickedDate != null){
      setState(() {
        _birthDate = pickedDate;
        _contactManager.updateContactField('birthDate', pickedDate.toIso8601String());
      });
    }
  }

  void _addNote(String newText) {
    setState(() {
      String formattedDate = DateFormat('dd.MM.yyyy').format(DateTime.now());
      _noteList.add(Note(date: formattedDate, text: newText));
      _contactManager.updateContactField('notes', _noteList.map((note) => note.toJson()).toList());
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _noteList.removeAt(index);
      _contactManager.updateContactField('notes', _noteList.map((note) => note.toJson()).toList());
    });
  }

  void _addSkill(String newSkill){
    setState(() {
      _skills.add(newSkill);
      _contactManager.updateContactField('skills', _skills);
    });
  }

  void _deleteSkill(int index){
    setState(() {
      _skills.removeAt(index);
      _contactManager.updateContactField('skills', _skills);
    });
  }

  /// This method shows a pop up to create a new entry to a list. This is used for the skills and the notes.
  /// The input field is not allowed to be empty.
  Future<void> _showAddItemDialog(Function(String) onAdd ) async {
    String itemText = '';
    bool isError = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Neues Item hinzufügen'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Text eingeben",
                      errorText: isError ? 'Feld darf nicht leer sein' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        itemText = value;
                        if (value.isNotEmpty) {
                          isError = false;
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
                    if (itemText.isEmpty) {
                      setState(() {
                        isError = true;
                      });
                    } else {
                      onAdd(itemText);
                      Navigator.of(context).pop();
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

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus status;

    if (source == ImageSource.camera){
      status = await Permission.camera.request();
    }
    else {
      status = await Permission.photos.request();
    }

    if (status.isGranted){
      try {
        final pickedFile = await _picker.pickImage(source: source);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
            _contactManager.updateContactField('imagePath', pickedFile.path);
          });
        } else if (status.isDenied || status.isPermanentlyDenied) {
          _showPermissionDialog(source);
        }
      } catch (e) {
        print("Fehler beim Aufnehmen oder Laden des Bildes: $e");
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Keine Berechtigung für ${source == ImageSource.camera ? "Kamera" : "Galerie"} erteilt.'),
      ),
    );
    }    
  }
  
  void _showPermissionDialog(ImageSource source) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Berechtigung benötigt'),
        content: const Text(
            'Diese Berechtigung wird benötigt, um auf die Kamera oder die Galerie zugreifen zu können.'),
        actions: [
          TextButton(
            child: const Text('Abbrechen'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Zu den Einstellungen'),
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
          ),
        ],
      );
    },
  );
}

/// Shows the Dialog to select between Camera and Gallery of the phone. Only opens the selected source if the user gives permission to do so
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Galerie'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontakt'),
        backgroundColor: colorScheme.primary,
        foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _showImageSourceDialog,
                child: Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.25,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Icon(Icons.person, size: 100, color: Colors.grey),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Allgemeine Informationen
              _buildInfoCard(
                colorScheme,
                'Allgemeine Informationen',
                [
                  _buildDatePickerRow("Geburtsdatum", _birthDate, colorScheme),
                  const SizedBox(height: 8),
                  _buildEditableInfoRow("Wohnort", _residence, colorScheme),
                  const SizedBox(height: 8),
                  _buildEditableInfoRow("Arbeitgeber / Uni", _employer, colorScheme)
                ],
              ),

              const SizedBox(height: 16),

              // Skills
              _buildInfoCard(
                colorScheme,
                'Fähigkeiten',
                [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _skills.length,
                    itemBuilder: (context, index) {
                      final skill = _skills[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          _deleteSkill(index);
                        },
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.only(left: 16),
                          alignment: Alignment.centerLeft,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
                                initialValue: skill,
                                readOnly: true,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                floatingActionButton: FloatingActionButton.small(
                  onPressed: () => _showAddItemDialog(_addSkill),
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                ),
              ),          

              // Notizen
              _buildInfoCard(
                colorScheme,
                'Notizen',
                [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _noteList.length,
                    itemBuilder: (context, index) {
                      final notiz = _noteList[index];
                      return Dismissible(
                        key: UniqueKey(),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          _deleteNote(index);
                        },
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.only(left: 16),
                          alignment: Alignment.centerLeft,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notiz.date,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: notiz.text,
                                readOnly: true,
                                maxLines: null,
                                style: TextStyle(color: colorScheme.onSurfaceVariant),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                floatingActionButton: 
                  FloatingActionButton.small(
                  onPressed: () => _showAddItemDialog(_addNote),
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePickerRow(String label, DateTime? date, ColorScheme colorScheme){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4,),
        InkWell(
          onTap: _pickBirthDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(color: colorScheme.primary),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date != null ? DateFormat('dd.MM.yyyy').format(date) : "",
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildInfoCard(ColorScheme colorScheme, String title, List<Widget> content, {FloatingActionButton? floatingActionButton}) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: colorScheme.primary,
                width: 1.0,
                style: BorderStyle.solid)
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$title:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...content,
                ],
              ),
            ),
          ),
        ),
        if (floatingActionButton != null)
        Positioned(
            bottom: 16,
            right: 16,
            child: floatingActionButton,
          ),
      ],
    );
  }

  Widget _buildEditableInfoRow(String? label, String value, ColorScheme colorScheme) {
    if (label == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: value,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    TextEditingController controller;
    if (label == 'Wohnort') {
      controller = _residenceController;
    }
    else if (label == 'Arbeitgeber / Uni'){
      controller = _employerController;
    }
    else {
      controller = TextEditingController(text: value); // Fallback
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$label:",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: (newValue) {
            setState(() {
              if (label == 'Wohnort') {
                _residence = newValue;
                _contactManager.updateContactField('residence', newValue);
              }
              else if (label == 'Arbeitgeber / Uni') {
                _employer = newValue;
                _contactManager.updateContactField('employer', newValue);
              }
            });
          },
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}