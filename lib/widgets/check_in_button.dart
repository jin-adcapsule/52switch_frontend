import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget {
  final String? objectId;
  final bool isAttendanceMarked;

  const CheckInButton({super.key, required this.objectId, required this.isAttendanceMarked});

  @override
  CheckInButtonState createState() => CheckInButtonState();
}

class CheckInButtonState extends State<CheckInButton> {
  late bool _isLoading; // To manage loading state
  late bool isAttendanceMarked;
  @override
  void initState() {
    super.initState();
    _isLoading = false; // Initialize loading as false
    isAttendanceMarked = widget.isAttendanceMarked;
    // Fetch attendance status on init
    _getAttendanceStatus();
    
  }
  Future<void> _getAttendanceStatus() async {
    final attendanceService = AttendanceService();
    setState(() {
      _isLoading = true; // Start loading indicator
    });
    try {
      // Send API call to toggle attendance
      await attendanceService.fetchAttendanceStatus(widget.objectId);

      // Stop loading once API call succeeds
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle error and stop loading
      setState(() {
        _isLoading = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  Future<void> _toggleAttendance(bool newValue) async {
    final attendanceService = AttendanceService();
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      // Send API call to toggle attendance
      await attendanceService.markAttendance(widget.objectId, newValue);

      // Stop loading once API call succeeds
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      // Handle error and stop loading
      setState(() {
        _isLoading = false;
      });
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _isLoading
            ? CircularProgressIndicator() // Show loader when loading
            : Transform.scale(
                scale: 3.5,
                child: Switch(
                  value: isAttendanceMarked,
                  onChanged: (val) async {
                    // Disable switch interaction while loading
                    if (!_isLoading) {
                      await _toggleAttendance(val);
                    }
                  },
                  activeColor: Colors.green,
                  inactiveThumbColor: Colors.grey,
                ),
              ),
      ],
    );
  }
}
