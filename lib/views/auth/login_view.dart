import 'package:email_validator/email_validator.dart';
import 'package:famlicious/managers/auth_manager.dart';
import 'package:famlicious/views/auth/create_account_view.dart';
import 'package:famlicious/views/auth/forgot_password_view.dart';
import 'package:famlicious/views/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginView extends StatefulWidget {
  LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _authManager = AuthManager();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(10),
            children: [
              FlutterLogo(
                size: 130,
              ),
              SizedBox(
                height: 35,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => _emailValidation(value),
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) => _passwordValidation(value),
              ),
              SizedBox(
                height: 25,
              ),
              _submitButton(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text(
                    'Forgot password? Reset here!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordView(),
                      ),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text(
                    'Create an Account!',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CreateAccountView(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _passwordValidation(value) {
    if (value!.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  _emailValidation(value) {
    if (value == null || !EmailValidator.validate(value)) {
      return 'Invalid Email supplied';
    }
    return null;
  }

  _submitButton() => isLoading
      ? Center(
          child: CircularProgressIndicator.adaptive(),
        )
      : TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            if (_formKey.currentState!.validate()) {
              String email = _emailController.text;
              String password = _passwordController.text;
              String message = '';

              bool created = await _authManager
                  .loginUser(email: email, password: password)
                  .then((value) => value)
                  .catchError((error) {
                print(error);
                print(StackTrace.current);
                message = 'An error occurred';
                return false;
              }).timeout(Duration(seconds: 60), onTimeout: () {
                message = 'Request timed out';
                return false;
              });

              if (created) {
                Fluttertoast.showToast(
                  msg: "Login Success",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green.shade300,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false);
              } else {
                Fluttertoast.showToast(
                    msg: message,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            }

            setState(() {
              isLoading = false;
            });
          },
          child: Text(
            'Submit',
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                ),
          ),
        );
}
