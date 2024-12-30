import 'package:connect2/screens/graph_screen.dart';
import 'package:flutter/material.dart';
import 'package:connect2/screens/first_own_card.dart';
import 'package:connect2/screens/home_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      locale: Locale('en'), // Hier wird die Sprache festgelegt, standardmäßig Englisch
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            basePath: 'assets/flutter_i18n', // Hier wird der Pfad zu deinen JSON-Dateien angegeben
            fallbackFile: 'en', // Falls keine Übersetzung für die aktuelle Sprache vorhanden ist
            useCountryCode: false, // Falls du keine länderspezifischen Übersetzungen verwendest
          ),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', '')
      ],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeContent(), 
    const GraphScreen(),
    const OwnContactView()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "app_title")),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),  // Wählt die View basierend auf dem Index aus
      ),
      // floatingActionButton: FloatingActionButton.large(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const PersonCardView()),
      //     );
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,  
        onDestinationSelected: _onItemTapped,  
        indicatorColor: Theme.of(context).colorScheme.inversePrimary,
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: FlutterI18n.translate(context, "navbar_home"),
          ),
          NavigationDestination(
            icon: Icon(Icons.network_cell),
            label: FlutterI18n.translate(context, "navbar_graph"),
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: FlutterI18n.translate(context, "navbar_card"),
          ),
        ],
      ),
    );
  }
}