import 'package:connect2/components/contact_relation_widget/contact_relation_list_tile.dart';
import 'package:connect2/model/full_contact.dart';
import 'package:connect2/model/model.dart';
import 'package:connect2/services/contact_service.dart';
import 'package:flutter/material.dart';

class ContactRelationList extends StatefulWidget {
  final FullContact fullContact;
  const ContactRelationList({super.key, required this.fullContact});

  @override
  ContactRelationListState createState() => ContactRelationListState();
}

class ContactRelationListState extends State<ContactRelationList> {
  final ContactService contactService = ContactService();
  late FullContact _fullContact;
  Map<int, String> idToNameMap = {};

  @override
  void initState() {
    super.initState();
    _fullContact = widget.fullContact;
    _initData();
  }

  void _initData() async {
    Map<int, String> newIdToNameMap =
        await contactService.getContactDetailIdToNameMap();
    setState(() {
      idToNameMap = newIdToNameMap;
    });
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
            fromText: idToNameMap[
                _fullContact.outgoingContactRelations[index].fromId] ?? '',
            toText: idToNameMap[
                _fullContact.outgoingContactRelations[index].toId] ?? '',
          ),
        );
      },
    );
  }
}
