import 'package:flutter/material.dart';

class ContactRelationListTile extends StatelessWidget {
  final String fromText;
  final String toText;

  const ContactRelationListTile({
    super.key,
    required this.fromText,
    required this.toText,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              fromText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Icon(
                Icons.arrow_forward,
                size: 24,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                toText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
