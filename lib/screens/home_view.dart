import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Aktuell ausgewählter Index der Navigationsleiste
  int _selectedIndex = 0;

  // Liste von Widgets für jede Ansicht
  final List<Widget> _pages = [
    const HomeContent(),         // Home Seite
    const PersonView(),          // Person View Seite
    const NotificationView(),    // Notification Seite
  ];

  // Funktion, um den Index zu ändern
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Navigation Example'),
      ),
      body: Center(
        child: _pages[_selectedIndex],  // Zeige die ausgewählte Seite an
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,  // Der aktuell ausgewählte Index
        onDestinationSelected: _onItemTapped,  // Ruft die Funktion auf, um den Index zu ändern
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Person View',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aktion für den Floating Button
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// HomeContent Widget: Die scrollbare Liste
class HomeContent extends StatelessWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> names = [
      'Alice Biden', 'Bob Schulz', 'Charlie', 'David', 'Eve', 'Frank',
      'Grace', 'Heidi', 'Ivan', 'Judy', 'Karl', 'Lars', 'Marta', 'Nicole'
    ];

    return ListView.builder(
      itemCount: names.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.person),  // Icon links vom Namen
          title: Text(names[index]),
        );
      },
    );
  }
}

// PersonView Widget: Placeholder für Person View
class PersonView extends StatelessWidget {
  const PersonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Person View'),
    );
  }
}

// NotificationView Widget: Placeholder für Notification View
class NotificationView extends StatelessWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Notification View'),
    );
  }
}
