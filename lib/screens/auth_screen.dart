import 'dart:io';

import 'package:chatapp/widgets/user_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

final _kfirebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var isLogin = true;
  var _enteredEmail = '';
  var _enteredPass = '';
  File? onSelectImage;

  //
  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid || !isLogin && onSelectImage == null) {
      //Show error message...on required but can be done
      return;
    }

    _formKey.currentState!.save();
    //Exception handling for email and password entered for login and signup
    try {
      if (isLogin) {
        //log users in

        final userCredential = _kfirebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPass);
      } else {
        //signUp

        final userCredential = await _kfirebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPass);

        //store image in fiebase
        final storageImage = await FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredential.user!.uid}.jpg');

        //
        await storageImage.putFile(onSelectImage!);

        //url
        final storageUrl = storageImage.getDownloadURL();

        //Store User's data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': 'to be alloted',
          'email': _enteredEmail,
          'image_url': storageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication Failed'),
        ),
      );
    }
  }

  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade800,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.all(15),
                width: 200,
                child: Image.asset(
                  'assets/images/chat.jpeg',
                ),
              ),
              Card(
                margin: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        UserImagePicker(
                          //UserImagePicker class called to display selected Image
                          onPickImage: (pickedImage) {
                            onSelectImage = pickedImage;
                          },
                        ),
                        TextFormField(
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Enter valid Email Address';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            label: Text('Email Address'),
                          ),
                        ),
                        TextFormField(
                          onSaved: (value) {
                            _enteredPass = value!;
                          },
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value.trim().length < 6) {
                              return 'Password must be more than 6 characters';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                          autocorrect: false,
                          obscureText: true,
                          decoration: const InputDecoration(
                            label: Text('Password'),
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          child: Text(
                            isLogin ? 'Login' : 'SignUp',
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              isLogin = !isLogin;
                            });
                          },
                          child: Text(isLogin
                              ? 'Create an account'
                              : 'Already have an account'),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
