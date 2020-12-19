import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'globals.dart' as globals;

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

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
  
  assert(user.uid == currentUser.uid);
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
                //signInWithFacebook();
                print("signInWithFacebook()");
              },
              text: "Facebook ile bağlan",
            )
          ]
        )
      );
  }
}