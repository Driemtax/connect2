import 'package:connect2/screens/person_card_view.dart';
import 'package:flutter/material.dart';

// HomeContent Widget: Die scrollbare Liste
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> names = [
      'Alice Biden', 'Bob Schulz', 'Charlie', 'David', 'Eve', 'Frank',
      'Grace', 'Heidi', 'Ivan', 'Judy', 'Karl', 'Lars', 'Marta', 'Nicole'
    ];

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
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.person),  // Icon links vom Namen
            title: Text(names[index]),
          );
        },
      ),
    );
  }
}
