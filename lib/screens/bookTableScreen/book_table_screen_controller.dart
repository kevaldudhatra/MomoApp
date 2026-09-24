import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class BookTableScreenController extends GetxController {
  final storage = GetStorage();
  final selectedDate = "".obs;
  final selectedGuests = 0.obs;
  final selectedPeriod = "".obs;
  final selectedTimeIndex = 0.obs;
  final selectedTime = "".obs;
  final isDateDropdownOpen = false.obs;
  final isGuestDropdownOpen = false.obs;
  final isLoading = true.obs;
  List<String> get timeSlots => periodTimeSlots[selectedPeriod.value] ?? [];
  final RxMap<String, dynamic> reservationData = <String, dynamic>{}.obs;
  final List<dynamic> allDateWithSlots = <dynamic>[].obs;
  final List<String> datesList = <String>[].obs;
  final RxList<int> guestsList = <int>[].obs;
  final RxList<String> periodsList = <String>[].obs;
  final RxMap<String, List<String>> periodTimeSlots =
      <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getReservationBookingDetails();
  }

  void selectDate(String date) {
    selectedDate.value = date;
    for (var element in allDateWithSlots) {
      if (element['label'] == date) {
        periodTimeSlots.clear();
        periodTimeSlots.assignAll(
          (element['slotsByTimeOfDay'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
              key == 'lateNight'
                  ? 'Late Night'
                  : '${key[0].toUpperCase()}${key.substring(1)}',
              (value as List<dynamic>)
                  .map((item) => item['label'] as String)
                  .toList(),
            ),
          ),
        );
        selectedPeriod.value = periodsList.first;
        final slots = periodTimeSlots[selectedPeriod.value] ?? [];
        selectedTime.value = slots.isNotEmpty ? slots.first : "";
        selectedTimeIndex.value = 0;
      }
    }
    isDateDropdownOpen.value = false;
  }

  void selectGuests(int count) {
    selectedGuests.value = count;
    isGuestDropdownOpen.value = false;
  }

  void selectPeriod(String period) {
    selectedPeriod.value = period;
    selectedTimeIndex.value = 0;
    final slots = periodTimeSlots[period] ?? [];
    selectedTime.value = slots.isNotEmpty ? slots.first : "";
  }

  Future<void> getReservationBookingDetails() async {
    try {
      isLoading.value = true;
      final outlateId =
          Get.find<DeliveryScreenController>().outlateDetails['id'];
      final response = await http.get(
        Uri.parse(
          ApiServices.getReservationBookingDetails.replaceAll(
            '{outlateId}',
            outlateId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print(
        'getReservationBookingDetails Response status: ${response.statusCode}',
      );
      print('getReservationBookingDetails Response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        reservationData.value = Map<String, dynamic>.from(data['data'] ?? {});
        _parseReservationData(data['data']);
      }
    } catch (e) {
      print('getReservationBookingDetails Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _parseReservationData(dynamic data) {
    if (data == null) {
      return;
    }

    allDateWithSlots.assignAll(data['dates'] ?? []);
    print("allDateWithSlots.value: $allDateWithSlots");

    final List<String> datesOptions = List<String>.from(
      data['dates']?.map((e) => e['label']) ?? [],
    );
    datesList.assignAll(datesOptions);

    final List<int> guestOptions = List<int>.from(data['guestOptions'] ?? []);
    guestsList.assignAll(guestOptions);

    final List<String> periodOptions = List<String>.from(
      data['timeOfDayOptions']?.map((e) => e['label']) ?? [],
    );
    periodsList.assignAll(periodOptions);

    if (allDateWithSlots.isNotEmpty) {
      periodTimeSlots.assignAll(
        (data['dates']?.first['slotsByTimeOfDay'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key == 'lateNight'
                ? 'Late Night'
                : '${key[0].toUpperCase()}${key.substring(1)}',
            (value as List<dynamic>)
                .map((item) => item['label'] as String)
                .toList(),
          ),
        ),
      );
    }

    // Set defaults
    if (datesList.isNotEmpty) {
      selectedDate.value = datesList.first;
    }
    if (guestsList.isNotEmpty) {
      selectedGuests.value = guestsList.first;
    }
    if (periodsList.isNotEmpty) {
      selectedPeriod.value = periodsList.first;
      final slots = periodTimeSlots[selectedPeriod.value] ?? [];
      selectedTime.value = slots.isNotEmpty ? slots.first : "";
    }
  }
}
