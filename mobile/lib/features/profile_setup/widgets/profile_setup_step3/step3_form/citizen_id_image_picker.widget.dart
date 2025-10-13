// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'dart:io';

// import 'package:hourz/shared/index.dart';

// import '../../../providers/profile_setup.provider.dart';

// class CitizenIdImagePicker extends ConsumerWidget {
//   const CitizenIdImagePicker({super.key});

//   static final ImagePicker _picker = ImagePicker();

//   Future<void> _pickCitizenIdImage(BuildContext context, WidgetRef ref) async {
//     final XFile? image = await _picker.pickImage(
//       source: ImageSource.gallery,
//       maxWidth: 1200,
//       maxHeight: 1200,
//       imageQuality: 85,
//     );

//     if (image != null) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('อัปโหลดรูป Citizen ID เรียบร้อยแล้ว'),
//             backgroundColor: Color(0xFF00B4A6),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // ✅ Use .select() for better performance
//     // final citizenIdImagePath = ref.watch(
//     //   profileSetupProvider.select((s) => s.citizenIdImagePath),
//     // );
//     final hasUploadedImage =  true ;//citizenIdImagePath != null;
//     return GestureDetector(
//       onTap: () => _pickCitizenIdImage(context, ref),
//       child: Container(
//         width: double.infinity,
//         height: 220,
//         decoration: BoxDecoration(
//           border: Border.all(
//             color: AppColors.mutedForeground,
//             style: BorderStyle.solid,
//             width: 2,
//           ),
//           borderRadius: BorderRadius.circular(25),
//           color: hasUploadedImage
//               ? AppColors.mutedForeground
//               : AppColors.background,
//           image: citizenIdImagePath != null
//               ? DecorationImage(
//                   image: FileImage(File(citizenIdImagePath)),
//                   fit: BoxFit.cover,
//                 )
//               : null,
//         ),
//         child: citizenIdImagePath == null
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     hasUploadedImage ? Icons.check_circle : LucideIcons.upload,
//                     size: 48,
//                     color: hasUploadedImage
//                         ? AppColors.background
//                         : AppColors.mutedForeground,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     hasUploadedImage
//                         ? 'อัปโหลดเรียบร้อยแล้ว'
//                         : 'อัปโหลดรูปภาพบัตรประชาชน หรือพาสปอร์ต',
//                     style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                       color: hasUploadedImage
//                           ? AppColors.background
//                           : AppColors.mutedForeground,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'รองรับไฟล์ JPG, PNG ขนาดไม่เกิน 5MB',
//                     style: TextStyle(color: AppColors.mutedForeground),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               )
//             : Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//                 child: const Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.edit, size: 30, color: AppColors.background),
//                       SizedBox(height: 8),
//                       Text(
//                         'แตะเพื่อเปลี่ยนรูป',
//                         style: TextStyle(color: AppColors.background),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }
