import 'package:get/get.dart';

class BookTableScreenController extends GetxController {
  final selectedDate = "Today".obs;
  final selectedGuests = 1.obs;
  final selectedPeriod = "Dinner".obs;
  final selectedTimeIndex = 2.obs;
  final isDateDropdownOpen = false.obs;
  final isGuestDropdownOpen = false.obs;
  final List<int> guestsList = [1, 2, 3, 4, 5, 6, 7];
  final List<String> periodsList = ["Lunch", "Dinner", "Late Night"];
  final List<String> datesList = [
    "Today",
    "Tomorrow",
    "Sat, 25 Jul",
    "Sun, 26 Jul",
    "Mon, 27 Jul",
  ];
  final List<String> timeSlots = [
    "06:00 PM",
    "06:00 PM",
    "06:00 PM",
    "06:00 PM",
    "06:00 PM",
    "06:00 PM",
  ];

  void selectDate(String date) {
    selectedDate.value = date;
    isDateDropdownOpen.value = false;
  }

  void selectGuests(int count) {
    selectedGuests.value = count;
    isGuestDropdownOpen.value = false;
  }
}
