import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:momos/network/api_services.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/addressSelectionScreen/address_selection_screen_controller.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/deliveryScreen/delivery_screen_controller.dart';
import 'package:momos/screens/bookTableScreen/book_table_screen_controller.dart';
import 'package:momos/screens/profileScreen/profile_screen_controller.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/screens/searchAddressScreen/search_address_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';
import 'package:momos/utils/const_key.dart';
import 'package:http/http.dart' as http;

// Models for dynamic delivery schedule and time slots
class DeliverySlot {
  final String start;
  final String end;
  final String label;
  final bool isAvailable;
  final int remaining;
  final String? disabledReason;

  const DeliverySlot({
    required this.start,
    required this.end,
    required this.label,
    this.isAvailable = true,
    this.remaining = 0,
    this.disabledReason,
  });

  factory DeliverySlot.fromJson(Map<String, dynamic> json) {
    return DeliverySlot(
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      isAvailable: json['isAvailable'] == true,
      remaining: json['remaining'] is int
          ? json['remaining']
          : int.tryParse(json['remaining']?.toString() ?? '') ?? 0,
      disabledReason: json['disabledReason']?.toString(),
    );
  }
}

class DeliveryDaySchedule {
  final String date;
  final String label;
  final int day;
  final String dayName;
  final bool isOpen;
  final List<DeliverySlot> slots;

  const DeliveryDaySchedule({
    required this.date,
    required this.label,
    required this.day,
    required this.dayName,
    required this.isOpen,
    required this.slots,
  });

  factory DeliveryDaySchedule.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'] as List<dynamic>? ?? [];
    return DeliveryDaySchedule(
      date: json['date']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      day: json['day'] is int
          ? json['day']
          : int.tryParse(json['day']?.toString() ?? '') ?? 0,
      dayName: json['dayName']?.toString() ?? '',
      isOpen: json['isOpen'] == true,
      slots: rawSlots.map<DeliverySlot>((s) {
        if (s is Map<String, dynamic>) {
          return DeliverySlot.fromJson(s);
        } else if (s is Map) {
          return DeliverySlot.fromJson(Map<String, dynamic>.from(s));
        }
        return const DeliverySlot(start: '', end: '', label: '');
      }).toList(),
    );
  }
}

// Model for dynamic payment methods
class PaymentMethodItem {
  final int id;
  final String name;

  PaymentMethodItem({required this.id, required this.name});

  factory PaymentMethodItem.fromJson(Map<String, dynamic> json) {
    return PaymentMethodItem(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'],
    );
  }

  String get iconPath {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('cash')) {
      return AppImages().codIcon;
    } else if (lowerName.contains('wallet')) {
      return AppImages().walletIcon;
    } else if (lowerName.contains('phonepe')) {
      return AppImages().phonePeIcon;
    } else if (lowerName.contains('gpay')) {
      return AppImages().gPeIcon;
    }
    return AppImages().paymentIcon;
  }
}

// Bottom Sheet Widget for selecting scheduled delivery date and time.
class DeliveryScheduleBottomSheet extends StatefulWidget {
  final List<DeliveryDaySchedule> schedules;
  final String initialDate;
  final String initialTime;
  final Function(String selectedDate, String selectedTime) onConfirm;
  final VoidCallback onDeliverNow;
  final VoidCallback onClose;

  const DeliveryScheduleBottomSheet({
    super.key,
    required this.schedules,
    required this.initialDate,
    required this.initialTime,
    required this.onConfirm,
    required this.onDeliverNow,
    required this.onClose,
  });

  // Helper static method to show the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required List<DeliveryDaySchedule> schedules,
    required String initialDate,
    required String initialTime,
    required Function(String selectedDate, String selectedTime) onConfirm,
    required VoidCallback onDeliverNow,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return DeliveryScheduleBottomSheet(
          schedules: schedules,
          initialDate: initialDate,
          initialTime: initialTime,
          onConfirm: onConfirm,
          onDeliverNow: onDeliverNow,
          onClose: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  State<DeliveryScheduleBottomSheet> createState() =>
      _DeliveryScheduleBottomSheetState();
}

class _DeliveryScheduleBottomSheetState
    extends State<DeliveryScheduleBottomSheet> {
  late List<DeliveryDaySchedule> _schedules;
  late List<String> _daysList;
  late String _selectedDate;
  late int _selectedTimeIndex;

  List<DeliverySlot> get _currentSlots {
    if (_schedules.isEmpty) return [];
    final matchingDay = _schedules.firstWhereOrNull(
      (s) => s.label == _selectedDate || s.date == _selectedDate,
    );
    return matchingDay?.slots ?? [];
  }

  DeliveryDaySchedule? get _currentDaySchedule {
    if (_schedules.isEmpty) return null;
    return _schedules.firstWhereOrNull(
      (s) => s.label == _selectedDate || s.date == _selectedDate,
    );
  }

  @override
  void initState() {
    super.initState();
    _schedules = widget.schedules;
    _daysList = _schedules
        .map(
          (s) => s.label.trim().isNotEmpty
              ? s.label
              : (s.dayName.isNotEmpty ? s.dayName : s.date),
        )
        .toList();

    _selectedDate = widget.initialDate;
    if (!_daysList.contains(_selectedDate)) {
      final firstOpenWithSlots = _schedules.firstWhereOrNull(
        (s) => s.isOpen && s.slots.any((slot) => slot.isAvailable),
      );
      if (firstOpenWithSlots != null) {
        _selectedDate = firstOpenWithSlots.label.isNotEmpty
            ? firstOpenWithSlots.label
            : firstOpenWithSlots.date;
      } else if (_daysList.isNotEmpty) {
        _selectedDate = _daysList.first;
      } else {
        _selectedDate = "Today";
      }
    }

    _updateSelectedTimeIndex(initialTime: widget.initialTime);
  }

  void _updateSelectedTimeIndex({String? initialTime}) {
    final slots = _currentSlots;
    if (slots.isEmpty) {
      _selectedTimeIndex = -1;
      return;
    }

    if (initialTime != null && initialTime.isNotEmpty) {
      final index = slots.indexWhere((s) => s.label == initialTime);
      if (index != -1 && slots[index].isAvailable) {
        _selectedTimeIndex = index;
        return;
      }
    }

    final firstAvailable = slots.indexWhere((s) => s.isAvailable);
    _selectedTimeIndex = firstAvailable != -1 ? firstAvailable : 0;
  }

  void _onDaySelected(String day) {
    if (_selectedDate == day) return;
    setState(() {
      _selectedDate = day;
      _updateSelectedTimeIndex();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final currentDay = _currentDaySchedule;
    final slots = _currentSlots;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: widget.onClose,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Header
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 14),
                    child: Text(
                      "Select your delivery time",
                      style: TextStyle(
                        fontFamily: natoBold,
                        fontSize: 18,
                        color: black,
                      ),
                    ),
                  ),

                  // Horizontal Days Selector Row
                  if (_daysList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Text(
                        "No delivery schedule available",
                        style: TextStyle(
                          fontFamily: natoRegular,
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 16,
                      ),
                      child: Row(
                        children: _schedules.map((schedule) {
                          final dayLabel = schedule.label.trim().isNotEmpty
                              ? schedule.label
                              : (schedule.dayName.isNotEmpty
                                    ? schedule.dayName
                                    : schedule.date);
                          final isSelected = _selectedDate == dayLabel;
                          final isOpen = schedule.isOpen;

                          return GestureDetector(
                            onTap: () => _onDaySelected(dayLabel),
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? orange : white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? orange : borderGray,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                dayLabel,
                                style: TextStyle(
                                  fontFamily: natoMedium,
                                  fontSize: 14,
                                  color: isSelected
                                      ? white
                                      : (isOpen ? charcoalGray : textSecondary),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  // Divider Line
                  const Divider(height: 1, thickness: 1, color: borderGray),

                  // Scrollable Grid of Time Slots or Status Message
                  Flexible(
                    child: currentDay?.isOpen == false
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.store_mall_directory_outlined,
                                    size: 40,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Store is closed on this day",
                                    style: TextStyle(
                                      fontFamily: natoMedium,
                                      fontSize: 15,
                                      color: charcoalGray,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Please choose another delivery date",
                                    style: TextStyle(
                                      fontFamily: natoRegular,
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : slots.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.access_time_outlined,
                                    size: 40,
                                    color: textSecondary,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "No time slots available",
                                    style: TextStyle(
                                      fontFamily: natoMedium,
                                      fontSize: 15,
                                      color: charcoalGray,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    "Please choose another delivery date",
                                    style: TextStyle(
                                      fontFamily: natoRegular,
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: 4,
                                ),
                            itemCount: slots.length,
                            itemBuilder: (context, index) {
                              final slot = slots[index];
                              final isSelected = _selectedTimeIndex == index;
                              final isAvailable = slot.isAvailable;

                              return GestureDetector(
                                onTap: isAvailable
                                    ? () {
                                        setState(() {
                                          _selectedTimeIndex = index;
                                        });
                                      }
                                    : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? white
                                        : segmentedBg.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? orange
                                          : (isAvailable
                                                ? borderGray
                                                : borderGray.withValues(
                                                    alpha: 0.5,
                                                  )),
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      slot.label,
                                      style: TextStyle(
                                        fontFamily: isSelected
                                            ? natoMedium
                                            : natoRegular,
                                        fontSize: 14,
                                        color: isSelected
                                            ? orange
                                            : (isAvailable
                                                  ? charcoalGray
                                                  : lightGray),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // Bottom Action Buttons Area
                  const Divider(height: 1, thickness: 1, color: borderGray),

                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          // Deliver Now Button
                          Expanded(
                            child: GestureDetector(
                              onTap: widget.onDeliverNow,
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: borderGray,
                                    width: 1,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Deliver Now",
                                    style: TextStyle(
                                      fontFamily: natoMedium,
                                      fontSize: 15,
                                      color: charcoalGray,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Confirm Button
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (slots.isEmpty ||
                                    _selectedTimeIndex < 0 ||
                                    _selectedTimeIndex >= slots.length ||
                                    !slots[_selectedTimeIndex].isAvailable) {
                                  Get.snackbar(
                                    "Schedule Delivery",
                                    "Please select an available delivery time slot",
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: charcoalGray.withValues(
                                      alpha: 0.9,
                                    ),
                                    colorText: Colors.white,
                                  );
                                  return;
                                }
                                final selectedTime =
                                    slots[_selectedTimeIndex].label;
                                widget.onConfirm(_selectedDate, selectedTime);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      (slots.isNotEmpty &&
                                          _selectedTimeIndex >= 0 &&
                                          _selectedTimeIndex < slots.length &&
                                          slots[_selectedTimeIndex].isAvailable)
                                      ? orange
                                      : orange.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Confirm",
                                    style: TextStyle(
                                      fontFamily: natoMedium,
                                      fontSize: 15,
                                      color: white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet Widget for selecting a delivery address.
class AddressSelectionBottomSheet extends StatelessWidget {
  final RxList<SavedAddress> addresses;
  final RxString? selectedTitle;
  final RxInt? selectedAddressId;
  final Function(SavedAddress address) onSelect;
  final VoidCallback onAddNewAddress;
  final Function(SavedAddress address) onDeleteAddress;
  final VoidCallback onClose;

  const AddressSelectionBottomSheet({
    super.key,
    required this.addresses,
    this.selectedTitle,
    this.selectedAddressId,
    required this.onSelect,
    required this.onAddNewAddress,
    required this.onDeleteAddress,
    required this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required RxList<SavedAddress> addresses,
    dynamic selectedTitle,
    dynamic selectedAddressId,
    required Function(SavedAddress address) onSelect,
    required Function(SavedAddress address) onDeleteAddress,
    required VoidCallback onAddNewAddress,
    VoidCallback? onClose,
  }) {
    final RxInt? rxSelectedAddressId = selectedAddressId is RxInt
        ? selectedAddressId
        : (selectedAddressId is int ? selectedAddressId.obs : null);
    final RxString? rxSelectedTitle = selectedTitle is RxString
        ? selectedTitle
        : (selectedTitle is String ? selectedTitle.obs : null);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return AddressSelectionBottomSheet(
          addresses: addresses,
          selectedTitle: rxSelectedTitle,
          selectedAddressId: rxSelectedAddressId,
          onSelect: onSelect,
          onDeleteAddress: onDeleteAddress,
          onAddNewAddress: onAddNewAddress,
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
      constraints: BoxConstraints(maxHeight: screenHeight * 0.80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: onClose,
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

          // Main Bottom Sheet Body Container
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: background, // gray background behind the cards
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add New Address Button
                      GestureDetector(
                        onTap: onAddNewAddress,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          margin: const EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Add New Address",
                                style: TextStyle(
                                  fontFamily: natoMedium,
                                  fontSize: 15,
                                  color: white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Reactive Saved Address list
                      Obx(() {
                        if (addresses.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                "No saved addresses found",
                                style: TextStyle(
                                  fontFamily: natoRegular,
                                  fontSize: 14,
                                  color: textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Saved Address",
                              style: TextStyle(
                                fontFamily: natoMedium,
                                fontSize: 14,
                                color: sectionHeaderColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: addresses.map((address) {
                                final isSelected =
                                    selectedAddressId?.value == address.id;
                                return GestureDetector(
                                  onTap: () {
                                    selectedAddressId?.value = address.id;
                                    selectedTitle?.value = address.type;
                                    onSelect(address);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? orange
                                            : Colors.transparent,
                                        width: isSelected ? 1.5 : 0,
                                      ),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: cardShadow,
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Address Icon
                                        Image.asset(
                                          address.icon,
                                          width: 22,
                                          height: 22,
                                          color: isSelected
                                              ? orange
                                              : charcoalGray,
                                        ),
                                        const SizedBox(width: 12),

                                        // Address Text Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                address.type,
                                                style: const TextStyle(
                                                  fontFamily: natoBold,
                                                  fontSize: 15,
                                                  color: black,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                address.address,
                                                style: const TextStyle(
                                                  fontFamily: natoRegular,
                                                  fontSize: 13,
                                                  color: textSecondary,
                                                  height: 1.35,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Delete Icon
                                        GestureDetector(
                                          onTap: () => onDeleteAddress(address),
                                          child: Image.asset(
                                            AppImages().deleteIcon,
                                            width: 22,
                                            height: 22,
                                            color: orange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bottom Sheet Widget for displaying detailed bill breakdown.
class BillDetailsBottomSheet extends StatelessWidget {
  final OrderDetailScreenController controller;
  final VoidCallback onClose;

  const BillDetailsBottomSheet({
    super.key,
    required this.controller,
    required this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context,
    OrderDetailScreenController controller, {
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return BillDetailsBottomSheet(
          controller: controller,
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
      constraints: BoxConstraints(maxHeight: screenHeight * 0.80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: onClose,
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

          // Main Bottom Sheet Body Container
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: background, // gray background behind the cards
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Text "Bill details"
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                        child: Text(
                          "Bill details",
                          style: TextStyle(
                            fontFamily: natoBold,
                            fontSize: 16,
                            color: black,
                          ),
                        ),
                      ),

                      // Card-like White Container for items
                      Obx(() {
                        final items = <Widget>[];

                        // Item Total
                        items.add(
                          _buildBillRow(
                            label: "Item Total",
                            value: "₹${controller.subtotal.toStringAsFixed(2)}",
                          ),
                        );

                        // Delivery Charge
                        final isDeliveryFree = controller.deliveryFee == 0.0;
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "Delivery Charge",
                              value: isDeliveryFree
                                  ? "FREE"
                                  : "₹${controller.deliveryFee.toDouble().toStringAsFixed(2)}",
                              valueColor: isDeliveryFree ? greenBadge : black,
                              valueFontFamily: isDeliveryFree
                                  ? natoBold
                                  : natoRegular,
                            ),
                          ),
                        );

                        // Coupon Discount (only if > 0)
                        if (controller.promoDiscount.value > 0.0) {
                          items.add(
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: _buildBillRow(
                                label: "Coupon Discount",
                                value:
                                    "₹${controller.promoDiscount.value.toDouble().toStringAsFixed(2)}",
                              ),
                            ),
                          );
                        }

                        // Packaging Charge
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "Packaging Charge",
                              value:
                                  "₹${controller.packagingCharge.toDouble().toStringAsFixed(2)}",
                            ),
                          ),
                        );

                        // CGST
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "CGST(2.5%)",
                              value:
                                  "₹${controller.cgst.toDouble().toStringAsFixed(2)}",
                            ),
                          ),
                        );

                        // SGST
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "SGST(2.5%)",
                              value:
                                  "₹${controller.sgst.toDouble().toStringAsFixed(2)}",
                            ),
                          ),
                        );

                        // Divider
                        items.add(
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14.0),
                            child: Divider(
                              height: 1,
                              thickness: 1,
                              color: borderGray,
                            ),
                          ),
                        );

                        // Total Row
                        items.add(
                          _buildBillRow(
                            label: "Total",
                            value:
                                "₹${controller.totalBill.toDouble().toStringAsFixed(2)}",
                            labelFontFamily: natoBold,
                            valueFontFamily: natoBold,
                            fontSize: 15,
                          ),
                        );

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 18.0,
                          ),
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: const [
                              BoxShadow(
                                color: cardShadow,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: items,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow({
    required String label,
    required String value,
    Color? valueColor,
    String? labelFontFamily,
    String? valueFontFamily,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: labelFontFamily ?? natoRegular,
            fontSize: fontSize,
            color: black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: valueFontFamily ?? natoRegular,
            fontSize: fontSize,
            color: valueColor ?? black,
          ),
        ),
      ],
    );
  }
}

// Bottom Sheet Widget for selecting a payment method.
class PaymentMethodBottomSheet extends StatefulWidget {
  final List<PaymentMethodItem> paymentMethods;
  final String selectedMethod;
  final int selectedPaymentId;
  final Function(PaymentMethodItem method) onSelect;
  final VoidCallback onClose;

  const PaymentMethodBottomSheet({
    super.key,
    required this.paymentMethods,
    required this.selectedMethod,
    required this.selectedPaymentId,
    required this.onSelect,
    required this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required List<PaymentMethodItem> paymentMethods,
    required String selectedMethod,
    required int selectedPaymentId,
    required Function(PaymentMethodItem method) onSelect,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return PaymentMethodBottomSheet(
          paymentMethods: paymentMethods,
          selectedMethod: selectedMethod,
          selectedPaymentId: selectedPaymentId,
          onSelect: onSelect,
          onClose: () {
            onClose?.call();
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  @override
  State<PaymentMethodBottomSheet> createState() =>
      _PaymentMethodBottomSheetState();
}

class _PaymentMethodBottomSheetState extends State<PaymentMethodBottomSheet> {
  int? selectedPaymentId;
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedPaymentId = widget.selectedPaymentId;
    selectedMethod = widget.selectedMethod;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.80),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating Circular Close Button positioned above the bottom sheet
          GestureDetector(
            onTap: widget.onClose,
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

          // Main Bottom Sheet Body Container
          Flexible(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: background, // gray background behind the cards
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Text "Payment method"
                      const Padding(
                        padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
                        child: Text(
                          "Payment method",
                          style: TextStyle(
                            fontFamily: natoBold,
                            fontSize: 16,
                            color: black,
                          ),
                        ),
                      ),

                      // Card-like White Container for options
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 18.0,
                        ),
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: const [
                            BoxShadow(
                              color: cardShadow,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.paymentMethods.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Text(
                                  "No payment methods available",
                                  style: TextStyle(
                                    fontFamily: natoRegular,
                                    fontSize: 14,
                                    color: charcoalGray,
                                  ),
                                ),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.paymentMethods.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 18),
                                itemBuilder: (context, index) {
                                  final method = widget.paymentMethods[index];
                                  final isSelected =
                                      selectedPaymentId == method.id;
                                  return _buildPaymentRow(
                                    context: context,
                                    method: method,
                                    isSelected: isSelected,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow({
    required BuildContext context,
    required PaymentMethodItem method,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPaymentId = method.id;
          selectedMethod = method.name;
        });
        widget.onSelect(method);
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Image.asset(method.iconPath, width: 24, height: 24),
          const SizedBox(width: 14),
          Text(
            method.name,
            style: const TextStyle(
              fontFamily: natoRegular,
              fontSize: 14,
              color: black,
            ),
          ),
          const Spacer(),
          _buildRadioIcon(isSelected),
        ],
      ),
    );
  }

  Widget _buildRadioIcon(bool isSelected) {
    if (isSelected) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: orange, width: 2),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: orange,
          ),
        ),
      );
    } else {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: lightGray, width: 1.5),
        ),
      );
    }
  }
}

class OrderDetailScreenController extends GetxController {
  final storage = GetStorage();
  final cookingNoteController = TextEditingController();
  final promoCodeController = TextEditingController();
  RxBool isLoading = true.obs;
  RxList<DeliveryDaySchedule> scheduleList = <DeliveryDaySchedule>[].obs;
  RxList<SavedAddress> userAddressList = <SavedAddress>[].obs;
  RxBool isPromocodeApplied = false.obs;
  RxInt promocodeId = 0.obs;
  RxDouble promoDiscount = 0.0.obs;
  RxString deliveryTime = "Delivering now".obs;
  RxString selectedScheduleDate = "Today".obs;
  RxString selectedScheduleTime = "".obs;
  RxList<PaymentMethodItem> paymentMethodList = <PaymentMethodItem>[].obs;
  RxString selectedPaymentMethod = "".obs;
  RxInt selectedPaymentId = 0.obs;
  RxInt selectedAddressId = 0.obs;
  RxString addressTitle = "".obs;
  RxString addressSubtitle = "".obs;
  RxMap<dynamic, dynamic> get outletDetails =>
      Get.isRegistered<DeliveryScreenController>()
      ? Get.find<DeliveryScreenController>().outlateDetails
      : {}.obs;
  RxMap<dynamic, dynamic> get billDetails => Get.isRegistered<CartController>()
      ? Get.find<CartController>().billDetails
      : {}.obs;
  RxList<dynamic> get cartItems => Get.isRegistered<CartController>()
      ? Get.find<CartController>().cartItems
      : <dynamic>[].obs;
  RxList<dynamic> get foodItems => Get.isRegistered<OutletScreenController>()
      ? Get.find<OutletScreenController>().foodItems
      : <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    getDeliverySlots(outletDetails['id']);
    getUserAddress();
    getPaymentMethods(outletDetails['id']);
    loadData();
  }

  @override
  void onClose() {
    cookingNoteController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }

  String convertToApiDate(String inputDate) {
    final now = DateTime.now();
    final date = inputDate.trim().toLowerCase();
    if (date == 'today') {
      return DateFormat('yyyy-MM-dd').format(now);
    }
    if (date == 'tomorrow') {
      final tomorrow = now.add(const Duration(days: 1));
      return DateFormat('yyyy-MM-dd').format(tomorrow);
    }
    try {
      final parsedDate = DateFormat('EEE, dd MMM').parse(inputDate);
      final finalDate = DateTime(now.year, parsedDate.month, parsedDate.day);
      return DateFormat('yyyy-MM-dd').format(finalDate);
    } catch (e) {
      throw FormatException('Invalid date format: $inputDate');
    }
  }

  Map<String, String> convertTimeRange(String timeRange) {
    final parts = timeRange.split(' - ');
    if (parts.length != 2) {
      throw FormatException('Invalid time range: $timeRange');
    }
    final inputFormat = DateFormat('h:mm a');
    final outputFormat = DateFormat('HH:mm');
    final startTime = inputFormat.parse(parts[0].trim());
    final endTime = inputFormat.parse(parts[1].trim());
    return {
      'startTime': outputFormat.format(startTime),
      'endTime': outputFormat.format(endTime),
    };
  }

  Future<void> loadData() async {
    isLoading.value = true;
    Future.delayed(Duration(seconds: 1), () async {
      await Get.find<CartController>().getCartItem();
      isLoading.value = false;
    });
  }

  Future<void> getDeliverySlots(int outletId) async {
    try {
      scheduleList.clear();
      final response = await http.get(
        Uri.parse(
          ApiServices.getDeliverySlots.replaceAll(
            '{outletId}',
            outletId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getDeliverySlots Response status: ${response.statusCode}');
      print('getDeliverySlots Response body: ${response.body}');
      if (response.statusCode != 200) {
        scheduleList.clear();
        return;
      }
      final data = jsonDecode(response.body);
      if (data['success'] != true ||
          data['data'] == null ||
          data['data']['dates'] is! List) {
        scheduleList.clear();
        return;
      }
      final schedule = data['data']['dates'] as List;
      scheduleList.assignAll(
        schedule.map<DeliveryDaySchedule>((e) {
          if (e is Map<String, dynamic>) {
            return DeliveryDaySchedule.fromJson(e);
          } else if (e is Map) {
            return DeliveryDaySchedule.fromJson(Map<String, dynamic>.from(e));
          }
          return const DeliveryDaySchedule(
            date: '',
            label: '',
            day: 0,
            dayName: '',
            isOpen: false,
            slots: [],
          );
        }).toList(),
      );
    } catch (e) {
      scheduleList.clear();
      print('getDeliverySlots Error: $e');
    }
  }

  Future<void> getUserAddress() async {
    try {
      final response = await http.get(
        Uri.parse(ApiServices.userAddress),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getUserAddress Response status: ${response.statusCode}');
      print('getUserAddress Response body: ${response.body}');
      if (response.statusCode != 200) {
        userAddressList.clear();
        return;
      }
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['data'] is! List) {
        userAddressList.clear();
        return;
      }
      final addresses = data['data'] as List;
      userAddressList.assignAll(
        addresses.map<SavedAddress>((address) {
          final type = address['type']?.toString() ?? '';
          final icon = switch (type) {
            'Home' => AppImages().homeIcon,
            'Work' => AppImages().workIcon,
            _ => AppImages().locationIcon,
          };
          final subtitle =
              [
                    address['houseNo'],
                    address['appartment'],
                    address['landmark'],
                    address['city'],
                  ]
                  .where(
                    (value) =>
                        value != null && value.toString().trim().isNotEmpty,
                  )
                  .join(', ');
          final pinCode = address['pinCode']?.toString() ?? '';
          return SavedAddress(
            id: address['id'],
            type: type,
            address: '$subtitle - $pinCode.',
            icon: icon,
            isDefault: address['isDefault'],
          );
        }),
      );
      if (userAddressList.isNotEmpty) {
        final defaultAddress = userAddressList.firstWhere(
          (element) => element.isDefault,
          orElse: () => userAddressList.first,
        );
        selectedAddressId.value = defaultAddress.id;
        addressTitle.value = defaultAddress.type;
        addressSubtitle.value = defaultAddress.address;
      }
    } catch (e) {
      userAddressList.clear();
      print('getUserAddress Error: $e');
    }
  }

  Future<bool> deleteUserAddress(int addressId) async {
    try {
      var response = await http.delete(
        Uri.parse(
          ApiServices.deleteUserAddress.replaceFirst(
            "{addressId}",
            addressId.toString(),
          ),
        ),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "${storage.read(userToken)}",
        },
      );
      print('deleteUserAddress Response status: ${response.statusCode}');
      print('deleteUserAddress Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('deleteUserAddress Error: $e');
      return false;
    }
  }

  Future<void> getPaymentMethods(int outletId) async {
    try {
      paymentMethodList.clear();
      final response = await http.get(
        Uri.parse(
          ApiServices.getPaymentMethod.replaceAll(
            '{outletId}',
            outletId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
      );
      print('getPaymentMethods Response status: ${response.statusCode}');
      print('getPaymentMethods Response body: ${response.body}');
      if (response.statusCode != 200) {
        paymentMethodList.clear();
        return;
      }
      final data = jsonDecode(response.body);
      if (data['success'] != true || data['data'] is! List) {
        paymentMethodList.clear();
        return;
      }
      final paymentMethods = data['data'] as List;
      final activePaymentMethods = paymentMethods
          .where((item) => item['isActive'] == true)
          .toList();
      paymentMethodList.assignAll(
        activePaymentMethods.map<PaymentMethodItem>((method) {
          return PaymentMethodItem.fromJson(method);
        }),
      );
      print("payment method list => $paymentMethodList");
      if (paymentMethodList.isNotEmpty) {
        final defaultMethod = paymentMethodList.firstWhere(
          (element) => element.name.toLowerCase() == 'cash on delivery',
          orElse: () => paymentMethodList.first,
        );
        selectedPaymentMethod.value = defaultMethod.name;
        selectedPaymentId.value = defaultMethod.id;
      }
    } catch (e) {
      paymentMethodList.clear();
      print('payment method list Error: $e');
    }
  }

  Future<void> incrementQuantity({required dynamic itemData}) async {
    print('incrementQuantity Input: ${itemData['quantity']}');
    try {
      final response = await http.patch(
        Uri.parse(
          ApiServices.updateItemQuantity.replaceAll(
            '{itemId}',
            itemData['itemId'].toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "quantity": itemData["quantity"] + 1,
          "itemPriceId": itemData["itemPriceId"],
        }),
      );
      print('incrementQuantity Response status: ${response.statusCode}');
      print('incrementQuantity Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.find<CartController>().addItemToCart(
          cartItem: data["data"]["items"],
          billData: data["data"]["bill"],
        );
        for (var element in foodItems) {
          if (element["category"]["id"] == itemData["categoryId"]) {
            for (var item in element["items"]) {
              if (item["id"] == itemData["itemId"]) {
                item["cartCount"] = itemData["quantity"] + 1;
              }
            }
          }
        }
        foodItems.refresh();
        for (var element
            in Get.find<DeliveryScreenController>().outletTopPicks) {
          if (element["id"] == itemData["itemId"] &&
              element["categoryId"] == itemData["categoryId"]) {
            element["cartCount"] = itemData["quantity"] + 1;
          }
        }
        Get.find<DeliveryScreenController>().outletTopPicks.refresh();
      } else {
        foodItems.refresh();
        Get.find<DeliveryScreenController>().outletTopPicks.refresh();
        Get.snackbar(
          "Oops!",
          data['message'] ?? "Something went wrong. Please try again.",
          snackPosition: SnackPosition.TOP,
          icon: const Icon(Icons.error, color: Colors.red),
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('incrementQuantity Error: $e');
      foodItems.refresh();
      Get.find<DeliveryScreenController>().outletTopPicks.refresh();
    }
  }

  Future<void> decrimentQuantity({required dynamic itemData}) async {
    print('decrimentQuantity Input: ${itemData['quantity']}');
    try {
      final response = await http.patch(
        Uri.parse(
          ApiServices.updateItemQuantity.replaceAll(
            '{itemId}',
            itemData['itemId'].toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({
          "quantity": itemData["quantity"] - 1,
          "itemPriceId": itemData["itemPriceId"],
        }),
      );
      print('decrimentQuantity Response status: ${response.statusCode}');
      print('decrimentQuantity Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        Get.find<CartController>().addItemToCart(
          cartItem: data["data"]["items"],
          billData: data["data"]["bill"],
        );
        for (var element in foodItems) {
          if (element["category"]["id"] == itemData["categoryId"]) {
            for (var item in element["items"]) {
              if (item["id"] == itemData["itemId"]) {
                item["cartCount"] = itemData["quantity"] - 1;
              }
            }
          }
        }
        foodItems.refresh();
        for (var element
            in Get.find<DeliveryScreenController>().outletTopPicks) {
          if (element["id"] == itemData["itemId"] &&
              element["categoryId"] == itemData["categoryId"]) {
            element["cartCount"] = itemData["quantity"] - 1;
          }
        }
        Get.find<DeliveryScreenController>().outletTopPicks.refresh();
      } else {
        foodItems.refresh();
        Get.find<DeliveryScreenController>().outletTopPicks.refresh();
      }
    } catch (e) {
      print('decrimentQuantity Error: $e');
      foodItems.refresh();
      Get.find<DeliveryScreenController>().outletTopPicks.refresh();
    }
  }

  Future<void> orderValidation() async {
    if (selectedAddressId.value == 0) {
      Get.snackbar(
        "Oops!",
        "Please select delivery address.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
      return;
    }
    if (deliveryTime.value == "Delivering now") {
      Map<String, dynamic> payload = {
        "addressId": selectedAddressId.value,
        "paymentSettingId": selectedPaymentId.value,
        "cookingNote": cookingNoteController.text.trim(),
        "deliveryType": "now",
      };
      if (isPromocodeApplied.value) {
        payload["promocodeId"] = promocodeId.value;
        payload["promocodeCode"] = promoCodeController.text.trim().toString();
      }
      await placeOrder(orderData: payload);
    } else {
      final dateResult = convertToApiDate(selectedScheduleDate.value);
      final timeResult = convertTimeRange(selectedScheduleTime.value);
      Map<String, dynamic> payload = {
        "addressId": selectedAddressId.value,
        "paymentSettingId": selectedPaymentId.value,
        "cookingNote": cookingNoteController.text.trim(),
        "deliveryType": "schedule",
        "scheduledDate": dateResult,
        "scheduledSlotStart": timeResult['startTime'],
        "scheduledSlotEnd": timeResult['endTime'],
      };
      if (isPromocodeApplied.value) {
        payload["promocodeId"] = promocodeId.value;
        payload["promocodeCode"] = promoCodeController.text.trim().toString();
      }
      await placeOrder(orderData: payload);
    }
  }

  Future<void> placeOrder({dynamic orderData}) async {
    try {
      final response = await http.post(
        Uri.parse(ApiServices.placeOrder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode(orderData),
      );
      print('placeOrder Response status: ${response.statusCode}');
      print('placeOrder Response body: ${response.body}');
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data["success"] == true) {
        Get.snackbar(
          "Success",
          "Order placed successfully!",
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
        cartItems.clear();
        foodItems.clear();
        outletDetails.value = {};
        await Get.delete<DeliveryScreenController>(force: true);
        await Get.delete<BookTableScreenController>(force: true);
        await Get.delete<ProfileScreenController>(force: true);
        await Get.offAllNamed(Routes.homeScreen);
      } else {
        Get.snackbar(
          "oops!",
          data["message"] ?? "Something went wrong. Please try again.",
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      }
    } catch (e) {
      print('placeOrder Error: $e');
      Get.snackbar(
        "oops!",
        "Something went wrong. Please try again.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  Future<void> verifyPromocode({int? outletId, int? promocodeId}) async {
    print("verifyPromocode input:$outletId");
    print("verifyPromocode input:${promoCodeController.text.trim()}");
    try {
      final response = await http.post(
        Uri.parse(
          ApiServices.verifyPromocode.replaceAll(
            '{outlateId}',
            outletId.toString(),
          ),
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '${storage.read(userToken)}',
        },
        body: jsonEncode({"promocodeId": promocodeId}),
      );
      print('verifyPromocode Response status: ${response.statusCode}');
      print('verifyPromocode Response body: ${response.body}');
      var data = jsonDecode(response.body);
      if (response.statusCode == 200 && data["success"] == true) {
        isPromocodeApplied.value = true;
        promoDiscount.value = double.parse(
          data["data"]["promocode"]["discountAmt"].toString(),
        );
        Get.snackbar(
          "Success",
          data["data"]["message"],
          icon: const Icon(Icons.done, color: Colors.green),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      } else {
        isPromocodeApplied.value = false;
        promoDiscount.value = 0.0;
        Get.snackbar(
          "Oops!",
          data["message"],
          icon: const Icon(Icons.error, color: Colors.red),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          backgroundColor: charcoalGray.withValues(alpha: 0.9),
        );
      }
    } catch (e) {
      isPromocodeApplied.value = false;
      promoDiscount.value = 0.0;
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

  // Shows the delivery schedule bottom sheet
  void showScheduleBottomSheet(BuildContext context) {
    DeliveryScheduleBottomSheet.show(
      context,
      schedules: scheduleList,
      initialDate: selectedScheduleDate.value,
      initialTime: selectedScheduleTime.value,
      onConfirm: (date, time) {
        selectedScheduleDate.value = date;
        selectedScheduleTime.value = time;
        deliveryTime.value = "Delivering on : $date, $time";
        Get.back();
      },
      onDeliverNow: () {
        deliveryTime.value = "Delivering now";
        Get.back();
      },
    );
  }

  // Shows the address bottom sheet
  void showAddressBottomSheet(BuildContext ctx) {
    AddressSelectionBottomSheet.show(
      ctx,
      addresses: userAddressList,
      selectedTitle: addressTitle,
      selectedAddressId: selectedAddressId,
      onDeleteAddress: (address) async {
        bool isDeleted = await deleteUserAddress(address.id);
        if (isDeleted) {
          userAddressList.removeWhere((element) => element.id == address.id);
          if (userAddressList.isNotEmpty) {
            final defaultAddress = userAddressList.firstWhere(
              (element) => element.isDefault,
              orElse: () => userAddressList.first,
            );
            selectedAddressId.value = defaultAddress.id;
            addressTitle.value = defaultAddress.type;
            addressSubtitle.value = defaultAddress.address;
          } else {
            selectedAddressId.value = 0;
            addressTitle.value = "";
            addressSubtitle.value = "";
          }
          userAddressList.refresh();
        }
      },
      onSelect: (address) {
        selectedAddressId.value = address.id;
        addressTitle.value = address.type;
        addressSubtitle.value = address.address;
        Get.back();
      },
      onAddNewAddress: () async {
        await storage.write(isFromOrder, true);
        await storage.write(isFromProfile, false);
        Future.delayed(const Duration(milliseconds: 500), () {
          if (Get.isRegistered<SearchAddressScreenController>()) {
            Get.delete<SearchAddressScreenController>();
          }
          Get.toNamed(Routes.searchAddressScreen);
        });
      },
    );
  }

  // Shows the bill details bottom sheet
  void showBillDetailsBottomSheet(BuildContext context) {
    BillDetailsBottomSheet.show(context, this);
  }

  // Shows the payment method bottom sheet
  void showPaymentMethodBottomSheet(BuildContext context) {
    PaymentMethodBottomSheet.show(
      context,
      paymentMethods: paymentMethodList,
      selectedMethod: selectedPaymentMethod.value,
      selectedPaymentId: selectedPaymentId.value,
      onSelect: (method) {
        selectedPaymentMethod.value = method.name;
        selectedPaymentId.value = method.id;
        Get.back();
      },
    );
  }

  void applyPromoCode() {
    final code = promoCodeController.text.trim();
    if (code.isEmpty && promocodeId.value == 0) {
      Get.snackbar(
        "Oops!",
        "Please enter a promocode.",
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Colors.red),
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }

    verifyPromocode(
      outletId: outletDetails['id'],
      promocodeId: promocodeId.value,
    );
  }

  void removePromocode() {
    isPromocodeApplied.value = false;
    promoDiscount.value = 0.0;
    promocodeId.value = 0;
    promoCodeController.clear();
    Get.snackbar(
      "Success",
      "Promocode removed successfully!",
      icon: const Icon(Icons.done, color: Colors.green),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: charcoalGray.withValues(alpha: 0.9),
    );
  }

  // Calculated values
  double get subtotal => (billDetails['itemTotal'] as num).toDouble();

  double get deliveryFee => (billDetails['deliveryCharge'] as num).toDouble();

  double get packagingCharge =>
      (billDetails['packagingCharge'] as num).toDouble();

  double get cgst => isPromocodeApplied.value
      ? ((subtotal + packagingCharge + deliveryFee) - (promoDiscount.value)) *
            2.5 /
            100
      : (billDetails['cgstAmount'] as num).toDouble();

  double get sgst => isPromocodeApplied.value
      ? ((subtotal + packagingCharge + deliveryFee) - (promoDiscount.value)) *
            2.5 /
            100
      : (billDetails['sgstAmount'] as num).toDouble();

  double get totalBill => isPromocodeApplied.value
      ? (subtotal +
            deliveryFee +
            packagingCharge +
            cgst +
            sgst -
            promoDiscount.value)
      : (billDetails['grandTotal'] as num).toDouble();
}
