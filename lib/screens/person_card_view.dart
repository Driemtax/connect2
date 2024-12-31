import 'dart:io';
import 'package:connect2/components/contact_relation_widget/contact_relation_widget.dart';
import 'package:connect2/helper/contact_manager.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connect2/main.dart';
import 'package:flutter_i18n/flutter_i18n.dart';


class PersonCardView extends StatefulWidget {
  final String phoneContactId;
  const PersonCardView({Key? key, required this.phoneContactId}) : super(key: key);
  @override
  // ignore: library_private_types_in_public_api
  _PersonCardViewState createState() => _PersonCardViewState();
}

class _PersonCardViewState extends State<PersonCardView> {
  late String phoneContactId;
  late ContactManager _contactManager;
  FullContact? fullContact;
  bool _isLoading = true;
  late TextEditingController _residenceController;
  late TextEditingController _employerController;
  
  String _name = "";
  DateTime? _birthDate;
  String _residence = "";
  String _employer = "";
  // Notes
  final List<ContactNote> _noteList = [];

  Image? _image;
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
    fullContact = await _contactManager.loadContactFromDatabase();
    setState(() {
      _name = fullContact!.phoneContact.displayName;

      Event? birthdayEvent = fullContact?.phoneContact.events.firstWhere(
        (event) => event.label == EventLabel.birthday,
        orElse: () => Event(month: 0, day: 0),
      );

      if (birthdayEvent != null && birthdayEvent.year != null) {
        _birthDate = DateTime(
          birthdayEvent.year!,
          birthdayEvent.month,
          birthdayEvent.day,
        );
      } else {
        _birthDate = null;
      }

      _residence = fullContact?.phoneContact.addresses.isNotEmpty == true
      ? fullContact!.phoneContact.addresses.first.address
      : "";

      _employer = fullContact?.phoneContact.organizations.isNotEmpty == true
      ? fullContact!.phoneContact.organizations.first.company
      : "";

      if (fullContact?.phoneContact.photo != null) {
        _image = Image.memory(fullContact!.phoneContact.photo!, fit: BoxFit.cover);
      }

      // Controller
      _residenceController = TextEditingController(text: _residence);
      _employerController = TextEditingController(text: _employer);

      // Notes
      _noteList.clear();
      final List<ContactNote> notesFromDb= fullContact!.notes;
      for (var noteData in notesFromDb) {
        _noteList.add(noteData);
      }

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

          _contactManager.updateDebouncing(fullContact!);
          _birthDate = pickedDate;
          
        } else {
          throw Exception('FullContact is null');
        }
      });
    }
  }

  Future<void> _addNote(String newText) async {
  if (fullContact != null) {
    try {
      DateTime formattedDate = DateTime.now();
      ContactNote newNote = await fullContact!.addNewNote(newText, formattedDate);
      setState(() {
        _noteList.add(newNote);
      });
    } catch (error) {
      throw Exception('Error while adding the note: $error');
    }
  } else {
    throw Exception('FullContact is null');
  }
}


  void _deleteNote(int index) {
    setState(() {
      ContactNote noteToDelete = _noteList[index];
      if (fullContact != null) {
        fullContact!.deleteNote(noteToDelete);
        _noteList.remove(noteToDelete);
      }
      else {
        throw Exception('FullContact is null');
      }
    });
  }

  void _addSkill(String newSkill) async {
    if (fullContact != null) {
      Tag newTag = await fullContact!.addTagByName(newSkill);
      if (mounted) {
        setState(() => fullContact!.tags.add(newTag));
      }
    }
  }

  void _deleteSkill(int index) async {
    if (fullContact != null) {
      Tag tagToRemove = fullContact!.tags[index];
      fullContact!.removeTag(tagToRemove);
      setState(() => fullContact!.tags.remove(tagToRemove));
    }
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
              title: Text(FlutterI18n.translate(context, "person_view.new_item")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: FlutterI18n.translate(context, "person_view.enter_text"),
                      errorText: isError ? FlutterI18n.translate(context, "person_view.empty_field_error") : null,
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
                  child: Text(FlutterI18n.translate(context, "person_view.cancel")),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(FlutterI18n.translate(context, "person_view.add")),
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

  if (source == ImageSource.camera) {
    status = await Permission.camera.request();
  } else {
    status = await Permission.photos.request();
  }

  if (status.isGranted) {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          File imageFile = File(pickedFile.path);
          _image = Image.file(imageFile, fit: BoxFit.cover);
          _contactManager.saveImageToContact(imageFile, fullContact!);
        });
      }
    } catch (e) {
      print("Error while recording or loading the picture: $e");
    }
  } else if (status.isDenied || status.isPermanentlyDenied) {
    _showPermissionDialog(source);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(FlutterI18n.translate(context, 
                                            "person_view.snackbar_no_permission",
                                            translationParams:{
                                                      "source": source == ImageSource.camera 
                                                      ? FlutterI18n.translate(context, "person_view.camera") 
                                                      : FlutterI18n.translate(context, "person_view.gallery"),
                                                              },
                                            ),
                      ),
      ),
    );
  }
}

  
  void _showPermissionDialog(ImageSource source) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(FlutterI18n.translate(context, "person_view.camera_galarie_permission_required")),
        content: Text(
            FlutterI18n.translate(context, "person_view.camera_galarie_permission_explained")),
        actions: [
          TextButton(
            child: Text(FlutterI18n.translate(context, "person_view.cancel")),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(FlutterI18n.translate(context, "person_view.to_settings")),
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
              title: Text(FlutterI18n.translate(context, "person_view.gallery")),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(FlutterI18n.translate(context, "person_view.camera")),
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
        title: Text(FlutterI18n.translate(context, "person_view.contact")),
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
                  child: _image != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _image,
                        ) : const Center(
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
                FlutterI18n.translate(context, "person_view.gen_info"),
                [
                  _buildDatePickerRow(FlutterI18n.translate(context, "person_view.birthday"), _birthDate, colorScheme),
                  const SizedBox(height: 8),
                  _buildEditableInfoRow(FlutterI18n.translate(context, "person_view.address"), _residence, colorScheme),
                  const SizedBox(height: 8),
                  _buildEditableInfoRow(FlutterI18n.translate(context, "person_view.employer/uni"), _employer, colorScheme)
                ],
              ),

              const SizedBox(height: 16),

              // Skills
              _buildInfoCard(
                colorScheme,
                FlutterI18n.translate(context, "person_view.skills"),
                [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fullContact != null ? fullContact!.tags.length : 0,
                    itemBuilder: (context, index) {
                      final skill = fullContact!.tags[index];
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
                                initialValue: skill.name,
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
                FlutterI18n.translate(context, "person_view.notes"),
                [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _noteList.length,
                    itemBuilder: (context, index) {
                      final note = _noteList[index];
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
                                DateFormat('dd.MM.yyyy').format(note.date ?? DateTime.now()),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              TextFormField(
                                initialValue: note.note,
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
                  child:
                        Icon(Icons.add, color: colorScheme.onPrimaryContainer),
                  )),

              const SizedBox(height: 16),

              _buildInfoCard(
                colorScheme,
                FlutterI18n.translate(context, "person_view.contact_relation"),
                [
                  SizedBox(
                    width: double.infinity,
                    child: fullContact != null
                        ? ContactRelationWidget(fullContact: fullContact!)
                        : Text(FlutterI18n.translate(context, "graph_screen.loading")),
                  ),
                ],
              )

              
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
                  _contactManager.updateDebouncing(fullContact!);
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
                  _contactManager.updateDebouncing(fullContact!);
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