import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home-page.dart';
import 'investment-page.dart';
import 'login.dart';

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _userLoggedIn = false;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLoggedIn ? 
      Scaffold(
        appBar: AppBar(
          title: _selectedIndex == 0 ? Text('Anasayfa') : Text('Yatırımlarım'),
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
      ) :
      LoginScreen(onUserLoggedIn: () => {
        setState(() => _userLoggedIn = true)
      },)
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    title: 'Yatırım Uygulaması',
    home: new App()
  ));
}
