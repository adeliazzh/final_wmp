import 'package:final_wmp/shared/theme.dart';
import 'package:final_wmp/widgets/customized_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Initialize the controllers as class-level variables
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordReTypeController = TextEditingController();

  String errorMessage = ''; // Keeps track of the error message

  // Function to update error message
  void setErrorMessage(String message) {
    setState(() {
      errorMessage = message;
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void registerUser() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      String userId = userCredential.user!.uid;

      // Create a new document in Firestore based on userId
      await _firestore.collection('users').doc(userId).set({
        'name': nameController.text,
        'email': emailController.text,
        'userId': userId,
        'createdAt': Timestamp.now(),
      });

      print('User has successfully registered with uId of $userId');
    } on FirebaseAuthException catch (e) {
      print('Error during registration: ${e.message}');
      if (e.code == 'weak-password') {
        setErrorMessage('The password is too weak.');
      } else if (e.code == 'email-already-in-use') {
        setErrorMessage('The email is already in use.');
      } else {
        setErrorMessage('An unknown error occurred.');
      }
    } catch (e) {
      print('Unknown error: $e');
      setErrorMessage('An error occurred while trying to register.');
    }
  }

  Widget nameInput() {
    return TextField(
      controller: nameController,
      decoration: InputDecoration(
        labelText: "Full Name",
        labelStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        hintText: "Enter your Email",
        hintStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kBlackColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPurpleColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    );
  }

  Widget emailInput() {
    return TextField(
      controller: emailController,
      decoration: InputDecoration(
        labelText: "Email Address",
        labelStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        hintText: "Enter your email...",
        hintStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kBlackColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPurpleColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    );
  }

  Widget passwordInput() {
    return TextField(
      controller: passwordController,
      decoration: InputDecoration(
        labelText: "Password",
        labelStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        hintText: "Your password here...",
        hintStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kBlackColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPurpleColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      obscureText: true,
    );
  }

  Widget passwordReType() {
    return TextField(
      controller: passwordReTypeController,
      onEditingComplete: () {
        // Check if passwords match
        if (passwordReTypeController.text != passwordController.text) {
          setErrorMessage('Password does not match!');
        } else {
          setErrorMessage('Password match!');
        }
        print(errorMessage);
        FocusScope.of(context).requestFocus(FocusNode());
      },
      decoration: InputDecoration(
        labelText: "Confirm Password",
        labelStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        hintText: "Confirm your password",
        hintStyle: blackTextStyle.copyWith(
          fontSize: 20,
          fontWeight: light,
        ),
        errorText: errorMessage != "Password match!" ? errorMessage : null,
        errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(defaultRadius)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kBlackColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: kPurpleColor),
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
      obscureText: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhiteColor,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: defaultMargin),
            child: Column(
              children: [
                const SizedBox(height: 64), // Space at the top
                Text(
                  "Register Account",
                  style: blackTextStyle.copyWith(
                    fontSize: 28,
                    fontWeight: medium,
                  ),
                ),
                const SizedBox(height: 16),
                nameInput(),
                const SizedBox(height: 16),
                emailInput(),
                const SizedBox(height: 16),
                passwordInput(),
                const SizedBox(height: 16),
                passwordReType(),
                const SizedBox(height: 28),
                CustomizedButton(
                  height: 60,
                  onTap: () {
                    errorMessage == "Password match!"
                        ? {
                            registerUser(),
                            Navigator.pushNamed(context, '/login-page')
                          }
                        : null;
                  },
                  text: "Register",
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
