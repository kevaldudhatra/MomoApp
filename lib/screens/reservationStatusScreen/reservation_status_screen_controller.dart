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
      reservation = ReservationModel(
        id: "",
        restaurantName: "",
        restaurantAddress: "",
        restaurantImage: "",
        guests: 0,
        scheduledTime: "",
        placedTime: "",
        status: "",
        phoneNumber: "",
      );
    }
  }
}
