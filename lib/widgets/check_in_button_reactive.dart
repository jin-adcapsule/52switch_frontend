
import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget  {
  final bool isAttendanceMarked;
  final String? objectId;

  const CheckInButton({super.key, required this.isAttendanceMarked, required this.objectId});

  @override
  CheckInButtonState createState() => CheckInButtonState();
}

class CheckInButtonState extends State<CheckInButton> {
  late bool isAttendanceMarked;
  late bool _isLoading;
  //late Stream<QueryResult> subscriptionStream;

  @override
  void initState() {
    super.initState();
    isAttendanceMarked = widget.isAttendanceMarked;
    _isLoading = false;
  }
  Future<void> _toggleAttendance(bool newValue) async {
    final attendanceService = AttendanceService();
    setState(() {
      _isLoading = true; // Start loading indicator
    });

    try {
      // Call the service to update attendance
      await attendanceService.markAttendance(widget.objectId, newValue);
      // Update state only if the call succeeds
      setState(() {
        isAttendanceMarked = newValue;
        AppConfig.isAttendanceMarkedNotifier.value = newValue; // Update global state
        _isLoading = false; // Stop loading indicator
      });
    /*
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newValue ? 'Attendance marked successfully' : 'Attendance undone')),

      );*/

    } catch (e) {
      // Show error message and revert switch state
      setState(() {
        _isLoading = false; // Stop loading indicator
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
  @override
  void dispose() {
    super.dispose();
  }
    /*return Transform.scale(
      scale: 3.5,
      child: Switch(
        value: isAttendanceMarked,
        onChanged: (val) async {
          // Temporarily disable switch interaction until the backend call is complete
          setState(() {
            isAttendanceMarked = !val; // Revert UI state temporarily
          });

          await _toggleAttendance(val);
        },
        activeColor: Colors.green,
        inactiveThumbColor: Colors.grey,
      ),
    );
  }

     */
}

