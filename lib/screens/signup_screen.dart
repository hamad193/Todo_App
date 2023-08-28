import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/screens/login_screen.dart';
import 'package:todo_app/widgets/my_Button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  var fullNameController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SIGNUP'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                controller: fullNameController,
                decoration: InputDecoration(
                  hintText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'E-mail',
                  prefixIcon: Icon(Icons.mail),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  prefixIcon: Icon(Icons.verified_user),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              MyButton(
                  title: 'Sign Up',
                  onPress: () async {
                    var fullName = fullNameController.text.trim();
                    var email = emailController.text.trim();
                    var password = passwordController.text.trim();
                    var confirmPassword = confirmPasswordController.text.trim();

                    if (fullName.isEmpty ||
                        email.isEmpty ||
                        password.isEmpty ||
                        confirmPassword.isEmpty) {
                      // show error toast
                      Fluttertoast.showToast(msg: 'Please Fill all Fields');
                      return;
                    }

                    if (password.length < 6) {
                      // show error toast
                      Fluttertoast.showToast(
                          msg: 'Short Password, use at least 6 characters');
                      return;
                    }

                    if (password != confirmPassword) {
                      // show error toast
                      Fluttertoast.showToast(msg: 'Passwords do not match');
                      return;
                    }
                    // request to firebase auth

                    ProgressDialog progressDialog = ProgressDialog(
                      context,
                      title: Text("Signing up"),
                      message: Text('Please wait'),
                    );

                    progressDialog.show();

                    try {
                      FirebaseAuth auth = FirebaseAuth.instance;
                      UserCredential userCredential =
                          await auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );

                      if (userCredential.user != null) {
                        DatabaseReference userRef =
                            FirebaseDatabase.instance.ref().child('users');

                        String uid = userCredential.user!.uid;

                        int dt = DateTime.now().millisecondsSinceEpoch;

                        userRef.child(uid).set({
                          'fullName': fullName,
                          'email': email,
                          'uid': uid,
                          'dt': dt,
                          'profileImage': '',
                        });

                        Fluttertoast.showToast(msg: 'Success');
                        Navigator.pop(context);
                      } else {
                        Fluttertoast.showToast(msg: 'Failed');
                      }
                      progressDialog.dismiss();
                    } on FirebaseAuthException catch (e) {
                      progressDialog.dismiss();

                      if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(
                            msg: 'Email is Already Registered');
                      } else if (e.code == 'weak-password') {
                        Fluttertoast.showToast(msg: 'Weak Password');
                      }
                    } catch (e) {
                      progressDialog.dismiss();
                      Fluttertoast.showToast(msg: 'Something went wrong');
                    }
                  }),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                    child: Text(
                      'Log in',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
