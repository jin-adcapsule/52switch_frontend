import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  final List<String> _availableStatuses = [statusAll, "대기중", "승인", "반려"];

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
        _requestStatusSelection.keys.forEach((key) {
          _requestStatusSelection[key] = value ?? false;
        });
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

      widget.onApplyFilters(_tempStartDate, _tempEndDate, _requestStatusSelection);
      Navigator.pop(context); // Close the modal
      } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('에러 발생: ${e.toString()}')),
      );
    }
  }
}

