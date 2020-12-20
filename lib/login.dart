import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();
final FacebookLogin facebookLogin = FacebookLogin();

Future<void> signInWithFacebook(onUserLoggedIn) async {
  final result = await facebookLogin.logIn(['email']);

  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      String token = result.accessToken.token;
      final graphResponse = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
      final profile = json.decode(graphResponse.body);
      globals.currentUser = profile;
      print(profile);
      onUserLoggedIn();
      break;
    case FacebookLoginStatus.cancelledByUser:
      print("Facebook login Canceled by User");
      break;
    case FacebookLoginStatus.error:
      print("Facebook login error");
      break;
  }
}

Future<String> signInWithGoogle(onUserLoggedIn) async {
  final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
  final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;
  
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleSignInAuthentication.accessToken,
    idToken: googleSignInAuthentication.idToken,
  );
  
  final UserCredential authResult = await _auth.signInWithCredential(credential);
  final User user = authResult.user;
  
  assert(!user.isAnonymous);
  assert(await user.getIdToken() != null);

  final User currentUser = _auth.currentUser;
  globals.currentUser = currentUser;
  assert(user.uid == currentUser.uid);
  print(currentUser);
  onUserLoggedIn();
  return 'signInWithGoogle succeeded: $user';
}

void signOutGoogle() async{
  await googleSignIn.signOut();

  print("User Sign Out");
}

class LoginScreen extends StatefulWidget {
  final VoidCallback onUserLoggedIn;
  LoginScreen({this.onUserLoggedIn});
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            SignInButton(
              Buttons.Google,
              onPressed: () {
                signInWithGoogle(widget.onUserLoggedIn);
              },
              text: "Google ile bağlan",
            ),
            SignInButton(
              Buttons.Facebook,
              onPressed: () {
                signInWithFacebook(widget.onUserLoggedIn);
              },
              text: "Facebook ile bağlan",
            )
          ]
        )
      );
  }
}