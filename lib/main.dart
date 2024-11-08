import 'package:flutter/material.dart';
import 'package:connect2/screens/person_card_view.dart';
import 'package:connect2/screens/home_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  // Hier definierst du die verschiedenen Views, die je nach ausgewähltem Index angezeigt werden sollen
  static const List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    PersonCardView(),  // Neue View, die in der Navigation Bar angezeigt werden soll
    Text('Notifications View'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  // Aktualisiert den ausgewählten Index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Navigation Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),  // Wählt die View basierend auf dem Index aus
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
    );
  }
}
