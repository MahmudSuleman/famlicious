import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:famlicious/managers/auth_manager.dart';
import 'package:famlicious/views/home/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:unicons/unicons.dart';

class CreateAccountView extends StatefulWidget {
  @override
  State<CreateAccountView> createState() => _CreateAccountViewState();
}

class _CreateAccountViewState extends State<CreateAccountView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _imagePicker = ImagePicker();

  File? _imageFile;

  AuthManager _authManager = AuthManager();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: _imageFile == null
                        ? Image.network(
                            'https://randomuser.me/api/portraits/men/33.jpg',
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            _imageFile!,
                            height: 130,
                            width: 130,
                            fit: BoxFit.cover,
                          )),
              ),
              TextButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return SizedBox(
                          height: 150,
                          child: Column(
                            children: [
                              Text('Image Source'),
                              TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _selectImage(source: ImageSource.camera);
                                  },
                                  icon: Icon(UniconsLine.camera),
                                  label: Text('Camera')),
                              TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _selectImage(source: ImageSource.gallery);
                                  },
                                  icon: Icon(UniconsLine.picture),
                                  label: Text('Gallery')),
                            ],
                          ),
                        );
                      });
                },
                icon: Icon(Icons.camera_alt, color: Colors.grey),
                label: Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Full Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || !EmailValidator.validate(value)) {
                    return 'Invalid Email supplied';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(labelText: 'Password'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Password is required';
                  }

                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 15,
              ),
              _authManager.isLoading
                  ? Center(
                      child: CircularProgressIndicator.adaptive(),
                    )
                  : TextButton(
                      style:
                          TextButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String name = _nameController.text;
                          String email = _emailController.text;
                          String password = _passwordController.text;

                          bool created = await _authManager.createNewUser(
                              name: name,
                              email: email,
                              password: password,
                              imageFile: _imageFile!);

                          if (created) {
                            Fluttertoast.showToast(
                                msg: "Account created",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.green.shade300,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => HomePage()),
                                (route) => false);
                          } else {
                            Fluttertoast.showToast(
                                msg:
                                    "Failed to create account: error ${_authManager.message}",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0);
                          }
                        } else {
                          Fluttertoast.showToast(
                              msg: "All inputs fields are required",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        }
                      },
                      child: Text(
                        'Submit',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectImage({ImageSource source = ImageSource.camera}) async {
    XFile? selectedFile = await _imagePicker.pickImage(source: source);
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: selectedFile!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
    setState(() {
      _imageFile = croppedFile;
    });
  }
}
