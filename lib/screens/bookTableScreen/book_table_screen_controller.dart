import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/network/socket_service.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

class BookTableScreenController extends GetxController {
  StreamSubscription? _reservationCountStatusSubscription;
  StreamSubscription? _reconnectSubscription;
  final storage = GetStorage();
  final selectedDate = "".obs;
  final selectedGuests = 0.obs;
  final selectedPeriod = "".obs;
  final selectedTimeIndex = 0.obs;
  final selectedTime = "".obs;
  final isDateDropdownOpen = false.obs;
  final isGuestDropdownOpen = false.obs;
  final isLoading = true.obs;
  RxString closeNotes = "".obs;
  RxBool isTodayClosed = false.obs;
  RxInt reservationCount = 0.obs;
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
    fetchReservations();
    _listenToReservationStatusUpdate();
    _listenToSocketReconnect();
  }

  Future<void> refreshData() async {
    await Future.wait([
      checkOutletStatus(),
      getReservationBookingDetails(),
      fetchReservations(),
    ]);
  }

  @override
  void onClose() {
    _reservationCountStatusSubscription?.cancel();
    _reconnectSubscription?.cancel();
    super.onClose();
  }

  void _listenToSocketReconnect() {
    _reconnectSubscription?.cancel();
    _reconnectSubscription = SocketService().onReconnected.listen((_) {
      debugPrint(
        "BookTableScreenController => Socket reconnected: refreshing orders",
      );
      fetchReservations();
    });
  }

  void _listenToReservationStatusUpdate() {
    _reservationCountStatusSubscription?.cancel();
    _reservationCountStatusSubscription = SocketService()
        .onNewBookingCountReceived
        .listen((data) {
          debugPrint(
            "📦 Socket reservation update received in BookTableScreenController: $data",
          );
          if (data == null) return;
          reservationCount.value =
              int.tryParse(data['activeBookingCount'].toString()) ?? 0;
          debugPrint("✅ Updated reservationCount: ${reservationCount.value}");
          update();
        });
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

  Future<void> checkOutletStatus() async {
    if (Get.isRegistered<DeliveryScreenController>()) {
      print("checkOutletStatus isTodayClosed: $isTodayClosed $closeNotes");
      isTodayClosed.value =
          Get.find<DeliveryScreenController>().isTodayClosed.value;
      closeNotes.value = Get.find<DeliveryScreenController>().closeNotes.value;
    }
  }

  Future<void> fetchReservations() async {
    try {
      final url = ApiServices.getReservationCount
          .replaceAll('{page}', 1.toString())
          .replaceAll('{status}', 'all');
      print('fetchReservations count URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('fetchReservations count Status: ${response.statusCode}');
      print('fetchReservations count Body: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          final rawReservations = data['reservations'] as List<dynamic>? ?? [];
          reservationCount.value = rawReservations
              .where(
                (e) => e['status'] != 'completed' && e['status'] != 'cancelled',
              )
              .length;
        } else {
          reservationCount.value = 0;
        }
      } else {
        reservationCount.value = 0;
      }
    } catch (e) {
      print('fetchReservations count Error: $e');
      reservationCount.value = 0;
    }
  }

  Future<void> getReservationBookingDetails() async {
    try {
      isLoading.value = true;
      final outlateId = Get.isRegistered<DeliveryScreenController>()
          ? Get.find<DeliveryScreenController>().outlateDetails['id'] ?? 0
          : 0;
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
      } else {
        reservationData.value = {};
      }
    } catch (e) {
      reservationData.value = {};
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
