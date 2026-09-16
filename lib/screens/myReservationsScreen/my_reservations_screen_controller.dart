import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

String formatDateTime(String date, String time) {
  final inputFormat = DateFormat('yyyy-MM-dd HH:mm');
  final outputFormat = DateFormat('dd/MM/yy, hh:mma');
  final dateTime = inputFormat.parse('$date $time');
  return outputFormat.format(dateTime);
}

String formatReservationDateTime(String value) {
  final dateTime = DateTime.parse(value).toLocal();
  return DateFormat('dd/MM/yy, hh:mma').format(dateTime);
}

class ReservationModel {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantImage;
  final int guests;
  final String scheduledTime;
  final String placedTime;
  final String status;
  final String phoneNumber;

  ReservationModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantImage,
    required this.guests,
    required this.scheduledTime,
    required this.placedTime,
    required this.status,
    required this.phoneNumber,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'].toString(),
      restaurantName: json['outlate']['name'].toString(),
      restaurantAddress:
          "${json['outlate']['address']?.toString()}, ${json['outlate']['city']?.toString()}, ${json['outlate']['state']?.toString()}",
      restaurantImage: json['outlate']['brandLogo']?.toString() ?? '',
      guests: json['guestCount'] is int
          ? json['guestCount']
          : int.tryParse(json['guestCount'].toString()),
      scheduledTime: formatDateTime(json['bookingDate'], json['bookingTime']),
      placedTime: formatReservationDateTime(json['placedAt']),
      status: json['status'].toString(),
      phoneNumber: json['outlate']['phoneNo'].toString(),
    );
  }
}

class MyReservationsScreenController extends GetxController {
  final storage = GetStorage();
  final scrollController = ScrollController();
  final reservationsList = <ReservationModel>[].obs;
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final isNextPage = false.obs;
  final activeCount = 0.obs;
  final currentPage = 1.obs;
  final limit = 10.obs;
  final hasError = false.obs;
  final errorMessage = "".obs;
  final selectedStatus = "All".obs;
  final statusOptions = [
    "All",
    "Pending",
    "Confirmed",
    "Completed",
    "Cancelled",
  ];

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    fetchReservations(page: 1, isRefresh: true);
    ever(selectedStatus, (_) {
      fetchReservations(page: 1, isRefresh: true);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.hasClients &&
        scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isMoreLoading.value && isNextPage.value) {
        fetchReservations(page: currentPage.value + 1);
      }
    }
  }

  Future<void> fetchReservations({int page = 1, bool isRefresh = false}) async {
    if (isLoading.value || isMoreLoading.value) return;
    if (isRefresh || page == 1) {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = "";
    } else {
      isMoreLoading.value = true;
    }
    try {
      final statusParam = selectedStatus.value.toLowerCase() == 'all'
          ? 'all'
          : selectedStatus.value.toLowerCase() == 'pending'
          ? 'pending'
          : selectedStatus.value.toLowerCase() == 'confirmed'
          ? 'confirmed'
          : selectedStatus.value.toLowerCase() == 'completed'
          ? 'completed'
          : selectedStatus.value.toLowerCase() == 'cancelled'
          ? 'cancelled'
          : 'all';
      final url = ApiServices.getReservations
          .replaceAll('{page}', page.toString())
          .replaceAll('{status}', statusParam);

      print('fetchReservations URL: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('fetchReservations Status: ${response.statusCode}');
      print('fetchReservations Body: ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final data = json['data'];
          final rawReservations = data['reservations'] as List<dynamic>? ?? [];
          final newItems = rawReservations.map<ReservationModel>((item) {
            if (item is Map<String, dynamic>) {
              return ReservationModel.fromJson(item);
            } else if (item is Map) {
              return ReservationModel.fromJson(Map<String, dynamic>.from(item));
            }
            return ReservationModel.fromJson({});
          }).toList();
          currentPage.value = data['page'] is int
              ? data['page']
              : int.tryParse(data['page']?.toString() ?? '') ?? page;
          limit.value = data['limit'] is int
              ? data['limit']
              : int.tryParse(data['limit']?.toString() ?? '') ?? 10;
          isNextPage.value = data['isNextPage'] == true;
          activeCount.value = data['activeCount'] is int
              ? data['activeCount']
              : int.tryParse(data['activeCount']?.toString() ?? '') ?? 0;
          if (isRefresh || page == 1) {
            reservationsList.assignAll(newItems);
          } else {
            reservationsList.addAll(newItems);
          }
        } else {
          if (isRefresh || page == 1) {
            reservationsList.clear();
          }
          isNextPage.value = false;
        }
      } else {
        hasError.value = true;
        errorMessage.value = "Failed to fetch reservations";
        if (isRefresh || page == 1) {
          reservationsList.clear();
        }
      }
    } catch (e) {
      print('fetchReservations Error: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
      if (isRefresh || page == 1) {
        reservationsList.clear();
      }
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  List<ReservationModel> get filteredReservations {
    return reservationsList;
  }
}
