import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ProfileImagePicker extends ConsumerWidget {
  final bool isDisabled;
  const ProfileImagePicker({super.key, required this.isDisabled});

  static final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 100,
    );
    if (image != null) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: GestureDetector(
        onTap: isDisabled ? null : () => _pickImage(context, ref),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[300],
            // image: profileImagePath != null
            //     ? DecorationImage(
            //         image: FileImage(File(profileImagePath)),
            //         fit: BoxFit.cover,
            //       )
            //     : null,
          ),
          // child: profileImagePath == null
          //     ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
          //     : Container(
          //         decoration: BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Colors.black.withAlpha(30),
          //         ),
          //         child: const Icon(
          //           Icons.camera_alt,
          //           size: 30,
          //           color: Colors.white,
          //         ),
          //       ),
        ),
      ),
    );
  }
}
