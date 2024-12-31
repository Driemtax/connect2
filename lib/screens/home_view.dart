import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/screens/person_card_view.dart';
import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

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
              leading: const Icon(Icons.create),
              title: Text(FlutterI18n.translate(context, "home_view.create_manuall")),
              onTap: () {
                Navigator.pop(context); 
                _showNameInputDialog(context); 
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text(FlutterI18n.translate(context, "home_view.reset_own_data")),
              onTap: () async {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Karte wurde zurückgesetzt.")),
                );
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
          title: Text(FlutterI18n.translate(context, "home_view.new_contact")),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: FlutterI18n.translate(context, "home_view.enter_name"),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(FlutterI18n.translate(context, "home_view.cancel")),
            ),
            TextButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Contact contact = Contact(name: Name(first: name));

                  FullContact newFullContact = await contactService.createFullContact(contact);
                  String testName = newFullContact.phoneContact.displayName;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PersonCardView(phoneContactId: newFullContact.phoneContact.id))); 
                }
              },
              child: Text(FlutterI18n.translate(context, "home_view.save")),
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
            child: Text(FlutterI18n.translate(context, "home_view.contact_permission_required")), // TODO add i18
          ),
        )
      );
    }

    final List<String> names = contacts.map((e) {
      if (e.displayName.isEmpty) {
        return FlutterI18n.translate(context, "home_view.no_name");
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
          tooltip: FlutterI18n.translate(context, "home_view.show_menu"),
          child: const Icon(Icons.add),
        ),
        body:
            Center(child: Text(FlutterI18n.translate(context, "home_view.no_contacts_found"))), // TODO add i18
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMenu(context);
        },
        tooltip: FlutterI18n.translate(context, "home_view.show_menu"),
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