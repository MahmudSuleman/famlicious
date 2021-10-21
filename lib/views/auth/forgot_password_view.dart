import 'package:email_validator/email_validator.dart';
import 'package:famlicious/managers/auth_manager.dart';
import 'package:famlicious/views/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ForgotPasswordView extends StatefulWidget {
  ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authManager = AuthManager();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              FlutterLogo(
                size: 130,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => _emailValidation(value),
              ),
              SizedBox(
                height: 20,
              ),
              _submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  _submitButton() => isLoading
      ? Center(child: CircularProgressIndicator())
      : TextButton(
          style: TextButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            if (_formKey.currentState!.validate()) {
              String email = _emailController.text;

              bool isSent = await _authManager.sendResetLink(email);

              if (isSent) {
                Fluttertoast.showToast(
                  msg: "Account reset link sent",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green.shade300,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginView()));
              } else {
                Fluttertoast.showToast(
                  msg: "Failed to send reset link",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0,
                );
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

  _emailValidation(value) {
    if (value == null || !EmailValidator.validate(value)) {
      return 'Invalid Email supplied';
    }
    return null;
  }
}
