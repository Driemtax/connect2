import 'package:connect2/model/full_contact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:connect2/services/contact_service.dart'; 
import 'package:connect2/screens/person_card_view.dart';
import 'package:connect2/screens/own_card.dart';

class OwnContactView extends StatefulWidget {
  const OwnContactView({super.key});

  @override
  _OwnContactViewState createState() => _OwnContactViewState();
}

class _OwnContactViewState extends State<OwnContactView> {
  final ContactService _service = ContactService();
  FullContact? _ownContact;

  @override
  void initState() {
    super.initState();
    _loadOwnContact();
  }

  Future<void> _loadOwnContact() async {
    final contact = await _service.getOwnPhoneContact();
    setState(() {
      _ownContact = contact;
    });
  }

  void _selectExistingContact() async {
    final contacts = await _service.getAll();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Wähle einen Kontakt'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.displayName),
                  onTap: () async {
                    await _service.saveOwnPhoneContactId(contact.id);
                    Navigator.pop(context);
                    _loadOwnContact();
                  },
                );
              },
            ),
          ),
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
                  Contact newPhoneContact = Contact(name: Name(first: name));
                  FullContact newFullContact = await _service.createFullContact(newPhoneContact);

                  _service.saveOwnPhoneContactId(newFullContact.phoneContact.id);
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

  void _createNewContact() async {
    _showNameInputDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    // if own contact exists just show the view for ownContact
    if (_ownContact != null) {
      String contactId = _ownContact!.phoneContact.id;
      return OwnCardView(phoneContactId: contactId);
    }

    // If own contact doenst exist, show buttons to select what to do
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eigenen Kontakt auswählen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Was ist das?'),
                    content: const Text(
                      'Wählen Sie hier Ihren eigenen Kontakt aus der Liste aus oder erstellen Sie einen neuen Kontakt. Dies ist nur einmalig erforderlich.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _selectExistingContact,
              child: const Text('Bestehenden Kontakt auswählen'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createNewContact,
              child: const Text('Neuen Kontakt erstellen'),
            ),
          ],
        ),
      ),
    );
  }
}
