import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget {
  final String? employeeOid;

  const CheckInButton({super.key, required this.employeeOid});

  @override
  CheckInButtonState createState() => CheckInButtonState();
}

class CheckInButtonState extends State<CheckInButton> {
  late bool _isLoading; // To manage loading state
  bool isAttendanceMarked = AppConfig.isAttendanceMarkedNotifier.value;
  late String? employeeOid;
  bool isToggling = false; // To track if toggle is in process

  @override
  void initState() {
    super.initState();
    _isLoading = false; // Initialize loading as false
    employeeOid = widget.employeeOid;
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
      final result = await attendanceService.fetchAttendanceStatus(employeeOid);

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
      isToggling = true; // Mark that toggle is in progress
    });

    try {
      // Send API call to toggle attendance
      final result = await attendanceService.markAttendance(employeeOid, newValue);

      // Stop loading once API call succeeds
      setState(() {
        _isLoading = false;
        isToggling = false; // Mark toggle as done
      });
      if (result['mutationSuccess'] == true) {
        setState(() {
          isAttendanceMarked = result['status']; // Update status on success
          // Directly update the ValueNotifier
          AppConfig.isAttendanceMarkedNotifier.value = isAttendanceMarked;
        });
      } else {
        _showErrorSnackBar('Failed to mark attendance.');
         // Snap back to original state
        setState(() {
          isAttendanceMarked = !newValue;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
         isToggling = false; // Mark toggle as done
        isAttendanceMarked = !newValue; // Snap back to original state
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
        AnimatedSwitcher(
          duration: Duration(milliseconds: 600), // Smooth animation duration
          transitionBuilder: (Widget child, Animation<double> animation) {
            final slideAnimation = Tween<Offset>(
              begin: Offset(0.5, 0), // Start slightly offset
              end: Offset.zero, // End at the original position
            ).animate(animation);

            return SlideTransition(
              position: slideAnimation,
              child: child,
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                key: ValueKey<bool>(isAttendanceMarked), // Ensure proper rebuild
                scale: 4,
                child: IgnorePointer( // Disable interaction during loading state
                  ignoring: isToggling || _isLoading, // Ignore pointer when toggling or loading
                  child: Switch(
                    value: isAttendanceMarked,
                    onChanged: (val) async {
                      if (!_isLoading && !isToggling) { // Only toggle if not already loading
                        await _toggleAttendance(val);
                      }
                    },
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.grey,
                  ),
                ),
              ),
              // Overlay the CircularProgressIndicator over the switch
              if (_isLoading && !isToggling)
                Positioned(
                  child: Container(
                    color: Colors.transparent,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}