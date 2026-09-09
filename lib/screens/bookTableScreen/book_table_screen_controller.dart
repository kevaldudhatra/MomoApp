import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookTableScreenController extends GetxController {
  final selectedDate = "Today".obs;
  final selectedGuests = 1.obs;
  final selectedPeriod = "Lunch".obs;
  final selectedTimeIndex = 0.obs;
  final selectedTime = "11:30 AM".obs;
  final isDateDropdownOpen = false.obs;
  final isGuestDropdownOpen = false.obs;
  final List<int> guestsList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  final List<String> periodsList = ["Lunch", "Dinner", "Late Night"];
  final List<String> datesList = List.generate(5, (index) {
    final date = DateTime.now().add(Duration(days: index));
    if (index == 0) {
      return "Today";
    } else {
      return DateFormat('EEE, dd MMM').format(date);
    }
  });

  final Map<String, List<String>> _periodTimeSlots = {
    "Lunch": [
      "11:30 AM",
      "12:00 PM",
      "12:30 PM",
      "1:00 PM",
      "1:30 PM",
      "2:00 PM",
    ],
    "Dinner": [
      "7:00 PM",
      "7:30 PM",
      "8:00 PM",
      "8:30 PM",
      "9:00 PM",
      "9:30 PM",
    ],
    "Late Night": [
      "10:00 PM",
      "10:30 PM",
      "11:00 PM",
      "11:30 PM",
      "12:00 AM",
      "12:30 AM",
    ],
  };

  List<String> get timeSlots => _periodTimeSlots[selectedPeriod.value] ?? [];

  void selectDate(String date) {
    selectedDate.value = date;
    isDateDropdownOpen.value = false;
  }

  void selectGuests(int count) {
    selectedGuests.value = count;
    isGuestDropdownOpen.value = false;
  }

  void selectPeriod(String period) {
    selectedPeriod.value = period;
    selectedTimeIndex.value = 0;
    if (period == "Lunch") {
      selectedTime.value = "11:30 AM";
    } else if (period == "Dinner") {
      selectedTime.value = "7:00 PM";
    } else {
      selectedTime.value = "10:00 PM";
    }
  }
}
