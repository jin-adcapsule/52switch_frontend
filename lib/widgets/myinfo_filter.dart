import 'package:app52switch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class MyinfoFilterPopup extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String, bool> orDayoffHolidaySelection;
  final Map<String, bool> attendanceStatusSelection;

  final Function(DateTime, DateTime, Map<String, bool>, Map<String, bool>)
      onApplyFilters;

  const MyinfoFilterPopup({
    required this.startDate,
    required this.endDate,
    required this.orDayoffHolidaySelection,
    required this.attendanceStatusSelection,
    required this.onApplyFilters,
    super.key,
  });

  @override
  State<MyinfoFilterPopup> createState() => _MyinfoFilterPopupState();
}

class _MyinfoFilterPopupState extends State<MyinfoFilterPopup> {
  late DateTime _tempStartDate;
  late DateTime _tempEndDate;
  late Map<String, bool> _tempOrDayoffHolidaySelection;
  late Map<String, bool> _tempAttendanceStatusSelection;

  static const String workTypeAll = "전체";
  @override
  void initState() {
    super.initState();

    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    // Initialize status selection
    _tempOrDayoffHolidaySelection = widget.orDayoffHolidaySelection;
    _tempAttendanceStatusSelection = widget.attendanceStatusSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(children: [
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Wrap(
          children: [
            const Text(
              "필터",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
                title: const Text("기간 선택"),
                subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDateButton(
                        context: context,
                        date: _tempStartDate,
                        onDatePicked: (pickedDate) {
                          _tempStartDate = pickedDate;
                        },
                        lastdate: _tempEndDate,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 0.0),
                        child: Text("~"), // Align `~` properly
                      ),
                      buildDateButton(
                        context: context,
                        date: _tempEndDate,
                        onDatePicked: (pickedDate) {
                          _tempEndDate = pickedDate;
                        },
                        firstdate: _tempStartDate,
                      ),
                    ])),
            const Divider(),
            ListTile(
              title: const Text("근무 상태 선택"),
              subtitle: Wrap(
                children: _tempOrDayoffHolidaySelection.keys.map((status) {
                  return SizedBox(
                      width:
                          150, // Adjust the width to fit multiple items in one row
                      child: CheckboxListTile(
                        title: Text(status),
                        value: _tempOrDayoffHolidaySelection[status],
                        onChanged: (bool? value) => selectStatuses(
                            value, status, _tempOrDayoffHolidaySelection),
                        controlAffinity: ListTileControlAffinity
                            .leading, // Checkbox on the left
                        dense: true, // Compact layout
                        contentPadding:
                            EdgeInsets.zero, // Remove padding around checkbox
                      ));
                }).toList(),
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text("근태 상태 선택"),
              subtitle: Wrap(
                children: _tempAttendanceStatusSelection.keys.map((status) {
                  return SizedBox(
                      width:
                          150, // Adjust the width to fit multiple items in one row
                      child: CheckboxListTile(
                        title: Text(status),
                        value: _tempAttendanceStatusSelection[status],
                        onChanged: (bool? value) => selectStatuses(
                            value, status, _tempAttendanceStatusSelection),
                        controlAffinity: ListTileControlAffinity
                            .leading, // Checkbox on the left
                        dense: true, // Compact layout
                        contentPadding:
                            EdgeInsets.zero, // Remove padding around checkbox
                      ));
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      // Bottom clickable area
      GestureDetector(
        onTap: _applyFilters,
        child: Container(
          width: double.infinity, // Full width
          color: Colors
              .black, // Dark gray (or black) background if all conditions are met
          padding: const EdgeInsets.symmetric(
              vertical: 30), // Add some vertical space
          alignment: Alignment.center, // Center the text
          child: Text(
            '적용하기',
            style: const TextStyle(
              color: Colors.white, // White text
              fontWeight: FontWeight.bold, // Bold font for better visibility
              fontSize: 24, // Font size
            ),
          ),
        ),
      ),
    ]);
  }

  void selectStatuses(bool? value, String key, Map<String, bool> selection) {
    setState(() {
      if (key == workTypeAll) {
        // Update all statuses based on "Toggle All"
        for (var key in selection.keys) {
          selection[key] = value ?? false;
        }
      } else {
        // Update individual status
        selection[key] = value ?? false;
        // Update "Toggle All" status
        selection[workTypeAll] = selection.entries
            .where((entry) => entry.key != workTypeAll)
            .every((entry) => entry.value);
      }
    });
  }

  Widget buildDateButton({
    required BuildContext context, // Pass context explicitly as a parameter
    required DateTime date,
    required void Function(DateTime) onDatePicked,
    DateTime? firstdate,
    DateTime? lastdate,
  }) {
    return TextButton(
      onPressed: () {
        int startYear = DateTime.now().year - 3;
        int endYear = DateTime.now().year;
        // Get the initial month and year from the provided date
        int initialDayIndex = date.day - 1; // Convert to 0-based index
        int initialMonthIndex = date.month - 1; // Convert to 0-based index
        int initialYearIndex = date.year -
            startYear; // Subtract starting year (2020) to get the index
        // Initialize controllers with initial item
        FixedExtentScrollController dayController =
            FixedExtentScrollController(initialItem: initialDayIndex);
        FixedExtentScrollController monthController =
            FixedExtentScrollController(initialItem: initialMonthIndex);
        FixedExtentScrollController yearController =
            FixedExtentScrollController(initialItem: initialYearIndex);
        // Create the picker data
        List<String> years = List.generate(
            endYear - startYear + 1, (index) => (startYear + index).toString());
        List<String> months = List.generate(
            12, (index) => (index + 1).toString().padLeft(2, '0'));
        List<String> days = List.generate(
            31, (index) => (index + 1).toString().padLeft(2, '0'));

        showCupertinoModalPopup(
          context: context,
          builder: (context) {
            return CupertinoActionSheet(
              title: Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: CupertinoActionSheetAction(
                    onPressed: () {
                      // Map selected index to values
                      int selectedYear = startYear +
                          yearController
                              .selectedItem; // Assuming starting year is 2020
                      int selectedMonth = monthController.selectedItem +
                          1; // Convert 0-based index to 1-based month
                      int selectedDay = dayController.selectedItem +
                          1; // Convert 0-based index to 1-based day

                      // Create a DateTime object with the selected date
                      DateTime selectedDate =
                          DateTime(selectedYear, selectedMonth, selectedDay);
                      // Check if selected date is within the valid range
                      if ((firstdate != null &&
                              selectedDate.isBefore(firstdate)) ||
                          (lastdate != null &&
                              selectedDate.isAfter(lastdate))) {
                        // If the date is invalid, show an alert or handle the error
                        showDialog(
                          context: context,
                          builder: (context) => CupertinoAlertDialog(
                            content: Text('날짜 선택 오류'),
                            actions: [
                              CupertinoDialogAction(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Pass the selected date back to the onDatePicked callback
                        setState(() {
                          onDatePicked(selectedDate);
                        });

                        // Close the modal
                        Navigator.pop(context);
                      }
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        '확인',
                        style: TextStyle(color: CupertinoColors.activeBlue),
                      ),
                    )),
              ),
              message: Column(
                children: [
                  Divider(), // Thin divider
                  SizedBox(
                      height: 200, // Height of the picker
                      child: Stack(children: [
                        // Unified overlay behind all pickers
                        Center(
                          child: Container(
                            height: 32.0, // Match itemExtent
                            margin: const EdgeInsets.symmetric(
                                horizontal:
                                    16.0), // Add padding around the pickers
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(
                                  0.2), // Light gray with transparency
                              borderRadius:
                                  BorderRadius.circular(10), // Rounded corners
                            ),
                          ),
                        ),
                        // Pickers Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize
                              .min, // Shrink the row's width to fit its children
                          children: [
                            // Year Picker
                            Expanded(
                                child: CupertinoPicker(
                              selectionOverlay: null,
                              scrollController: yearController,
                              itemExtent: 32.0,
                              onSelectedItemChanged: (int yearIndex) {
                                // Handle year selection
                              },
                              children: List.generate(years.length, (index) {
                                return Center(child: Text('${years[index]}년'));
                              }),
                            )),
                            // Month Picker
                            Expanded(
                                child: CupertinoPicker(
                              selectionOverlay: null,
                              scrollController: monthController,
                              itemExtent: 32.0,
                              onSelectedItemChanged: (int monthIndex) {
                                // Handle month selection
                              },
                              children: List.generate(months.length, (index) {
                                return Center(child: Text('${months[index]}월'));
                              }),
                            )),
                            // Day Picker
                            Expanded(
                                child: CupertinoPicker(
                              selectionOverlay: null,
                              itemExtent: 32.0,
                              scrollController: dayController,
                              onSelectedItemChanged: (int dayIndex) {
                                // Handle day selection
                              },
                              children: List.generate(days.length, (index) {
                                return Center(child: Text('${days[index]}일'));
                              }),
                            )),
                          ],
                        ),
                      ]))
                ],
              ),
            );
          },
        );
      },
      child: Text(DateFormat('yyyy-MM-dd').format(date)),
    );
  }

  void _applyFilters() async {
    try {
      // Extract selected statuses
      widget.onApplyFilters(_tempStartDate, _tempEndDate,
          _tempOrDayoffHolidaySelection, _tempAttendanceStatusSelection);
      Navigator.pop(context); // Close the modal
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: ${e.toString()}')),
      );
    }
  }
}

class FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final DateTime startDate; // Add startDate field
  final DateTime endDate; // Add endDate field
  final Map<String, bool> orDayoffHolidaySelection;
  final Map<String, bool> attendanceStatusSelection;
  //final Map<String, bool> workTypeSelection;
  final Function(DateTime, DateTime, Map<String, bool>, Map<String, bool>)
      onApplyFilters;

  FilterBarDelegate({
    required this.startDate, // Initialize startDate
    required this.endDate, // Initialize endDate
    required this.orDayoffHolidaySelection,
    required this.attendanceStatusSelection,
    required this.onApplyFilters,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate the current height for the filter bar based on vertical position
    //double screenHeight = MediaQuery.of(context).size.height;

    // Calculate the current height for the blue box
    //double currentHeight = maxExtent - shrinkOffset;
    //currentHeight = currentHeight.clamp(minExtent, maxExtent);

    // Calculate the opacity for the subtitle text
    double opacity =
        (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(0.0, 1.0);
    double fontsize = (25 - (shrinkOffset / maxExtent) * 10).clamp(20.0, 25.0);

    double statusBarHeight = MediaQuery.of(context).padding.top;
    double maxMovement = 20.0; // Maximum distance the date range can move up
    //double targetTop = 12; // Final position after pinning
    //double dynamicBottom = targetBottom+maxMovement - shrinkOffset;
    //double minTopText=10;
    double minTopIcon = 10;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Blue box
        Container(
          color: const Color.fromRGBO(97, 124, 255, 1.0), // Blue background
        ),
        // Filter bar content with date range and subtitle
        Positioned(
          left: 16.0,
          top: calculateDynamicPosition(shrinkOffset, statusBarHeight),
          child: buildFilterBarContent(
              shrinkOffset, fontsize, opacity, startDate, endDate),
        ),
        // Filter bar buttons
        Positioned(
          top: (-maxMovement + shrinkOffset)
              .clamp(minTopIcon, statusBarHeight + minTopIcon),
          right: 16.0, // Align buttons to the right side
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => onApplyFilters(startDate, endDate,
                    orDayoffHolidaySelection, attendanceStatusSelection),
                icon: const Icon(Icons.refresh, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return MyinfoFilterPopup(
                        startDate: startDate,
                        endDate: endDate,
                        orDayoffHolidaySelection: orDayoffHolidaySelection,
                        attendanceStatusSelection: attendanceStatusSelection,
                        onApplyFilters: onApplyFilters,
                      );
                    },
                  );
                },
                icon: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

// Function to build the filter bar content (Date range and subtitle)
  Widget buildFilterBarContent(
    double shrinkOffset,
    double fontsize,
    double opacity,
    DateTime startDate,
    DateTime endDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date range
        Text(
          "${DateFormat('yy.MM.dd').format(startDate)} ~ ${DateFormat('yy.MM.dd').format(endDate)}",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontsize, // Dynamic font size
            fontWeight: FontWeight.bold,
          ),
        ),
        // "나의 출퇴근 기록"
        Opacity(
          opacity: opacity, // Dynamic opacity
          child: const Text(
            "나의 출퇴근 기록",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  // Function to calculate dynamic position based on shrinkOffset
  double calculateDynamicPosition(double shrinkOffset, double statusBarHeight) {
    double maxMovement = 1.0; // Maximum distance the date range can move up
    double minTopText = 20.0; // Minimum position for text
    // Adjust the top position dynamically based on shrinkOffset
    return (-maxMovement + shrinkOffset)
        .clamp(minTopText, statusBarHeight + minTopText);
  }

  // Function to calculate dynamic font size based on shrinkOffset
  double calculateFontSize(double shrinkOffset) {
    // Calculate font size dynamically, clamp it between 20.0 and 25.0
    return (25 - (shrinkOffset / 300) * 10).clamp(20.0, 25.0);
  }

  // Function to calculate dynamic opacity based on shrinkOffset
  double calculateOpacity(double shrinkOffset) {
    // Calculate opacity based on shrinkOffset, clamp it between 0.0 and 1.0
    return (1 - (shrinkOffset / 300)).clamp(0.0, 1.0);
  }

  @override
  double get maxExtent =>
      180.0; // Return a static value for maxExtent, but it can still be used in calculations inside build

  @override
  double get minExtent => 90.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Trigger rebuild if startDate or endDate changes
    return oldDelegate is FilterBarDelegate &&
        (oldDelegate.startDate != startDate || oldDelegate.endDate != endDate);
  }
}
