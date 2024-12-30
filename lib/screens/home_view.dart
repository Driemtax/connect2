import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/screens/person_card_view.dart';
import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// HomeContent Widget: Die scrollbare Liste
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  List<Contact> contacts = [];
  bool permissionDenied = false;
  ContactService contactService = ContactService();

  void loadContacts() async {
    try {
      final fetchedContacts = await contactService.getAll();
      setState(() {
        contacts = fetchedContacts;
      });
    } on PermissionDeniedException {
      setState(() {
        permissionDenied = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("QR-Code importieren"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.create),
              title: const Text("Manuell erstellen"),
              onTap: () {
                Navigator.pop(context); 
                _showNameInputDialog(context); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Daten zurücksetzen"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNameInputDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Neuer Kontakt"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Namen eingeben",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Abbrechen"),
            ),
            TextButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Contact contact = Contact(name: Name(first: name));
                  print("\n");
                  print("Contact: $contact");

                  FullContact newFullContact = await contactService.createFullContact(contact);
                  String testName = newFullContact.phoneContact.displayName;
                  print("FullConctact: $testName");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PersonCardView(phoneContactId: newFullContact.phoneContact.id))); 
                }
              },
              child: const Text("Speichern"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO prettify the view
    if (permissionDenied) {
      return Scaffold(
        body: Center(
          child: TextButton(
            style: const ButtonStyle(
              foregroundColor: WidgetStatePropertyAll(Colors.blue)
            ),
            onPressed: () {
              loadContacts();
            },
            child: const Text('Give permissions to laod contacts'), // TODO add i18
          ), // TODO add i18
        )
      );
    }

    final List<String> names = contacts.map((e) {
      if (e.displayName.isEmpty) {
        return 'No Name'; // TODO add i18
      }
      return e.displayName;
    }).toList();

    // TODO prettify the message
    if (contacts.isEmpty) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showMenu(context);
          },
          tooltip: "Menü anzeigen",
          child: const Icon(Icons.add),
        ),
        body:
            Center(child: Text('Es wurden keine Kontakte gefunden.')), // TODO add i18
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMenu(context);
        },
        tooltip: 'Menü anzeigen',
        child: const Icon(Icons.add),
      ),
      body: contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PersonCardView(phoneContactId: contact.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}