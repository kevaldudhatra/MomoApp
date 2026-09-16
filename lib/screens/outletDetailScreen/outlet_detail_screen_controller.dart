import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class OutletReview {
  final String userName;
  final String userInitial;
  final String timeAgo;
  final double rating;
  final String comment;

  OutletReview({
    required this.userName,
    required this.userInitial,
    required this.timeAgo,
    required this.rating,
    required this.comment,
  });
}

// Data model representing opening hours for a day
class DayOpeningHours {
  final String day;
  final String timeSlots;

  DayOpeningHours({required this.day, required this.timeSlots});
}

// Bottom Sheet Widget displaying Outlet Opening Hours
class OpeningHoursBottomSheet extends StatelessWidget {
  final List<DayOpeningHours> openingHours;
  final VoidCallback? onClose;

  const OpeningHoursBottomSheet({
    super.key,
    required this.openingHours,
    this.onClose,
  });

  // Helper static method to show the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required List<DayOpeningHours> openingHours,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      isDismissible: false,
      enableDrag: false,
      builder: (context) {
        return OpeningHoursBottomSheet(
          openingHours: openingHours,
          onClose: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: onClose ?? () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 44,
              height: 44,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: const BoxDecoration(
                color: black,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardShadow,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  AppImages().closeIcon,
                  width: 18,
                  height: 18,
                  color: white,
                ),
              ),
            ),
          ),

          // Main White Bottom Sheet Container
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Title
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Text(
                        "Opening Hours",
                        style: TextStyle(
                          fontFamily: natoBold,
                          fontSize: 18,
                          color: black,
                        ),
                      ),
                    ),

                    // Header Bottom Line Divider
                    const Divider(height: 1, thickness: 1, color: borderGray),

                    // Scrollable List of Days and Time Slots
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(openingHours.length, (index) {
                            final dayItem = openingHours[index];
                            final isLast = index == openingHours.length - 1;
                            return _buildDayRow(dayItem, showDivider: !isLast);
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Builds a single day timing row with divider
  Widget _buildDayRow(DayOpeningHours dayItem, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Day Name Text
              Text(
                dayItem.day,
                style: const TextStyle(
                  fontFamily: natoBold,
                  fontSize: 16,
                  color: black,
                ),
              ),

              // Time Slots List
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  dayItem.timeSlots,
                  style: const TextStyle(
                    fontFamily: natoRegular,
                    fontSize: 14.5,
                    color: black,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: borderGray),
      ],
    );
  }
}

class OutletDetailScreenController extends GetxController {
  final storage = GetStorage();
  RxBool isLoading = true.obs;
  RxString outletName = "".obs;
  RxString fullAddress = "".obs;
  RxString contactNumber = "".obs;
  RxString openingStatus = "".obs;
  RxString openingHoursInfo = "".obs;
  RxList<DayOpeningHours> openingHoursList = <DayOpeningHours>[].obs;
  RxList<OutletReview> reviews = <OutletReview>[].obs;
  Rx<LatLng> outletLocation = LatLng(0, 0).obs;
  final outletId = Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails['id']
      : 0;

  @override
  void onInit() {
    super.onInit();
    _loadOutletDetails();
  }

  void _loadOutletDetails() async {
    try {
      isLoading.value = true;
      await Future.wait([
        getOutletDetails(outletID: outletId),
        getOutletReview(outletID: outletId),
      ]);
    } catch (e) {
      print('loadOutletDetails Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  String timeAgo(String dateString) {
    final date = DateTime.parse(dateString).toLocal();
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void showOpeningHoursBottomSheet(BuildContext context) {
    OpeningHoursBottomSheet.show(context, openingHours: openingHoursList);
  }

  Future<void> makePhoneCall() async {
    final Uri uri = Uri(scheme: 'tel', path: contactNumber.value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Get.snackbar('Error', 'Unable to open phone dialer');
    }
  }

  Future<void> getOutletDetails({int? outletID}) async {
    try {
      openingHoursList.clear();
      final response = await http.get(
        Uri.parse(
          ApiServices.getAllOutlateDetails.replaceAll(
            '{outletID}',
            '$outletID',
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getOutletDetails Response status: ${response.statusCode}');
      print('getOutletDetails Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        outletLocation.value = LatLng(
          data['data']['latitude'],
          data['data']['longitude'],
        );
        outletName.value = data['data']['name'] ?? '';
        fullAddress.value =
            "${data['data']['address']}, ${data['data']['city']}, ${data['data']['state']} - ${data['data']['pinCode']}, ${data['data']['country']}";
        contactNumber.value =
            "${data['data']['countryCode']}${data['data']['phoneNo']}";
        openingStatus.value = data['data']['isOpen'] == true
            ? "Open"
            : "Closed";
        openingHoursInfo.value = data['data']['isOpen'] == true
            ? "Available Now"
            : "Not Available";
        openingHoursList.assignAll(
          data['data']['openingHours'].map<DayOpeningHours>((e) {
            return DayOpeningHours(
              day: e['dayName'],
              timeSlots: e['hours'].isNotEmpty
                  ? e['hours'][0]['display']
                  : 'Closed',
            );
          }).toList(),
        );
      }
    } catch (e) {
      print('getOutletDetails Error: $e');
      isLoading.value = false;
    }
  }

  Future<void> getOutletReview({int? outletID}) async {
    try {
      reviews.clear();
      final response = await http.get(
        Uri.parse(
          ApiServices.getOutletReview.replaceAll('{outletID}', '$outletID'),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getOutletReview Response status: ${response.statusCode}');
      print('getOutletReview Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        reviews.assignAll(
          data['data']['ratings'].map<OutletReview>((e) {
            return OutletReview(
              userName: e['user']['name'],
              userInitial: e['user']['name'].substring(0, 1).toString(),
              timeAgo: timeAgo(e['createdAt']),
              rating: double.parse(e['rate'].toString()),
              comment: e['message'] ?? "",
            );
          }).toList(),
        );
      } else {
        reviews.clear();
      }
    } catch (e) {
      print('getOutletReview Error: $e');
      reviews.clear();
      isLoading.value = false;
    }
  }
}
