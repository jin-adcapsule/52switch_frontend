import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyinfoFilterPopup extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final Map<String,bool> workTypeSelection;

  final Function(DateTime, DateTime, Map<String,bool>) onApplyFilters;

  const MyinfoFilterPopup({
    required this.startDate,
    required this.endDate,
    required this.workTypeSelection,
    required this.onApplyFilters,
    super.key,
  });

  @override
  State<MyinfoFilterPopup> createState() => _MyinfoFilterPopupState();
}
class _MyinfoFilterPopupState extends State<MyinfoFilterPopup> {
  late DateTime _tempStartDate;
  late DateTime _tempEndDate;
  late Map<String,bool> _tempWorkTypeSelection;

  static const String workTypeAll="전체";
  @override
  void initState() {
    super.initState();
    _tempStartDate = widget.startDate;
    _tempEndDate = widget.endDate;
    // Initialize status selection
    _tempWorkTypeSelection = widget.workTypeSelection;
    }
  @override
  Widget build(BuildContext context) {
    return Wrap(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal:16.0),
            child:Wrap(
              children: [
                const Text("필터",style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text("기간 선택"),
                  subtitle: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDateButton(
                          date: _tempStartDate,
                          onDatePicked: (pickedDate) {_tempStartDate = pickedDate;},
                          lastdate:_tempEndDate,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal:0.0),
                          child: Text("~"), // Align `~` properly
                        ),
                        buildDateButton(
                          date: _tempEndDate,
                          onDatePicked: (pickedDate) {_tempStartDate = pickedDate;},
                          firstdate:_tempStartDate,
                        ),
                      ]
                  )
                ),
                const Divider(),
                ListTile(
                  title: const Text("상태 선택"),
                  subtitle:Wrap(
                    children: _tempWorkTypeSelection.keys.map((status) {
                      return SizedBox(
                          width: 150, // Adjust the width to fit multiple items in one row
                          child: CheckboxListTile(
                            title: Text(status),
                            value: _tempWorkTypeSelection[status],
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
      if (status == workTypeAll) {
        // Update all statuses based on "Toggle All"
        _tempWorkTypeSelection.keys.forEach((key) {
          _tempWorkTypeSelection[key] = value ?? false;
        });
      } else {
        // Update individual status
        _tempWorkTypeSelection[status] = value ?? false;
        // Update "Toggle All" status
        _tempWorkTypeSelection[workTypeAll] = _tempWorkTypeSelection.entries
            .where((entry) => entry.key != workTypeAll)
            .every((entry) => entry.value);
      }
    });
  }
  Widget buildDateButton({
    required DateTime date,
    required void Function(DateTime) onDatePicked,
    DateTime? firstdate,
    DateTime? lastdate,
  }) {
    return TextButton(
      onPressed: () async {
        DateTime _firstdate;
        DateTime _lastdate;
        if (firstdate == null) {_firstdate=DateTime(2000);}else{_firstdate=firstdate;};
        if (lastdate == null) {_lastdate=DateTime.now();}else{_lastdate=lastdate;};
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: _firstdate,
          lastDate: _lastdate,
        );
        if (picked != null) {
          setState(() {
            onDatePicked(picked);
          });
        }
      },
      child: Text(DateFormat('yyyy-MM-dd').format(date)),
    );
  }
  void _applyFilters() async {
    try {
      // Extract selected statuses
      widget.onApplyFilters(_tempStartDate, _tempEndDate, _tempWorkTypeSelection);
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
  final Map<String,bool> workTypeSelection;
  final Function(DateTime, DateTime, Map<String,bool>) onApplyFilters;

  FilterBarDelegate({

    required this.startDate, // Initialize startDate
    required this.endDate, // Initialize endDate
    required this.workTypeSelection,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate the current height for the blue box
    double currentHeight = maxExtent - shrinkOffset;
    currentHeight = currentHeight.clamp(minExtent, maxExtent);

    // Calculate the opacity for the subtitle text
    double opacity = (1 - (shrinkOffset / (maxExtent - minExtent))).clamp(0.0, 1.0);
    double fontsize = (25 - (shrinkOffset / maxExtent) * 10).clamp(20.0, 25.0);
    return Stack(
      fit: StackFit.expand,
      children: [
        /*
        // Persistent filter bar
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: minExtent,
            child: child, // This is the persistent filter bar content
          ),
        ),

         */
        // Blue box
        Container(
          color: const Color.fromRGBO(97, 124, 255, 1.0), // Blue background
        ),
        // Persistent filter bar (refresh and filter buttons)
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align buttons to the right
              children: [
                IconButton(
                  onPressed: () => onApplyFilters(startDate, endDate, workTypeSelection),
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
                          workTypeSelection: workTypeSelection,
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
        ),
        // Filter bar content with moving date and subtitle
        Positioned(
          left: 16.0,
          top: currentHeight * 0.1, // Adjust top positioning for the moving content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date range
              Text(
                "${DateFormat('yy.MM.dd').format(startDate)} ~ ${DateFormat('yy.MM.dd').format(endDate)}",
                style:  TextStyle(
                  color: Colors.white,
                  fontSize: fontsize, // Dynamic font size
                  fontWeight: FontWeight.bold,
                ),
              ),

              // "나의 출퇴근 기록" moves with date
              Opacity(
                opacity: opacity, // Dynamic opacity
                child: const Text(
                  "나의 출퇴근 기록",
                  style: TextStyle(
                    color: Colors.white70, // Slightly dimmed color
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),


      ],
    );
  }

  @override
  double get maxExtent => 150.0;
  @override
  double get minExtent => 60.0;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    // Trigger rebuild if startDate or endDate changes
    return oldDelegate is FilterBarDelegate &&
        (oldDelegate.startDate != startDate ||
            oldDelegate.endDate != endDate);
  }
}
