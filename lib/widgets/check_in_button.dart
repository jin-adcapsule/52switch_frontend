import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget {
  final String? objectId;

  const CheckInButton({super.key, required this.objectId});

  @override
  _CheckInButtonState createState() => _CheckInButtonState();
}

class _CheckInButtonState extends State<CheckInButton> {
  late bool _isLoading; // To manage loading state

  @override
  void initState() {
    super.initState();
    _isLoading = false; // Initialize loading as false
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
      /*
      // Optionally, show success message (if needed)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue
              ? 'Attendance marked successfully'
              : 'Attendance undone'),
        ),
      );

       */
    } catch (e) {
      // Handle error and stop loading
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppConfig.isAttendanceMarkedNotifier,
      builder: (context, isAttendanceMarked, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading
                ? CircularProgressIndicator() // Show loader when loading
                : Transform.scale(
              scale: 3.5,
              child: Switch(
                value: isAttendanceMarked, // Listen to the subscription value
                onChanged: (val) async {
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
      },
    );
  }
}
