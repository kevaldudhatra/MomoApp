import 'package:get/get.dart';
import 'package:momos/screens/myReservationsScreen/my_reservations_screen_controller.dart';

class ReservationStatusScreenController extends GetxController {
  late final ReservationModel reservation;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is ReservationModel) {
      reservation = Get.arguments as ReservationModel;
    } else {
      // Fallback default mock reservation matching screenshot
      reservation = ReservationModel(
        id: "15312",
        restaurantName: "Momo I AM",
        restaurantAddress: "Alipore, Kolkata",
        restaurantImage:
            "https://images.unsplash.com/photo-1563245372-f21724e3856d?auto=format&fit=crop&q=80&w=150",
        guests: 1,
        scheduledTime: "Today at 07:00 PM",
        placedTime: "20/07/26, 07:00PM",
        status: "Completed",
      );
    }
  }
}
