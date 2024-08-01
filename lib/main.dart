import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'data_analysis_page.dart';
import 'app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set the initial collection name if not already set
  String collectionName = await AppConfig.getCollectionName();
  if (collectionName.isEmpty) {
    await AppConfig.setCollectionName('JacobLogs');
  }
  runApp(const AppWrapper());
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  _AppWrapperState createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Force a rebuild when the app is resumed
      setState(() {});
    }
  }

  void _reload() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MyApp(onReload: _reload);
  }
}

class MyApp extends StatefulWidget {
  final Function onReload;

  MyApp({required this.onReload, super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _isAshleyFuture;

  @override
  void initState() {
    super.initState();
    _isAshleyFuture = AppConfig.isAshley();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _isAshleyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
                home: Scaffold(body: CircularProgressIndicator()));
          }

          bool isAshley = snapshot.data ?? false;

          return MaterialApp(
            title: 'Smoke Log 2.0',
            theme: ThemeData.dark(),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              colorScheme: ColorScheme.dark(
                primary: isAshley ? Colors.purple[900]! : Colors.blue[900]!,
                secondary: isAshley
                    ? Colors.purpleAccent[700]!
                    : Colors.blueAccent[700]!,
                surface: isAshley ? Colors.deepPurple[900]! : Colors.grey[900]!,
                onPrimary: Colors.white,
                onSecondary: Colors.white70,
                onSurface: Colors.white70,
                error: Colors.red,
                onError: Colors.white,
              ),
              primaryColor:
                  isAshley ? Colors.deepPurple[900] : Colors.blueGrey[900],
              hintColor:
                  isAshley ? Colors.purpleAccent[700] : Colors.blueAccent[700],
              scaffoldBackgroundColor: isAshley ? Colors.black87 : Colors.black,
              cardColor: isAshley ? Colors.deepPurple[900] : Colors.grey[900],
              appBarTheme: AppBarTheme(
                color: isAshley ? Colors.deepPurple[900] : Colors.blueGrey[900],
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                displayLarge: TextStyle(color: Colors.white),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.blueGrey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            themeMode: ThemeMode.dark,
            home: MyHomePage(
              onReload: widget.onReload,
            ),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  final Function onReload;

  MyHomePage({required this.onReload, super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      HomePage(onReload: widget.onReload),
      DataAnalysisPage(onReload: widget.onReload),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analysis',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
