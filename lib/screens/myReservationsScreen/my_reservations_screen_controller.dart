import 'package:get/get.dart';

class ReservationModel {
  final String id;
  final String restaurantName;
  final String restaurantAddress;
  final String restaurantImage;
  final int guests;
  final String scheduledTime;
  final String placedTime;
  final String status;

  ReservationModel({
    required this.id,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantImage,
    required this.guests,
    required this.scheduledTime,
    required this.placedTime,
    required this.status,
  });
}

class MyReservationsScreenController extends GetxController {
  final selectedStatus = "All".obs;
  final statusOptions = [
    "All",
    "Pending",
    "Confirmed",
    "Completed",
    "Cancelled",
  ];
  final reservationsList = <ReservationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockReservations();
  }

  void _loadMockReservations() {
    reservationsList.assignAll([
      ReservationModel(
        id: "15312",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        guests: 2,
        scheduledTime: "20/07/26, 07:00PM",
        placedTime: "20/07/26, 07:00PM",
        status: "Pending",
      ),
      ReservationModel(
        id: "15312",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        guests: 2,
        scheduledTime: "20/07/26, 07:00PM",
        placedTime: "20/07/26, 07:00PM",
        status: "Confirmed",
      ),
      ReservationModel(
        id: "15312",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        guests: 2,
        scheduledTime: "20/07/26, 07:00PM",
        placedTime: "20/07/26, 07:00PM",
        status: "Completed",
      ),
      ReservationModel(
        id: "15312",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        guests: 2,
        scheduledTime: "20/07/26, 07:00PM",
        placedTime: "20/07/26, 07:00PM",
        status: "Cancelled",
      ),
    ]);
  }

  List<ReservationModel> get filteredReservations {
    if (selectedStatus.value == "All") {
      return reservationsList;
    }
    return reservationsList
        .where(
          (res) =>
              res.status.toLowerCase() == selectedStatus.value.toLowerCase(),
        )
        .toList();
  }
}
