import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactPickerModal extends StatefulWidget {
  const ContactPickerModal({super.key});

  @override
  State<ContactPickerModal> createState() => _ListModalState();
}

class _ListModalState extends State<ContactPickerModal> {
  late Future<List<Contact>> _itemsFuture;
  final ContactService contactService = ContactService();

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems();
  }

  Future<List<Contact>> _loadItems() async {
    List<Contact> contacts = await contactService.getAll();
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No contacts found'));
        } else {
          final contacts = snapshot.data!;
          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(contacts[index].displayName),
                onTap: () {
                  Navigator.pop(context, contacts[index]);
                },
              );
            },
          );
        }
      },
    );
  }
}
