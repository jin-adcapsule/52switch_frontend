import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class DayoffHistoryFilter extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String,bool> requestStatusSelection;
  final Function(DateTime, DateTime, Map<String,bool>) onApplyFilters;

  const DayoffHistoryFilter({
    required this.startDate,
    required this.endDate,
    required this.requestStatusSelection,
    required this.onApplyFilters,
    super.key,
  });

  void _showFilterPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DayoffFilterPopup(
          startDate: startDate,
          endDate: endDate,
          requestStatusSelection: requestStatusSelection,
          onApplyFilters: onApplyFilters,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showFilterPopup(context),
              child: Text(
                "${DateFormat('yy.MM.dd').format(startDate)}~${DateFormat('yy.MM.dd').format(endDate)}",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => onApplyFilters(startDate, endDate, requestStatusSelection),
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
          IconButton(
            onPressed: () => _showFilterPopup(context),
            icon: const Icon(Icons.filter_list, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
class DayoffFilterPopup extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String,bool> requestStatusSelection;
  final Function(DateTime, DateTime, Map<String,bool>) onApplyFilters;

  const DayoffFilterPopup({
    required this.startDate,
    required this.endDate,
    required this.requestStatusSelection,
    required this.onApplyFilters,
    super.key,
  });

  @override
  State<DayoffFilterPopup> createState() => _DayoffFilterPopupState();
}
class _DayoffFilterPopupState extends State<DayoffFilterPopup> {
  late DateTime _tempStartDate;
  late DateTime _tempEndDate;
  late Map<String,bool> _requestStatusSelection;

  static const String statusAll="전체";

  @override
  void initState() {
    super.initState();
    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    // Initialize status selection
    _requestStatusSelection = widget.requestStatusSelection;

  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal:16.0),
          child:Wrap(
            children: [
              const Text("필터", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 30),
              ListTile(
                title: const Text("기간 선택"),
                subtitle: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildDateButton(
                        context: context,
                        date: _tempStartDate,
                        onDatePicked: (pickedDate) {_tempStartDate = pickedDate;},
                        lastdate:_tempEndDate,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal:0.0),
                        child: Text("~"), // Align `~` properly
                      ),
                      buildDateButton(
                        context: context,
                        date: _tempEndDate,
                        onDatePicked: (pickedDate) {_tempStartDate = pickedDate;},
                        firstdate:_tempStartDate,
                      ),
                    ]
                )
              ),
              const Divider(),
              // Checkbox List for Status
              ListTile(
                title: const Text("상태 선택"),
                subtitle:Wrap(
                  children: _requestStatusSelection.keys.map((status) {
                    return SizedBox(
                        width: 150, // Adjust the width to fit multiple items in one row
                          child: CheckboxListTile(
                            title: Text(status),
                            value: _requestStatusSelection[status],
                            onChanged: (bool? value) => selectStatuses( value,status),
                            controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                            dense: true, // Compact layout
                            contentPadding: EdgeInsets.zero, // Remove padding around checkbox
                          )
                    );
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
            color: Colors.black, // Dark gray (or black) background if all conditions are met
            padding: const EdgeInsets.symmetric(vertical: 50), // Add some vertical space
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
      ]
    );
  }
  void selectStatuses(bool? value, String status) {
    setState(() {
      if (status == statusAll) {
        // Update all statuses based on "Toggle All"
        for (var key in _requestStatusSelection.keys) {
          _requestStatusSelection[key] = value ?? false;
        }
      } else {
        // Update individual status
        _requestStatusSelection[status] = value ?? false;
        // Update "Toggle All" status
        _requestStatusSelection[statusAll] = _requestStatusSelection.entries
            .where((entry) => entry.key != statusAll)
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
      int startYear = DateTime.now().year-3;
      int endYear = DateTime.now().year;
      // Get the initial month and year from the provided date
      int initialDayIndex = date.day - 1; // Convert to 0-based index
      int initialMonthIndex = date.month - 1; // Convert to 0-based index
      int initialYearIndex = date.year - startYear; // Subtract starting year (2020) to get the index
      // Initialize controllers with initial item
      FixedExtentScrollController dayController = FixedExtentScrollController(initialItem: initialDayIndex);
      FixedExtentScrollController  monthController = FixedExtentScrollController(initialItem: initialMonthIndex);
      FixedExtentScrollController  yearController = FixedExtentScrollController(initialItem: initialYearIndex);
      // Create the picker data
      List<String> years = List.generate(endYear - startYear + 1, (index) => (startYear + index).toString());
      List<String> months = List.generate(12, (index) => (index + 1).toString().padLeft(2, '0'));
      List<String> days = List.generate(31, (index) => (index + 1).toString().padLeft(2, '0'));

      showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: Padding(
              padding: const EdgeInsets.only(top: 10, right: 10),
              child: CupertinoActionSheetAction(
                onPressed: () {
                  // Map selected index to values
                  int selectedYear = startYear + yearController.selectedItem; // Assuming starting year is 2020
                  int selectedMonth = monthController.selectedItem + 1; // Convert 0-based index to 1-based month
                  int selectedDay = dayController.selectedItem + 1; // Convert 0-based index to 1-based day

                  // Create a DateTime object with the selected date
                  DateTime selectedDate = DateTime(selectedYear, selectedMonth, selectedDay);
                  // Check if selected date is within the valid range
                  if ((firstdate != null && selectedDate.isBefore(firstdate)) ||
                      (lastdate != null && selectedDate.isAfter(lastdate))) {
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
                  child:Text(
                      '확인',
                      style: TextStyle(color: CupertinoColors.activeBlue),
                  ),
                )
              ),
            ),
            message: Column(
              children: [
                Divider(), // Thin divider
                SizedBox(
                  height: 200, // Height of the picker
                  child: Stack(
                    children: [
                      // Unified overlay behind all pickers
                      Center(
                        child: Container(
                          height: 32.0, // Match itemExtent
                          margin: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding around the pickers
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2), // Light gray with transparency
                            borderRadius: BorderRadius.circular(10), // Rounded corners
                          ),
                        ),
                      ),
                      // Pickers Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,  // Shrink the row's width to fit its children
                        children: [
                          
                          // Year Picker
                          Expanded(
                            child:CupertinoPicker(
                              selectionOverlay: null,
                              scrollController: yearController,
                              itemExtent: 32.0,
                              onSelectedItemChanged: (int yearIndex) {
                                // Handle year selection
                              },
                              children: List.generate(years.length, (index) {
                                return Center(child: Text('${years[index]}년'));
                              }),
                            )
                          ),
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
                            )
                          ),
                          // Day Picker
                          Expanded(
                            child:CupertinoPicker(
                              selectionOverlay: null,
                              itemExtent: 32.0,
                              scrollController: dayController,
                              onSelectedItemChanged: (int dayIndex) {
                                // Handle day selection
                              },
                              children: List.generate(days.length, (index) {
                                return Center(child: Text('${days[index]}일'));
                              }),
                            )
                          ),
                        ],
                      ),
                    ]
                  )
                )
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

      widget.onApplyFilters(_tempStartDate, _tempEndDate, _requestStatusSelection);
      Navigator.pop(context); // Close the modal
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: ${e.toString()}')),
      );
    }
  }
}

