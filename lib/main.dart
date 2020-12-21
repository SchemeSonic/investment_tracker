import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home-page.dart';
import 'investment-page.dart';
import 'login.dart';
import 'globals.dart' as globals;

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  bool _userLoggedIn = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    final User user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      globals.currentUser = user;
      setState(() {
        _userLoggedIn = true;
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _userLoggedIn ? 
      Scaffold(
        appBar: AppBar(
          title: _selectedIndex == 0 ? Text('Anasayfa') : Text('Yatırımlarım'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                FirebaseAuth.instance.signOut();
                setState(() {
                  _userLoggedIn = false;
                });
              },
            )]
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
