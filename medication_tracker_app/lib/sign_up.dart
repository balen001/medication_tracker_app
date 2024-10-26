import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController fNameCtrl = TextEditingController();
  TextEditingController lNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  TextEditingController confirmPassCtrl = TextEditingController();
  String firstName = "";
  String lastName = "";
  String email = "";
  String password = "";
  String confirmPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Sign up",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          centerTitle: true,
          automaticallyImplyLeading: false, // to hide return button
        ),
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: fNameCtrl,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "John",
                      labelText: "First Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter your first name";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        firstName = value;
                      });
                    },
                  ),

                  SizedBox(
                    height: 40,
                  ),

                  TextFormField(
                    controller: lNameCtrl,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      hintText: "Doe",
                      labelText: "Last Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter your last name";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        lastName = value;
                      });
                    },
                  ),

                  SizedBox(
                    height: 40,
                  ),

                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "user@domain.com",
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter your email please";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: passCtrl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "enter your password";
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: confirmPassCtrl,
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm password",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "type your password again";
                      } else if (value != password) {
                        return 'Passwords do not match';
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                  ),

                  SizedBox(
                    height: 70,
                  ),
                  //space after the text fields

                  Container(
                    width: 150,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          signUpData();
                        }
                      },
                      child: Text("Sign up",
                          style: const TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: <TextSpan>[
                        const TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                decoration: TextDecoration.none)),
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                              color: Colors.blue,
                              fontSize: 12,
                              decoration: TextDecoration.none),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  void signUpData() async {
    try {
      UserCredential uc = await auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      if (uc.user?.uid != null) {
        addUserData(
            uc.user!.uid, email.trim(), firstName.trim(), lastName.trim());

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("User created successfully"),
          ),
        );
      }
    } catch (e) {
      print("$e");

      String message;
      if (e.toString().contains('email address is badly formatted')) {
        message = 'The email address is invalid.';
      } else if (e
          .toString()
          .contains('Password should be at least 6 characters')) {
        message = "Invalid password. Password should be at least 6 characters.";
      } else if (e
          .toString()
          .contains('[firebase_auth/email-already-in-use]')) {
        message =
            e.toString().replaceAll('[firebase_auth/email-already-in-use]', '');
      } else {
        message = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }
  }

  Future addUserData(
      String uid, String email, String firstName, String lastName) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'email': email.trim(),
    });
  }
}
