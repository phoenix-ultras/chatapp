import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  UserImagePicker({super.key, required this.onPickImage});

  void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  //selectedImage variable
  File? _selectedImage;

//upload image from gallery
  void _imagePickerGallery() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 150);

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    //selected image will be passed to auth screen
    widget.onPickImage(_selectedImage!);
  }

//upload image from camera
  void _imagePickerCamera() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
    });
    //selected image will be passed to auth screen
    widget.onPickImage(_selectedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 35,
          foregroundImage:
              //if selected image is not null then _selectedImage will be displayed
              //else null will be returned
              _selectedImage != null ? FileImage(_selectedImage!) : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _imagePickerCamera,
              icon: const Icon(Icons.image),
              label: const Text('Take Image'),
            ),
            TextButton.icon(
              onPressed: _imagePickerGallery,
              icon: const Icon(Icons.upload),
              label: const Text('upload Image'),
            )
          ],
        )
      ],
    );
  }
}
