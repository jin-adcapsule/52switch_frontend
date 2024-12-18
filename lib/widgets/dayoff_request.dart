import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/dayoff_service.dart';
import 'package:flutter/foundation.dart';
import '../screens/config_screen.dart';
import '../services/push_service.dart';
class DayoffRequestScreen extends StatefulWidget {
  final String? objectId;
  final String supervisorName; // Add supervisor name
  final int dayoffRemaining; // Add day off remaining
  final int supervisorId;


  const DayoffRequestScreen({
    Key? key,
    required this.objectId,
    required this.supervisorName,
    required this.dayoffRemaining,
    required this.supervisorId
  }) : super(key: key);

  @override
  _DayoffRequestScreenState createState() => _DayoffRequestScreenState();
}

class _DayoffRequestScreenState extends State<DayoffRequestScreen> {
  List<DateTime> _selectedDates = [];
  final TextEditingController _commentController = TextEditingController();
  final List<String> _dayoffTypes = [ '정기휴가', '오전반차', '오후반차','예비군'];
  String? _selectedDayoffType;

  // Add the focusedDay variable
  DateTime focusedDay = DateTime.now();


  final ScrollController _scrollController = ScrollController();
  bool _showAppBarBorder = false;

  @override
  void initState() {
    super.initState();
    _selectedDayoffType = '정기휴가'; // Set the default value for _selectedDayoffType
    _scrollController.addListener(() {
      if (_scrollController.offset > 0 && !_showAppBarBorder) {
        setState(() {
          _showAppBarBorder = true;
        });
      } else if (_scrollController.offset <= 0 && _showAppBarBorder) {
        setState(() {
          _showAppBarBorder = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴가신청'),
        elevation: 0, // Remove AppBar shadow
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // Back icon
          onPressed: () => Navigator.pop(context), // Go back to the previous screen
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 0.3,
            color: _showAppBarBorder ? Colors.grey : Colors.transparent, // Dynamic border visibility
          ),
        ),

      ),
      body: Column(
        children:[
        Expanded(
        child: SingleChildScrollView(
          controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              locale: 'ko_KR',
              availableGestures: AvailableGestures.all,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                leftChevronVisible: DateTime.now().isAfter(DateTime(DateTime.now().year, DateTime.now().month, 1)),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: DateTime.now().month == focusedDay.month ? Colors.grey : Colors.black,
                ),
                rightChevronIcon: const Icon(Icons.chevron_right),
                titleCentered: true, // Center the title
                titleTextFormatter: (date, locale) => '${date.year}.${date.month.toString().padLeft(2, '0')}', // Custom format
                titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Style the text
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                outsideDaysVisible: false,
                disabledTextStyle: TextStyle(color: Colors.grey),
              ),
              enabledDayPredicate: (day) => day.isAfter(DateTime.now()),
              selectedDayPredicate: (day) => _selectedDates.contains(day),
              onDaySelected: (selectedDay, newFocusedDay) {
                setState(() {
                  if (_selectedDates.contains(selectedDay)) {
                    _selectedDates.remove(selectedDay);
                  } else {
                    _selectedDates.add(selectedDay);
                  }
                  _selectedDates.sort(); // Sort dates after modification
                  focusedDay = newFocusedDay;// Update focusedDay
                });
              },
              focusedDay: focusedDay,// Use the focusedDay variable
              onPageChanged: (focusedDay) {
                setState(() {
                  this.focusedDay = focusedDay; // Update focusedDay dynamically
                });
              },
              firstDay: DateTime(DateTime.now().year, DateTime.now().month, 1), // First day of this month
              lastDay: DateTime(DateTime.now().year + 10, DateTime.now().month, DateTime.now().day), // 10 years later
            ),

            const SizedBox(height: 20),
            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10),
            ///selected dates section

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.calendar_today, color: Colors.black), // Date icon
                const SizedBox(width: 10),
                Expanded(
                  child: _selectedDates.isNotEmpty
                      ? Text(
                    _selectedDates
                        .map((date) =>
                    "${date.month.toString().padLeft(2, '0')}월${date.day.toString().padLeft(2, '0')}일")
                        .join('/'), // Join dates with "/"
                    style: const TextStyle(fontSize: 16),
                  )
                      :  Text(
                    '휴가일을 선택해주세요(남은휴가:${widget.dayoffRemaining}일)',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            if (_selectedDates.isNotEmpty)
              Align(
                alignment: Alignment.bottomRight, // Align to the bottom-right
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0), // Add space between sections
                  child: Text(
                    '${_selectedDates.length}일', // Text showing the count of selected dates
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ),
              ),

            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person, color: Colors.black), // Left-sided person icon
                const SizedBox(width: 10),
                 Expanded(
                  child: Text(
                    '${widget.supervisorName}님에게 신청합니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10),
            //dropdown select for dayoffType
            Row(
              children: [
                const Icon(Icons.luggage, color: Colors.black), // Luggage Icon
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      String? selected = await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) {
                          int initialIndex = _dayoffTypes.indexOf(_selectedDayoffType?? '정기휴가');

                          return StatefulBuilder(
                            builder: (context, setState) {
                              int selectedIndex = initialIndex >= 0 ? initialIndex : 0;

                              return Container(
                                height: MediaQuery.of(context).size.height * 0.3, // Adjustable height
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                ),
                                child: Column(
                                  children: [
                                    // Top bar with Confirm button
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, _dayoffTypes[selectedIndex]);
                                            },
                                            child: const Text(
                                              '확인',
                                              style: TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(thickness: 1, height: 1), // Divider below the top bar

                                    // ListWheelScrollView with minimized empty space
                                    Expanded(
                                      child: Stack(
                                        alignment: Alignment.center, // Aligns the box in the middle
                                        children: [
                                          // Fixed Highlight Box
                                          Positioned(
                                            child: Container(
                                              height: 40, // Match itemExtent
                                              margin: const EdgeInsets.symmetric(horizontal: 16),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[300], // Highlight color
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ),
                                          // ListWheelScrollView
                                          ListWheelScrollView.useDelegate(
                                            controller: FixedExtentScrollController(initialItem: selectedIndex), // Start at selectedIndex
                                            itemExtent: 40, // Height of each item
                                            physics: const FixedExtentScrollPhysics(),
                                            onSelectedItemChanged: (index) {
                                              selectedIndex = index; // Update selected index
                                            },
                                            childDelegate: ListWheelChildBuilderDelegate(
                                              builder: (context, index) {
                                                final bool isSelected = index == selectedIndex;

                                                return Container(
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    _dayoffTypes[index],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: isSelected ? Colors.black : Colors.grey,
                                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                    ),
                                                  ),
                                                );
                                              },
                                              childCount: _dayoffTypes.length,
                                            ),
                                          ),


                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );

                      if (selected != null) {
                        setState(() {
                          _selectedDayoffType = selected; // Update selected value
                        });
                      }
                    },
                    child: Text(
                      _selectedDayoffType ?? '정기휴가', // Default value
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(thickness: 1, color: Colors.grey),
            const SizedBox(height: 10),
            //comment type
            Row(
              children: [
                const Icon(Icons.edit, color: Colors.black), // Left-sided writing icon
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    maxLines: null, // Allow multi-line input
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(left: 7.0), // Adjust horizontal alignment
                      hintText: '위와 같이 휴가를 신청합니다.\n재가하여 주시기 바랍니다.', // Default input displayed as gray
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none, // Remove default border
                    ),
                    style: const TextStyle(color: Colors.black, fontSize: 16), // Text styling
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),


              ],
            ),
          ),
        ),

          // Bottom clickable area
          GestureDetector(
            onTap: () async {
              // Use default comment if the text field is empty
              String requestComment = _commentController.text.trim().isEmpty
                  ? '위와 같이 휴가를 신청합니다. 재가하여 주시기 바랍니다.'
                  : _commentController.text.trim();


              try {
                // Call the request day off logic here
                final dayoffService = DayoffService();
                final dateList = _selectedDates
                    .map((date) =>
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}")
                    .toList();
                // Await the response from the mutation
                final response = await dayoffService.RequestDayoff(
                  widget.objectId!,
                  dateList,
                  _selectedDayoffType!,
                  requestComment,
                  widget.dayoffRemaining,

                );
                // Check the response
                if (listEquals(response, ["Success"])) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('휴가 신청이 완료되었습니다.')),
                  );
                  //send Notification to Supervisor
                  PushService.sendPushToSupervisor(widget.objectId!, "휴가 신청", "${AppConfig.employeeName}  ${_selectedDayoffType} 신청");
                  // Clear the form
                  setState(() {
                    _selectedDates.clear();
                    _selectedDayoffType = null;
                  });
                  _commentController.clear();
                  // Pop the current widget
                  Navigator.pop(context);
                }else{
                  // Show failure message with returned response
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('휴가 신청 실패: ${response.join(", ")}')),
                  );
                }

              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('에러 발생: ${e.toString()}')),
                );
              }
            },
            child: Container(
              width: double.infinity, // Full width
              color: _selectedDates.isEmpty ||
                  _selectedDayoffType == null
                  ? Colors.grey // Gray background if conditions are not met
                  : Colors.black, // Dark gray (or black) background if all conditions are met
              padding: const EdgeInsets.symmetric(vertical: 50), // Add some vertical space
              alignment: Alignment.center, // Center the text
              child: Text(
                '휴가 신청',
                style: const TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold font for better visibility
                  fontSize: 24, // Font size
                ),
              ),
            ),
          ),

      ],
    ),
    );
  }
}
