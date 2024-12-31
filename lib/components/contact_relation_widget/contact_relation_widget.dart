import 'package:connect2/components/contact_picker_modal.dart';
import 'package:connect2/components/contact_relation_widget/contact_relation_list.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactRelationWidget extends StatefulWidget {
  final FullContact fullContact;
  const ContactRelationWidget({super.key, required this.fullContact});

  @override
  ContactRelationWidgetState createState() => ContactRelationWidgetState();
}

class ContactRelationWidgetState extends State<ContactRelationWidget> {
  late FullContact _fullContact;

  @override
  void initState() {
    _fullContact = widget.fullContact;
    super.initState();
  }

  void _createNewContactRelation(Contact contact) async {
    ContactDetail? contactDetail = await ContactDetail()
        .select()
        .phoneContactId
        .equals(contact.id)
        .toSingle();
    int? contactDetailId = contactDetail?.id;
    if (contactDetailId != null) {
      ContactRelation newContactRelation =
          await _fullContact.addContactRelation('', contactDetailId);
      if (mounted) {
        setState(() {
          _fullContact.outgoingContactRelations.add(newContactRelation);
        });
      }
    }
  }

  void _openContactPickerModal(BuildContext context) async {
    final Contact? contact = await showModalBottomSheet<Contact>(
      context: context,
      builder: (BuildContext context) {
        return const ContactPickerModal();
      },
    );

    if (contact != null) {
      _createNewContactRelation(contact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200,
          child: ContactRelationList(
            fullContact: _fullContact,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _openContactPickerModal(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Contact Relation'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
