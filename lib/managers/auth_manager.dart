import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:famlicious/services/file_upload_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthManager with ChangeNotifier {
  final FirebaseAuth _fireBaseAuth = FirebaseAuth.instance;
  final FileUploadService _fileUploadService = FileUploadService();
  static final FirebaseFirestore _firebaseFirestore =
      FirebaseFirestore.instance;
  CollectionReference _userCollection = _firebaseFirestore.collection('users');
  String _message = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get message => _message;

  setMessage(String message) {
    _message = message;
    notifyListeners();
  }

  setIsLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<bool> createNewUser({
    required String name,
    required String email,
    required String password,
    required File imageFile,
  }) async {
    setIsLoading(true);
    return _fireBaseAuth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((userCredentials) async {
      String? photoUrl = await _fileUploadService.uploadFile(
          file: imageFile, userUid: userCredentials.user!.uid);

      print('download url:$photoUrl');

      if (photoUrl != null) {
        //  add user info to firestore(name, email, photo, uid,createdAt)
        _userCollection.doc(userCredentials.user!.uid).set({
          'name': name,
          'email': email,
          'picture': photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'user_id': userCredentials.user!.uid
        });
        setIsLoading(false);
        return true;
      } else {
        setMessage('Image upload failed');
        setIsLoading(false);
        return false;
      }
    }).catchError((error) {
      print('firebase error: $error');
      // setMessage(error);
      setIsLoading(false);
      return false;
    }).timeout(Duration(seconds: 60), onTimeout: () {
      setMessage('Request timed out');
      setIsLoading(false);
      return false;
    });
  }
}
