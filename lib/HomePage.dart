import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:authentification/Location.dart';
// import 'package:shared_preferences/shared_preferences.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String displayName;
  String email;
  bool isloggedin = false;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("Start");
      }
    });
  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    DocumentSnapshot documentSnapshot = await firestore.collection('users').doc(_auth.currentUser.uid).get();
    if (documentSnapshot.exists) {
      email = documentSnapshot.get('email');
      displayName =  documentSnapshot.get('displayName');
    } else {
      print('User does not exist in the database');
    }

    if (firebaseUser != null ) {
      setState(() {
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Treklocation',
        home: Scaffold(
              appBar: AppBar(
                title: Text('Welcome to Treklocation'),
              ),
        body: Container(
        child: !isloggedin
          ? CircularProgressIndicator()
          : Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Text(
                    "Hello $displayName you are logged in using mail id $email",
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  style:ElevatedButton.styleFrom(
                    primary: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.fromLTRB(70, 10, 70, 10),
                  ),
                  onPressed: signOut,
                  child: Text('Sign Out',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),

                )
              ],
            ),
    ) ,
          drawer: Drawer(
        child: ListView(
        padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Treklocation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  textBaseline: TextBaseline.ideographic,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Location'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.of(context).pushReplacementNamed("Location");
              },
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Profile'),
              onTap: () {
                // change app state...
                Navigator.pop(context); // close the drawer
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Update the state of the app
                // ...
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
    ),
        )
    );
  }
}
