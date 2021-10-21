import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileUploadService {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<String?> uploadFile(
      {required File file, required String userUid}) async {
    return _firebaseStorage
        .ref()
        .child('profile_images')
        .child('$userUid.jpg')
        .putFile(file)
        .then((value) => value.ref.getDownloadURL());

    // Reference storageRef =
    //     _firebaseStorage.ref().child('profile_images').child('$userUid.jpg');
    //
    // UploadTask task = storageRef.putFile(file);
    //
    // return task.whenComplete(() async {
    //   return await storageRef.getDownloadURL();
    // }).then((value) => value.ref.getDownloadURL());
  }
}
