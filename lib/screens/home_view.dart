import 'package:connect2/exceptions/exceptions.dart';
import 'package:connect2/screens/person_card_view.dart';
import 'package:connect2/provider/phone_contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dummy_person.dart';

// HomeContent Widget: Die scrollbare Liste
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  HomeContentState createState() => HomeContentState();
}

class HomeContentState extends State<HomeContent> {
  List<Contact> contacts = [];
  bool permissionDenied = false;
  PhoneContactProvider phoneContactProvider = PhoneContactProvider();

  void loadContacts() async {
    try {
      final fetchedContacts = await phoneContactProvider.getAll();
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
      return const Scaffold(
        body:
            Center(child: Text('No contacts have been found.')), // TODO add i18
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PersonCardView()),
          );
        },
        tooltip: 'Increment',
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
                            DummyPersonView(name: contact.displayName),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
