import 'package:connect2/components/contact_relation/contact_relation_list_tile.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:flutter/material.dart';

class ContactRelationList extends StatefulWidget {
  final FullContact fullContact;
  const ContactRelationList({super.key, required this.fullContact});

  @override
  ContactRelationListState createState() => ContactRelationListState();
}

class ContactRelationListState extends State<ContactRelationList> {
  late FullContact _fullContact;
  @override
  void initState() {
    super.initState();
    _fullContact = widget.fullContact;
  }

  void _deleteRelation(int index) async {
    ContactRelation relation = _fullContact.outgoingContactRelations[index];
    _fullContact.deleteContactRelation(relation);
    setState(() => _fullContact.outgoingContactRelations.remove(relation));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _fullContact.outgoingContactRelations.length,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemBuilder: (BuildContext context, int index) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            _deleteRelation(index);
          },
          background: Container(
            color: Colors.red,
            padding: const EdgeInsets.only(left: 16),
            alignment: Alignment.centerLeft,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ContactRelationListTile(
            fromText:
                _fullContact.outgoingContactRelations[index].fromId.toString(),
            toText:
                _fullContact.outgoingContactRelations[index].toId.toString(),
          ),
        );
      },
    );
  }
}
