import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:momos/widgets/loading_view.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:http/http.dart' as http;

class EditProfileScreenController extends GetxController {
  final storage = GetStorage();
  final firstNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final avatarUrl = "".obs;
  final ImagePicker _picker = ImagePicker();
  RxMap<String, dynamic> get userData =>
      Get.isRegistered<ProfileScreenController>()
      ? Get.find<ProfileScreenController>().userData
      : <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  void _loadProfileData() {
    avatarUrl.value = userData['profileImage'] ?? "";
    firstNameController.text = userData['name'] ?? "";
    emailController.text = userData['email'] ?? "";
    phoneController.text = userData['phoneNumber'] ?? "";
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    Color color = orange,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color == red ? red.withValues(alpha: 0.1) : logoutIconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color == red ? red : charcoalGray,
                fontSize: 14,
                fontFamily: natoMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display a dialog directing the user to device Settings when permission is permanently denied
  void _showPermissionSettingsDialog({
    required String title,
    required String message,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: natoBold,
            fontSize: 18,
            color: black,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: natoRegular,
            fontSize: 14,
            color: charcoalGray,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              "Cancel",
              style: TextStyle(fontFamily: natoMedium, color: charcoalGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            child: const Text(
              "Open Settings",
              style: TextStyle(fontFamily: natoMedium, color: white),
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet for selecting image source
  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (BuildContext ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Change Profile Photo",
                  style: TextStyle(
                    color: black,
                    fontSize: 18,
                    fontFamily: natoBold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Select photo from gallery or take a new one",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 13,
                    fontFamily: natoRegular,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPickerOption(
                      icon: Icons.camera_alt_rounded,
                      label: "Camera",
                      onTap: () {
                        Get.back();
                        pickImage(ImageSource.camera);
                      },
                    ),
                    _buildPickerOption(
                      icon: Icons.photo_library_rounded,
                      label: "Gallery",
                      onTap: () {
                        Get.back();
                        pickImage(ImageSource.gallery);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: borderGray),
                      ),
                    ),
                    onPressed: () => Get.back(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: charcoalGray,
                        fontSize: 15,
                        fontFamily: natoMedium,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Check and request Camera permission with proper Android and iOS handling
  Future<bool> _checkAndRequestCameraPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.camera.status;
      if (status.isGranted || status.isLimited) {
        return true;
      }
      if (status.isDenied) {
        final result = await Permission.camera.request();
        return result.isGranted || result.isLimited;
      }
      if (status.isPermanentlyDenied || status.isRestricted) {
        _showPermissionSettingsDialog(
          title: "Camera Permission Required",
          message:
              "Please allow camera access in your device settings to take a profile picture.",
        );
        return false;
      }
    } catch (e) {
      debugPrint("Camera permission check error: $e");
    }
    return true;
  }

  /// Check and request Gallery/Photo permission with proper Android and iOS handling
  Future<bool> _checkAndRequestGalleryPermission() async {
    if (kIsWeb) return true;
    try {
      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        if (status.isGranted || status.isLimited) {
          return true;
        }
        if (status.isDenied) {
          final result = await Permission.photos.request();
          return result.isGranted || result.isLimited;
        }
        if (status.isPermanentlyDenied || status.isRestricted) {
          _showPermissionSettingsDialog(
            title: "Photos Permission Required",
            message:
                "Please allow photo library access in your device settings to choose a profile picture.",
          );
          return false;
        }
      } else if (Platform.isAndroid) {
        // Android 13+ (API 33+) uses PhotoPicker which doesn't require runtime storage permission.
        // For older Android versions (SDK < 33), check storage or photos permission.
        final photoStatus = await Permission.photos.status;
        final storageStatus = await Permission.storage.status;
        if (photoStatus.isGranted ||
            photoStatus.isLimited ||
            storageStatus.isGranted ||
            storageStatus.isLimited) {
          return true;
        }
        // On Android 13+, Permission.photos handles READ_MEDIA_IMAGES
        final photoReq = await Permission.photos.request();
        if (photoReq.isGranted || photoReq.isLimited) {
          return true;
        }
        final storageReq = await Permission.storage.request();
        if (storageReq.isGranted) {
          return true;
        }
        if (photoReq.isPermanentlyDenied && storageReq.isPermanentlyDenied) {
          _showPermissionSettingsDialog(
            title: "Storage Permission Required",
            message:
                "Please allow photo/storage access in your device settings to select a profile picture.",
          );
          return false;
        }
      }
    } catch (e) {
      debugPrint("Gallery permission check error: $e");
    }
    return true;
  }

  /// Pick an image from Camera or Gallery with cross-platform support
  Future<void> pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        final hasPermission = await _checkAndRequestCameraPermission();
        if (!hasPermission) return;
      } else {
        final hasPermission = await _checkAndRequestGalleryPermission();
        if (!hasPermission) return;
      }
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (pickedFile != null) {
        dynamic data = await getSignedUrl();
        if (data != null) {
          String signedUrl = data['uploadUrl'];
          String profileUrl = data['fileUrl'];
          bool isUploaded = await uploadImageToServer(
            url: signedUrl,
            file: File(pickedFile.path),
          );
          if (isUploaded) {
            avatarUrl.value = profileUrl;
          } else {
            avatarUrl.value = userData['profileImage'] ?? "";
          }
        } else {
          avatarUrl.value = userData['profileImage'] ?? "";
          Get.snackbar(
            "Oops!",
            "Failed to get signed URL. Please try again.",
            icon: const Icon(Icons.error, color: Colors.red),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            backgroundColor: charcoalGray.withValues(alpha: 0.9),
          );
        }
      } else {
        avatarUrl.value = userData['profileImage'] ?? "";
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      avatarUrl.value = userData['profileImage'] ?? "";
      Get.snackbar(
        "Oops!",
        "Something went wrong. Please try again.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  Future<void> saveChanges() async {
    final name = firstNameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar(
        "Oops!",
        "First Name cannot be empty.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      return;
    }
    await updateUserProfile();
  }

  Future<dynamic> updateUserProfile() async {
    Get.dialog(const LoadingDialog(), barrierDismissible: false);
    var response = await http.put(
      Uri.parse(ApiServices.getAndUpdateProfile),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "${storage.read(userToken)}",
      },
      body: jsonEncode({
        "name": firstNameController.text.trim(),
        "profileImage": avatarUrl.value,
      }),
    );
    print('updateUserProfile Response status: ${response.statusCode}');
    print('updateUserProfile Response body: ${response.body}');
    if (Get.isDialogOpen!) {
      Get.back();
    }
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      userData.value = data["data"];
      Get.back();
    } else {
      Get.snackbar(
        "Oops!",
        data["message"] ??
            'We\'re unable to update your profile at the moment. Please try again later.',
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  Future<dynamic> getSignedUrl() async {
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpeg';
    print("getSignedUrl FileName :- $fileName");
    var response = await http.get(
      Uri.parse(
        ApiServices.uploadUrl
            .replaceAll("{fileName}", fileName)
            .replaceAll("{fileType}", "image/jpeg")
            .replaceAll("{folder}", "profiles"),
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "${storage.read(userToken)}",
      },
    );
    print('getSignedUrl Response status: ${response.statusCode}');
    print('getSignedUrl Response body: ${response.body}');
    var data = jsonDecode(response.body);
    if (response.statusCode == 200 && data["success"] == true) {
      return data["data"];
    } else {
      return null;
    }
  }

  Future<bool> uploadImageToServer({
    required String url,
    required File file,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'image/jpeg'},
        body: bytes,
      );
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('Upload response: ${response.body}');
        return true;
      }
      print('Upload failed: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      print('Upload error: $e');
      return false;
    }
  }
}
