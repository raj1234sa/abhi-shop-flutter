import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:abhi_shop/widgets/icon_avatar.dart';
import 'package:http/http.dart' as http;

class ImageHelper {
  static final StorageReference storageReference =
      FirebaseStorage.instance.ref();
  static File imageFile;
  static Directory tempDir;

  Future<File> convertUriToFile({String url}) async {
    File file = new File(
        '${ImageHelper.tempDir.path}/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg');
    http.Response response = await http.get(url);
    File networkImage = await file.writeAsBytes(response.bodyBytes);
    return networkImage;
  }

  static Future<void> _takePicture(ImageSource type) async {
    final PickedFile image = await ImagePicker().getImage(
      source: type,
    );
    if (image != null) {
      final croppedImage = await ImageCropper.cropImage(
        sourcePath: image.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      );
      if (croppedImage != null) {
        print("Picked image path ${croppedImage.path}");
        ImageHelper.imageFile = croppedImage;
        print(ImageHelper.imageFile);
      }
    }
  }

  static void showImagePickerOption(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 80,
            margin: EdgeInsets.all(25),
            child: Row(
              children: [
                IconAvatar(
                  color: Colors.lightBlue,
                  icon: Icons.camera_alt,
                  name: 'Camera',
                  onPress: () {
                    Navigator.of(ctx).pop();
                    _takePicture(ImageSource.camera);
                  },
                ),
                IconAvatar(
                  color: Colors.teal,
                  icon: Icons.image,
                  name: 'Gallery',
                  onPress: () {
                    Navigator.of(ctx).pop();
                    _takePicture(ImageSource.gallery);
                  },
                ),
                IconAvatar(
                  color: Colors.redAccent,
                  icon: Icons.clear,
                  name: 'Clear',
                  onPress: () {
                    ImageHelper.imageFile = null;
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<String> uploadImage({
    @required File imageFile,
    @required String dirName,
    @required String imageName,
  }) async {
    StorageUploadTask uploadTask = ImageHelper.storageReference
        .child(dirName)
        .child(imageName)
        .putFile(imageFile);

    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
