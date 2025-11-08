import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:verby_flutter/presentation/providers/room_checlist_provider.dart';

class AddCommentAndPicDialog extends ConsumerStatefulWidget {
  const AddCommentAndPicDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AddCommentAndPicDialogState();
  }
}

class _AddCommentAndPicDialogState
    extends ConsumerState<AddCommentAndPicDialog> {
  final TextEditingController _controller = TextEditingController();
  List<File> _selectedImages = [];

  void _submitComment() {
    if (_controller.text.isNotEmpty) {
      print('Comment submitted: ${_controller.text}');
      print('Selected images: ${_selectedImages.length}');
      _controller.clear();
      _selectedImages.clear();
      setState(() {});
    }
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              15.verticalSpace,
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _captureFromCamera();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              ListTile(
                leading: Icon(Icons.close),
                title: Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _captureFromCamera() async {
    try {
      // Request camera permission
      bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showCameraPermissionDialog();
        return;
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(roomChecklistProvider.notifier).addImage(File(image.path));
      }
    } catch (e) {
      print('Error capturing image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      // Request appropriate permissions based on Android version
      bool hasPermission = await _requestImagePermission();
      if (!hasPermission) {
        _showPermissionDialog();
        return;
      }

      // Pick images using file_picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        // allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          ref
              .read(roomChecklistProvider.notifier)
              .addImage(File(result.files[0].path ?? ""));
        });
      }
    } catch (e) {
      showToast('Error picking images: $e');
    }
  }

  Future<bool> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      return status.isGranted;
    }
    return status.isGranted;
  }

  Future<bool> _requestImagePermission() async {
    if (Platform.isAndroid) {
      var status = await Permission.photos.status;
      if (!status.isGranted) {
        status = await Permission.photos.request();
        if (status.isGranted) {
          return true;
        }
      } else {
        return true;
      }

      status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
        return status.isGranted;
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Permission Required',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            Platform.isAndroid
                ? 'Photo access permission is required to pick images from your gallery.'
                : 'Photo library access is required to pick images.',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCameraPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            'Camera Permission Required',
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            'Camera permission is required to capture photos.',
            style: TextStyle(color: Colors.black),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text(
                'Open Settings',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget listPicItem(File file, int index) {
    return Container(
      margin: EdgeInsets.only(right: 10.w),
      child: Stack(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(file, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: GestureDetector(
              onTap: () {
                ref.read(roomChecklistProvider.notifier).removeImage(index);
              },
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(roomChecklistProvider);
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "add_details".tr(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextField(
              controller: _controller,
              style: TextStyle(fontSize: 16.sp),
              onChanged: (text) {},
              maxLines: 3,
              keyboardType: TextInputType.multiline,
              // Enables multiline input
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'write_comment'.tr(),
                label: Text(
                  "Comment".tr(),
                  style: TextStyle(color: Colors.black),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(
                    color: Colors.black, // Custom focus color
                    width: 2.0,
                  ),
                ),
                counterText: "",
              ),
            ),

            // Display selected images
            if (state.selectedImages?.isNotEmpty == true) ...[
              20.verticalSpace,
              SizedBox(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.selectedImages?.length,
                  itemBuilder: (context, index) {
                    final file = state.selectedImages![index];
                    return listPicItem(file, index);
                  },
                ),
              ),
            ],

            30.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.r),

              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: _showImageSourceDialog,

                  borderRadius: BorderRadius.circular(15.r),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.r),

                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.white, size: 20.r),
                          3.horizontalSpace,
                          Text(
                            "Add Picture".tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            20.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.r),

              child: SizedBox(
                width: double.infinity,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },

                  borderRadius: BorderRadius.circular(15.r),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.r),

                      child: Center(
                        child: Text(
                          "Done".tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
