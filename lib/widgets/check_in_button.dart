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
  double sliderHeight = 80.0;
  double sliderWidth = 200.0;
  double buttonSizeRatio = 0.8; // Size of the inside button

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
    return GestureDetector(
      onTap: () async {
        if (!isToggling) { // Ensure it's not already toggling
          setState(() => isToggling = true);
          await _toggleAttendance(!isAttendanceMarked); // Call your toggle function
          setState(() => isToggling = false);
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: sliderHeight,
        width: sliderWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sliderHeight),
          color: isAttendanceMarked ? Colors.grey.shade100 : Colors.grey.shade100,
          gradient: LinearGradient(
            colors: isAttendanceMarked
                ? [
                    Colors.green.shade500, // Darker green for depth
                    Colors.green.shade400, // Lighter green for highlight
                  ]
                : [
                    Colors.red.shade500, // Darker red for depth
                    Colors.redAccent.shade200, // Lighter red for highlight
                  ],
            begin: Alignment.topLeft, // Start of the gradient
            end: Alignment.bottomRight, // End of the gradient
          ),
          boxShadow: [
            BoxShadow(
              color: isAttendanceMarked
                  ? Colors.black.withOpacity(0.2) // Subtle dark shadow for depth
                  : Colors.black.withOpacity(0.3),
              offset: Offset(-3, -3), // Shadow positioned inside
              blurRadius: 6,
            ),
            BoxShadow(
              color: isAttendanceMarked
                  ? Colors.white.withOpacity(0.3) // Light glow on the inside
                  : Colors.white.withOpacity(0.4),
              offset: Offset(3, 3), // Inner glow
              blurRadius: 6,
            ),
          ],
        ),
        child: Stack(
          children: <Widget>[
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: (sliderHeight - buttonSizeRatio*sliderHeight) / 2, // Centers the button vertically
              left: isAttendanceMarked ? (sliderWidth - sliderHeight) : 0.0,
              right: isAttendanceMarked ? 0.0 : (sliderWidth -sliderHeight),
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return RotationTransition(
                    turns: animation,
                    child: child,
                  );
                },
                child: Container(
                  key: ValueKey<bool>(isAttendanceMarked),
                  height: buttonSizeRatio*sliderHeight, // Adjust the size of the inside button here
                  width: buttonSizeRatio*sliderHeight,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Inside button color
                    gradient: LinearGradient(
                      colors: isAttendanceMarked
                          ? [Colors.white, Colors.grey.shade500]
                          : [Colors.white, Colors.grey.shade500],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      // Lighter shadow for raised effect (top-left)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.6),
                        offset: Offset(-4, -4),
                        blurRadius: 6,
                      ),
                      // Darker shadow for depth (bottom-right)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(4, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    isAttendanceMarked ? Icons.circle_outlined : Icons.close,
                    size: buttonSizeRatio*sliderHeight * 0.6, // Adjust icon size relative to button size
                    color: isAttendanceMarked ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    /*
    return Stack(
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
          );
*/
  }
}