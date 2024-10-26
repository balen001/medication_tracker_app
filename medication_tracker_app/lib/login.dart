import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'home.dart';
import 'sign_up.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _SignInPageState();
}

class _SignInPageState extends State<Login> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController passCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String email = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Login",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.indigo,
          centerTitle: true,
          automaticallyImplyLeading: false, // to hide return button
        ),
        body: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Form(
            key: _formKey, //for validation
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                    return null;
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
                      return "enter your password please";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
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
                          signInData();
                        }
                      },
                      child:
                          Text("Login", style: TextStyle(color: Colors.white)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.blue),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.blue))))),
                ),

                SizedBox(
                  height: 50,
                ),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              decoration: TextDecoration.none)),
                      TextSpan(
                        text: 'Sign up',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.none),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<int> signInData() async {
    try {
      final user = await auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (user != null) {
        //retrieving user id
        String userId = user.user!.uid;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage(userData: userId)),
        );
      }
      return 0;
    } catch (e) {
      print("$e");

      String message;
      if (e.toString().contains('email address is badly formatted')) {
        message = 'The email address is invalid.';
      } else if (e
          .toString()
          .contains('Password should be at least 6 characters')) {
        message = "Invalid password. Password should be at least 6 characters.";
      } else if (e.toString().contains('[firebase_auth/invalid-credential]')) {
        message = 'Invalid email or password.';
      } else if (e.toString().contains('missing-password')) {
        message = 'password is empty. Please enter a password.';
      } else {
        message = 'Unexpected error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
      return 1;
    }
  }
}
