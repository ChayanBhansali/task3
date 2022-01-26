import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:task3/screen/slots.dart';
import 'dart:convert';

class LoginWithGoogle extends StatefulWidget {
  const LoginWithGoogle({Key? key}) : super(key: key);

  @override
  _LoginWithGoogleState createState() => _LoginWithGoogleState();
}

class _LoginWithGoogleState extends State<LoginWithGoogle> {
  String userEmail = "";
  TextEditingController pincodeController = TextEditingController();

  String selectedDate = "";
  bool datePicked = false;

  List slots = [];
  selectDate(BuildContext context) async {}
  //getting data
  getData() async {
    await http
        .get(Uri.parse(
        "https://cdn-api.co-vin.in/api/v2/appointment/sessions/public/findByPin?pincode=" +
            pincodeController.text +
            "&date=" +
            selectedDate))
        .then((value) {
      Map result = jsonDecode(value.body);
      setState(() {
        slots = result['sessions'];
        print(slots);
      });
    });

    Navigator.push(context, MaterialPageRoute(builder: (_) {
      return FindSlot(slots);
    }));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [Text("User Email: "),
                    SizedBox(width: 10,),
                    Text(userEmail)],
                ),
              ),
              ElevatedButton(onPressed: () async {
                await signInWithGoogle();
                setState(() {});
              }, child: Text("Login with google")),
              ElevatedButton(onPressed: () async {
                await FirebaseAuth.instance.signOut();
                userEmail = "";
                await GoogleSignIn().signOut();
                setState(() {

                });

              }, child: Text("Logout")),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: pincodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pincode'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  child: MaterialButton(
                    elevation: 4,
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(), // Refer step 1
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null)
                        setState(
                              () {
                            String formattedDate =
                            DateFormat('dd-MM-yyyy').format(picked);
                            selectedDate = formattedDate;
                            datePicked = true;
                            print(selectedDate);
                          },
                        );
                    },
                    child: Text(datePicked == false ? 'Pick Date' : selectedDate),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Container(
                  child: MaterialButton(
                    elevation: 4,
                    onPressed: () {
                      getData();
                    },
                    child: Text('Find Slot'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    userEmail = googleUser.email;

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}