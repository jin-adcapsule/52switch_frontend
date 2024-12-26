import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget {
  final String? objectId;

  const CheckInButton({super.key, required this.objectId});

  @override
  CheckInButtonState createState() => CheckInButtonState();
}

class CheckInButtonState extends State<CheckInButton> {
  late bool _isLoading; // To manage loading state
  bool isAttendanceMarked = AppConfig.isAttendanceMarkedNotifier.value;
  late String? objectId;
  @override
  void initState() {
    super.initState();
    _isLoading = false; // Initialize loading as false
    isAttendanceMarked = isAttendanceMarked;
    objectId = widget.objectId;
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
      final result = await attendanceService.fetchAttendanceStatus(objectId);

      // Stop loading once API call succeeds
      setState(() {
        _isLoading = false;
      });
      if (result['querySuccess'] == true) {
        setState(() {
          isAttendanceMarked = result['status']; // Update the attendance status
          // Directly update the ValueNotifier
          AppConfig.isAttendanceMarkedNotifier.value = isAttendanceMarked;
        });
      } else {
        _showErrorSnackBar('Failed to fetch attendance status.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }
  Future<void> _toggleAttendance(bool newValue) async {
    final attendanceService = AttendanceService();
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      // Send API call to toggle attendance
      final result = await attendanceService.markAttendance(objectId, newValue);

      // Stop loading once API call succeeds
      setState(() {
        _isLoading = false;
      });
      if (result['mutationSuccess'] == true) {
        setState(() {
          isAttendanceMarked = result['status']; // Update status on success
          // Directly update the ValueNotifier
          AppConfig.isAttendanceMarkedNotifier.value = isAttendanceMarked;
        });
      } else {
        _showErrorSnackBar('Failed to mark attendance.');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }
  // Show error snack bar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
