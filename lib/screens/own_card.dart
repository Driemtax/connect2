import 'dart:io';
import 'package:connect2/helper/contact_manager.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class OwnCardView extends StatefulWidget {
  final String phoneContactId;
  const OwnCardView({Key? key, required this.phoneContactId}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _OwnCardViewState createState() => _OwnCardViewState();
}

class _OwnCardViewState extends State<OwnCardView> {
  late String phoneContactId;
  late ContactManager _contactManager;
  FullContact? fullContact;
  bool _isLoading = true;
  late TextEditingController _residenceController;
  late TextEditingController _employerController;
  // General Information
  String _name = "";
  DateTime? _birthDate;
  String _residence = "";
  String _employer = "";

  // Skills
  final List<String> _skills = [];

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    phoneContactId = widget.phoneContactId;
    _contactManager = ContactManager.withId(phoneContactId);
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
      _name = fullContact!.phoneContact.displayName;

      String? date = fullContact?.phoneContact.events
      .firstWhere(
        (event) => event.label == EventLabel.birthday,
        orElse: () => Event(month: 0, day: 0),
      ).toString();
      _birthDate = date != null ? DateTime.tryParse(date) : null;

      _residence = fullContact?.phoneContact.addresses.isNotEmpty == true
      ? fullContact!.phoneContact.addresses.first.address
      : "";

      _employer = fullContact?.phoneContact.organizations.isNotEmpty == true
      ? fullContact!.phoneContact.organizations.first.company
      : "";

      // Controller
      _residenceController = TextEditingController(text: _residence);
      _employerController = TextEditingController(text: _employer);

      // Skills
      // TODO Add SKills here

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
        if (fullContact != null) {
          if (fullContact!.phoneContact.events.isNotEmpty) {
              fullContact!.phoneContact.events.first = Event(year: pickedDate.year, 
              month: pickedDate.month, day: pickedDate.day, label: EventLabel.birthday);
            }
            else {
              fullContact!.phoneContact.events.add(Event(year: pickedDate.year, 
              month: pickedDate.month, day: pickedDate.day, label: EventLabel.birthday));
            }

          _contactManager.updateFullContact(fullContact!);
          _birthDate = pickedDate;
        }
        else {
          throw Exception("fullContact is null");
        }
      });
    }
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
  Future<void> _showAddSkillDialog() async {
    String itemText = '';
    bool isError = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Neuen Skill hinzufügen'),
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
                      _addSkill(itemText);
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
                  onPressed: () => _showAddSkillDialog(),
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                ),
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
                if (fullContact != null) {
                  if (fullContact!.phoneContact.addresses.isNotEmpty) {
                    fullContact!.phoneContact.addresses.first = Address(newValue);
                  }
                  else {
                    fullContact!.phoneContact.addresses.add(Address(newValue));
                  }
                  _contactManager.updateFullContact(fullContact!);
                  _residence = newValue;
                }
                else {
                  throw Exception('fullContact is null');
                }
              }
              else if (label == 'Arbeitgeber / Uni') {
                if (fullContact != null) {
                  if (fullContact!.phoneContact.organizations.isNotEmpty) {
                    fullContact!.phoneContact.organizations.first.company = newValue;
                  }
                  else {
                    fullContact!.phoneContact.organizations.add(Organization(company: newValue));
                  }
                  _contactManager.updateFullContact(fullContact!);
                  _employer = newValue;
                }
                else {
                  throw Exception('fullContact is null');
                }
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