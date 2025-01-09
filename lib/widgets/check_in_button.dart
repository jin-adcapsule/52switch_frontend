import 'package:flutter/material.dart';
import '../services/attendance_service.dart';
import '../screens/config_screen.dart';

class CheckInButton extends StatefulWidget {
  final String? employeeOid;
  final String startTime;
  final String endTime;
  final List<String> workTypeList;

  const CheckInButton({
    super.key,
    required this.employeeOid,
    required this.startTime,
    required this.endTime,
    required this.workTypeList,
  });

  @override
  CheckInButtonState createState() => CheckInButtonState();
}

class CheckInButtonState extends State<CheckInButton> {
// To manage loading state
  bool isAttendanceMarked = AppConfig.isAttendanceMarkedNotifier.value ==
      true; //when true is true else(null or false)then false
  late String? employeeOid;
  late bool isTodayOff;
  bool isToggling = false; // To track if toggle is in process
  double sliderHeight = 80.0;
  double sliderWidth = 200.0;
  double buttonSizeRatio = 0.8; // Size of the inside button
  double _dragOffset = 0.0; // Track the drag offset

  @override
  void initState() {
    super.initState();
// Initialize loading as false
    employeeOid = widget.employeeOid;
    isTodayOff = AppConfig.isAttendanceMarkedNotifier.value == null;
    // Fetch attendance status on init only if not dayoff day
    if (!isTodayOff) {
      _getAttendanceStatus();
    }
    // Set the initial drag offset based on attendance status
    _dragOffset = isAttendanceMarked ? (sliderWidth - sliderHeight) : 0.0;
  }

  Future<void> _getAttendanceStatus() async {
    final attendanceService = AttendanceService();
    setState(() {
// Start loading indicator
    });
    try {
      // Send API call to toggle attendance
      final result = await attendanceService.fetchAttendanceStatus(employeeOid);

      // Stop loading once API call succeeds
      setState(() {});
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
      setState(() {});
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  Future<void> _toggleAttendance(bool newValue) async {
    final attendanceService = AttendanceService();
    setState(() {
// Start loading indicator
      isToggling = true; // Mark that toggle is in progress
    });

    try {
      // Send API call to toggle attendance
      final result =
          await attendanceService.markAttendance(employeeOid, newValue);

      // Stop loading once API call succeeds
      setState(() {
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
        isToggling = false; // Mark toggle as done
        isAttendanceMarked = !newValue; // Snap back to original state
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  // Show error snack bar
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: isTodayOff
          ? null // Disable dragging if `isTodayOff` is true
          : (details) {
              // Update the drag offset based on user's drag movement
              setState(() {
                _dragOffset = details.localPosition.dx
                    .clamp(0.0, sliderWidth - sliderHeight);
              });
            },
      onPanEnd: isTodayOff
          ? null // Disable drag-end handling if `isTodayOff` is true
          : (details) async {
              // When the user stops dragging, toggle the attendance based on the final position
              if (_dragOffset >= (sliderWidth - sliderHeight) / 2) {
                await _toggleAttendance(true); // Mark attendance
                // Set the drag offset to right
                setState(() {
                  _dragOffset = (sliderWidth - sliderHeight);
                });
              } else {
                await _toggleAttendance(false); // Unmark attendance
                // Set the drag offset to left
                setState(() {
                  _dragOffset = 0;
                });
              }
            },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: sliderHeight,
        width: sliderWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(sliderHeight),
          color: isTodayOff
              ? Colors.grey.shade300
              : isAttendanceMarked
                  ? Colors.grey.shade100
                  : Colors.grey.shade100,
          gradient: LinearGradient(
            colors: isTodayOff
                ? [
                    Colors.grey.shade500,
                    Colors.grey.shade400,
                  ]
                : isAttendanceMarked
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
                  ? Color.fromRGBO(0, 0, 0, 0.2) // Subtle dark shadow
                  : Color.fromRGBO(0, 0, 0, 0.3), // Subtle dark shadow
              offset: Offset(-3, -3), // Shadow positioned inside
              blurRadius: 6,
            ),
            BoxShadow(
              color: isAttendanceMarked
                  ? Color.fromRGBO(255, 255, 255,
                      0.1) // Subtle dark shadow // Light glow on the inside
                  : Color.fromRGBO(255, 255, 255, 0.4),
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
              top: (sliderHeight - buttonSizeRatio * sliderHeight) /
                  2, // Centers the button vertically
              left:
                  _dragOffset, //isAttendanceMarked ? (sliderWidth - sliderHeight) : 0.0,
              right: (sliderWidth - sliderHeight) -
                  _dragOffset, //isAttendanceMarked ? 0.0 : (sliderWidth -sliderHeight),
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
                  height: buttonSizeRatio *
                      sliderHeight, // Adjust the size of the inside button here
                  width: buttonSizeRatio * sliderHeight,
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
                        color: Color.fromRGBO(255, 255, 255, 0.6),
                        offset: Offset(-4, -4),
                        blurRadius: 6,
                      ),
                      // Darker shadow for depth (bottom-right)
                      BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.2),
                        offset: Offset(4, 4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    isAttendanceMarked ? Icons.circle_outlined : Icons.close,
                    size: buttonSizeRatio *
                        sliderHeight *
                        0.6, // Adjust icon size relative to button size
                    color: isTodayOff
                        ? Colors.grey
                        : isAttendanceMarked
                            ? Colors.green
                            : Colors.red,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
