import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meta_col_hub/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text,
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text, 
        password: _controllerPassword.text
      );
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }




  Widget _title() {
    return const Text('Firebase Auth');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    bool obscureText,
  )  {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: title,
      ),
      cursorColor: Colors.lightBlue,
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword: createUserWithEmailAndPassword, 
      child: Text(isLogin ? 'Login' : 'Register')
    );
  }


  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin;
        });
      }, 
      child: Text(isLogin ? 'Register instead' : 'Login instead'),
      style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor:
                              Colors.lightBlue[200], 
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              
                            )
                          )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('Email', _controllerEmail, false),
            SizedBox(height: 10),
            _entryField('Password', _controllerPassword, true),
            _errorMessage(),
            _submitButton(),
            SizedBox(height: 10,),
            _loginOrRegisterButton(),
          ],
        ),
      ),
    );
  }
}