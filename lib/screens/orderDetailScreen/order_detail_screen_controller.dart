import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:momos/routes/app_pages.dart';
import 'package:momos/screens/cartManagement/cart_controller.dart';
import 'package:momos/screens/outletScreen/outlet_screen_controller.dart';
import 'package:momos/utils/const_colors_key.dart';
import 'package:momos/utils/const_fonts_key.dart';
import 'package:momos/utils/const_image_key.dart';

class SavedAddress {
  final String title;
  final String subtitle;
  final String icon;

  SavedAddress({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

// Bottom Sheet Widget for selecting scheduled delivery date and time.
class DeliveryScheduleBottomSheet extends StatefulWidget {
  final String initialDate;
  final String initialTime;
  final Function(String selectedDate, String selectedTime) onConfirm;
  final VoidCallback onDeliverNow;
  final VoidCallback onClose;

  const DeliveryScheduleBottomSheet({
    super.key,
    required this.initialDate,
    required this.initialTime,
    required this.onConfirm,
    required this.onDeliverNow,
    required this.onClose,
  });

  // Helper static method to show the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
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
  late String _selectedDate;
  late int _selectedTimeIndex;

  final List<String> _daysList = [
    "Today",
    "Tomorrow",
    "Mon, 20 Jul",
    "Tue, 21 Jul",
    "Wed, 22 Jul",
    "Thu, 23 Jul",
  ];

  // List of mock time slots
  final List<String> _timeSlots = List.generate(
    20,
    (_) => "12:30 PM - 12:45 PM",
  );

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (_daysList.contains(_selectedDate) == false) {
      _selectedDate = _daysList[1]; // Default to "Tomorrow" if not found
    }

    _selectedTimeIndex = _timeSlots.indexOf(widget.initialTime);
    if (_selectedTimeIndex == -1) {
      _selectedTimeIndex =
          2; // Default to index 2 (matching the screenshot selection)
    }
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
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 16,
                    ),
                    child: Row(
                      children: _daysList.map((day) {
                        final isSelected = _selectedDate == day;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
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
                              day,
                              style: TextStyle(
                                fontFamily: natoMedium,
                                fontSize: 14,
                                color: isSelected ? white : charcoalGray,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  // Divider Line
                  const Divider(height: 1, thickness: 1, color: borderGray),

                  // Scrollable Grid of Time Slots
                  Flexible(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 12,
                            childAspectRatio: 4,
                          ),
                      itemCount: _timeSlots.length,
                      itemBuilder: (context, index) {
                        final slot = _timeSlots[index];
                        final isSelected = _selectedTimeIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTimeIndex = index;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? orange : borderGray,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slot,
                                style: TextStyle(
                                  fontFamily: isSelected
                                      ? natoMedium
                                      : natoRegular,
                                  fontSize: 14,
                                  color: isSelected ? orange : charcoalGray,
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
                                final selectedTime =
                                    _timeSlots[_selectedTimeIndex];
                                widget.onConfirm(_selectedDate, selectedTime);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: orange,
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
class AddressSelectionBottomSheet extends StatefulWidget {
  final List<SavedAddress> addresses;
  final String selectedTitle;
  final Function(SavedAddress address) onSelect;
  final VoidCallback onAddNewAddress;
  final VoidCallback onClose;

  const AddressSelectionBottomSheet({
    super.key,
    required this.addresses,
    required this.selectedTitle,
    required this.onSelect,
    required this.onAddNewAddress,
    required this.onClose,
  });

  // Helper static method to display the bottom sheet cleanly
  static Future<void> show(
    BuildContext context, {
    required List<SavedAddress> addresses,
    required String selectedTitle,
    required Function(SavedAddress address) onSelect,
    required VoidCallback onAddNewAddress,
    VoidCallback? onClose,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: dialogBarrierColor,
      builder: (context) {
        return AddressSelectionBottomSheet(
          addresses: addresses,
          selectedTitle: selectedTitle,
          onSelect: onSelect,
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
  State<AddressSelectionBottomSheet> createState() =>
      _AddressSelectionBottomSheetState();
}

class _AddressSelectionBottomSheetState
    extends State<AddressSelectionBottomSheet> {
  String? selectedTitle;

  @override
  void initState() {
    super.initState();
    selectedTitle = widget.selectedTitle;
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Add New Address Button
                      GestureDetector(
                        onTap: widget.onAddNewAddress,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: double.infinity,
                          height: 48,
                          margin: EdgeInsets.only(top: 10),
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

                      // "Saved Address" Section Header
                      const Text(
                        "Saved Address",
                        style: TextStyle(
                          fontFamily: natoMedium,
                          fontSize: 14,
                          color: sectionHeaderColor,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Saved Address cards list
                      Column(
                        children: widget.addresses.map((address) {
                          final isSelected = selectedTitle == address.title;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTitle = address.title;
                              });
                              widget.onSelect(address);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Address Icon
                                  Image.asset(
                                    address.icon,
                                    width: 22,
                                    height: 22,
                                    color: isSelected ? orange : charcoalGray,
                                  ),
                                  const SizedBox(width: 12),

                                  // Address Text Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          address.title,
                                          style: const TextStyle(
                                            fontFamily: natoBold,
                                            fontSize: 15,
                                            color: black,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          address.subtitle,
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
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
                            value: "₹${controller.subtotal.toInt()}",
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
                                  : "₹${controller.deliveryFee.toInt()}",
                              valueColor: isDeliveryFree ? greenFree : black,
                              valueFontFamily: isDeliveryFree
                                  ? natoBold
                                  : natoRegular,
                            ),
                          ),
                        );

                        // Packaging Charge
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "Packaging Charge",
                              value: "₹${controller.packagingCharge.toInt()}",
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
                                    "₹${controller.promoDiscount.value.toInt()}",
                              ),
                            ),
                          );
                        }

                        // GST
                        items.add(
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: _buildBillRow(
                              label: "GST",
                              value: "₹${controller.gst.toInt()}",
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
                            value: "₹${controller.totalBill.toInt()}",
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
class PaymentMethodBottomSheet extends StatelessWidget {
  final OrderDetailScreenController controller;
  final VoidCallback onClose;

  const PaymentMethodBottomSheet({
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
        return PaymentMethodBottomSheet(
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
                      Obx(() {
                        final selectedMethod = controller.paymentMethod.value;
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
                            children: [
                              _buildPaymentRow(
                                context: context,
                                label: "Cash on delivery",
                                iconPath: AppImages().codIcon,
                                isSelected:
                                    selectedMethod == "Cash on delivery",
                              ),
                              const SizedBox(height: 18),
                              _buildPaymentRow(
                                context: context,
                                label: "Wallet",
                                iconPath: AppImages().walletIcon,
                                isSelected: selectedMethod == "Wallet",
                              ),
                              const SizedBox(height: 18),
                              _buildPaymentRow(
                                context: context,
                                label: "Phonepe",
                                iconPath: AppImages().phonePeIcon,
                                isSelected: selectedMethod == "Phonepe",
                              ),
                              const SizedBox(height: 18),
                              _buildPaymentRow(
                                context: context,
                                label: "G pay",
                                iconPath: AppImages().gPeIcon,
                                isSelected: selectedMethod == "G pay",
                              ),
                            ],
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

  Widget _buildPaymentRow({
    required BuildContext context,
    required String label,
    required String iconPath,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        controller.paymentMethod.value = label;
        onClose();
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(width: 14),
          Text(
            label,
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
  RxList<CartItem> get cartItems => Get.isRegistered<CartController>()
      ? Get.find<CartController>().cartItems
      : <CartItem>[].obs;
  RxList<MenuCategory> get categories =>
      Get.isRegistered<OutletScreenController>()
      ? Get.find<OutletScreenController>().categories
      : <MenuCategory>[].obs;
  final cookingNoteController = TextEditingController();
  final promoCodeController = TextEditingController();
  final userAddressList = <SavedAddress>[].obs;
  final promoDiscount = 0.0.obs;
  final deliveryTime = "Delivering now".obs;
  final selectedScheduleDate = "Tomorrow".obs;
  final selectedScheduleTime = "12:30 PM - 12:45 PM".obs;
  final addressTitle = "Other".obs;
  final paymentMethod = "Cash on delivery".obs;
  final addressSubtitle =
      "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002"
          .obs;

  @override
  void onInit() {
    super.onInit();
    _loadAddress();
  }

  @override
  void onClose() {
    cookingNoteController.dispose();
    promoCodeController.dispose();
    super.onClose();
  }

  void _loadAddress() {
    userAddressList.assignAll([
      SavedAddress(
        title: "Home",
        subtitle:
            "Aditya Mehta, 123, Sunrise Apartments, Yagnik Road, Rajkot - 360001",
        icon: AppImages().homeIcon,
      ),
      SavedAddress(
        title: "Other",
        subtitle:
            "201 Jaynath Complex, Gondal Rd, Makkam Chowk, Rajkot, Gujarat 360002",
        icon: AppImages().homeIcon,
      ),
    ]);
  }

  void incrementQuantity(CartItem item) {
    if (Get.isRegistered<OutletScreenController>()) {
      Get.find<OutletScreenController>().incrementQuantity(
        item.categoryName,
        item.id,
      );
    } else {
      int index = cartItems.indexWhere(
        (element) =>
            element.categoryName == item.categoryName && element.id == item.id,
      );
      if (index >= 0) {
        cartItems[index] = cartItems[index].copyWith(
          quantity: cartItems[index].quantity + 1,
        );
        cartItems.refresh();
      }
    }
  }

  void decrementQuantity(CartItem item) {
    if (Get.isRegistered<OutletScreenController>()) {
      Get.find<OutletScreenController>().decrimentQuantity(
        item.categoryName,
        item.id,
      );
    } else {
      int index = cartItems.indexWhere(
        (element) =>
            element.categoryName == item.categoryName && element.id == item.id,
      );
      if (index >= 0) {
        if (cartItems[index].quantity > 1) {
          cartItems[index] = cartItems[index].copyWith(
            quantity: cartItems[index].quantity - 1,
          );
        } else {
          cartItems.removeAt(index);
        }
        cartItems.refresh();
      }
    }
  }

  void applyPromoCode() {
    final code = promoCodeController.text.trim();
    if (code.isEmpty) {
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

    // Example promo discount logic
    if (code.toLowerCase() == "momo50") {
      promoDiscount.value = 50.0;
      Get.snackbar(
        "Success",
        "Promocode applied! You saved ₹50.",
        icon: const Icon(Icons.done, color: Colors.green),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    } else {
      Get.snackbar(
        "Oops!",
        "Invalid promocode. Try 'momo50'.",
        icon: const Icon(Icons.error, color: Colors.red),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    }
  }

  void placeOrder() {
    if (cartItems.isEmpty) {
      Get.snackbar(
        "Oops!",
        "Your cart is empty.",
        icon: const Icon(Icons.error, color: Colors.red),
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
        colorText: Colors.white,
      );
      return;
    }
    Get.offAndToNamed(Routes.homeScreen);
    Future.delayed(const Duration(milliseconds: 300), () {
      Get.snackbar(
        "Success",
        "Order placed successfully! Total: ₹${totalBill.toInt()}",
        icon: const Icon(Icons.done, color: Colors.green),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        backgroundColor: charcoalGray.withValues(alpha: 0.9),
      );
    });
  }

  // Shows the delivery schedule bottom sheet
  void showScheduleBottomSheet(BuildContext context) {
    DeliveryScheduleBottomSheet.show(
      context,
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
      selectedTitle: addressTitle.value,
      onSelect: (address) {
        addressTitle.value = address.title;
        addressSubtitle.value = address.subtitle;
        Get.back();
      },
      onAddNewAddress: () {
        Get.back();
      },
    );
  }

  // Shows the bill details bottom sheet
  void showBillDetailsBottomSheet(BuildContext context) {
    BillDetailsBottomSheet.show(context, this);
  }

  // Shows the payment method bottom sheet
  void showPaymentMethodBottomSheet(BuildContext context) {
    PaymentMethodBottomSheet.show(context, this);
  }

  // Calculated values
  double get subtotal =>
      cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  double get deliveryFee => 0.0;

  double get packagingCharge => 20.0;

  double get gst => 20.0;

  double get totalBill =>
      subtotal + deliveryFee + packagingCharge + gst - promoDiscount.value;
}
