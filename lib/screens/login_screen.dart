import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ndialog/ndialog.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:todo_app/screens/signup_screen.dart';
import 'package:todo_app/screens/tasklist_screen.dart';
import 'package:todo_app/widgets/my_Button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('LOGIN'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
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
            SizedBox(height: 30),
            MyButton(title: 'Log in', onPress: () async {

              var email = emailController.text.trim();
              var password = passwordController.text.trim();

              if(email.isEmpty || password.isEmpty) {
                // show error toast
                Fluttertoast.showToast(msg: 'Please Fill all fields');
                return;
              }

              ProgressDialog progressDialog = ProgressDialog(
                context,
                title: Text("Logging in"),
                message: Text('Please wait'),
              );

              progressDialog.show();

              try{
                FirebaseAuth auth = FirebaseAuth.instance;
                UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

                if(userCredential.user != null){

                  progressDialog.dismiss();

                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => TaskListScreen()));
                }


              }on FirebaseAuthException catch(e) {

                progressDialog.dismiss();

                if(e.code == 'user-not-found'){
                  Fluttertoast.showToast(msg: 'User Not found');

                }else if(e.code == 'wrong-password'){}

              }catch(e){
                Fluttertoast.showToast(msg: 'Wrong Password');
                progressDialog.dismiss();
              }

            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don\'t have an account?"),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SignupScreen()));
                  },
                  child: Text(
                    'Sign up',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
