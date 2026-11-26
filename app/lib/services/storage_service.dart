import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  /// Téléverse [file] sous `folder/` avec un nom unique, et renvoie son URL
  /// de téléchargement publique.
  Future<String> uploadFile(
    File file,
    String folder, {
    void Function(double progress)? onProgress,
  }) async {
    final name = file.path.split(Platform.pathSeparator).last;
    final safeName = name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final ref = FirebaseStorage.instance.ref().child(path);
    final task = ref.putFile(file);

    if (onProgress != null) {
      task.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
        }
      });
    }

    final completed = await task;
    return completed.ref.getDownloadURL();
  }
}
