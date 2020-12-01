import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home-page.dart';
import 'investment-page.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yatırım'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int index) => setState(() => _selectedIndex = index),
        currentIndex: _selectedIndex,
        items: [
          BottomNavigationBarItem(
            label: 'Ana Sayfa',
            icon: Icon(Icons.dashboard_rounded),
          ),
          BottomNavigationBarItem(
            label: 'Yatırımlarım',
            icon: Icon(Icons.money_rounded),
          ),
        ],
      ),
      body: _selectedIndex == 0 ? HomePage() : InvestmentPage(),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebase = await Firebase.initializeApp();
  print(firebase);
  runApp(MaterialApp(
    title: 'Shopping App',
    home: new App()
  ));
}
