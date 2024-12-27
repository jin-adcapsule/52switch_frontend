
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'config_screen.dart'; // Import AppConfig
import 'package:firebase_messaging/firebase_messaging.dart'; // Import Firebase Messaging

import '../widgets/check_in_button.dart';
import '../services/global_service.dart';

// Public create function
Widget createAttendanceScreen() {
  return _AttendanceScreen();
}

class _AttendanceScreen extends StatefulWidget {
  //final bool isAttendanceMarked;//Make AttendanceScreen receive the isAttendanceMarked value and update its background color
  const _AttendanceScreen();
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}
class _AttendanceScreenState extends State<_AttendanceScreen> {
  //late bool isAttendanceMarked;
  bool isAttendanceMarked = AppConfig.isAttendanceMarkedNotifier.value;
  
  final String? objectId = AppConfig.objectId; // Example: Use actual employee ID
  //final int? employeeId = AppConfig.employeeId;
  final GlobalService _globalService = GlobalService();
  String workplace = '';
  String workhourOn = '';
  String workhourOff = '';
  String workhourHalf = '';  
  // List to hold notifications
  final List<String> _notifications = [];


  @override
  void initState() {
    super.initState();
    _fetchEmployeeInfo(); // Fetch and set workplace

    // Listen for foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Check if notification body is null, then use message data as fallback
      String notificationMessage = message.notification?.body ?? message.data['message'] ?? 'New notification';

      // Add the notification (or fallback message) to the list
      if (mounted) {
        setState(() {
          _notifications.add(notificationMessage);
        });
      }
      // Show the modal bottom sheet with the updated notifications list
      //_showNotifications();
    });
  }
  String getMaintextHome() => AppConfig.getMaintextHome();
  String getSubtextHome() => AppConfig.getSubtextHome();

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('알림', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              // Display list of notifications dynamically
              Expanded(
                child: ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                      key: Key(_notifications[index]), // Use notification content as key
                      direction: DismissDirection.endToStart, // Slide from right to left
                      onDismissed: (direction) {
                        // Handle the action when the notification is dismissed
                        setState(() {
                          // Optionally remove the notification from the list
                          _notifications.removeAt(index);
                        });

                        // Show a snack bar or any other feedback
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Notification dismissed')),
                        );
                      },
                      background: Container(
                        color: Colors.red, // Background color when swiped
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Icon(Icons.delete, color: Colors.white), // Delete icon
                      ),
                      child: ListTile(
                        title: Text(_notifications[index]),
                        onTap: () {
                          // Optionally handle tap for other actions, like marking as read
                          _markAsRead(index);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  // Example method to mark the notification as read (you can implement the actual logic)
  void _markAsRead(int index) {
    setState(() {
      // Here, you could update the notification state or mark it as read
      _notifications[index] = "${_notifications[index]} (Read)";
    });
  }
  ///get a response for search from service
  Future<void> _fetchEmployeeInfo()  async {
    try {
      final locationData = await _globalService.fetchLocationInfo(AppConfig.objectId);
      setState(() {
        workplace =locationData['workplace']; 
        workhourOn =locationData['workhourOn']; 
        workhourOff =locationData['workhourOff']; 
        workhourHalf =locationData['workhourHalf']; 
      });
      
    } catch (e) {
      setState(() {
        workplace = "Error"; // Display error if fetching fails
      });
      throw Exception('Failed to fetch employeeInfoData: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppConfig.isAttendanceMarkedNotifier,
      builder: (context, isAttendanceMarked, child) {
        return Scaffold(
            backgroundColor: AppConfig.getColor(ColorType.background),//getBackgroundColor(AppConfig.selectedIndexNotifier.value, isAttendanceMarked),
            appBar: AppBar(
              title: Text(AppConfig.getAppbarTitle(AppConfig.selectedKeyNotifier.value), style: TextStyle(color: AppConfig.getColor(ColorType.text))),
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false, // Forces left alignment on both Android and iOS
              actions: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  color: AppConfig.getColor(ColorType.text),
                  onPressed: _showNotifications,
                  ),
                ],
              ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    DateWidget(workplace: workplace),
                    SizedBox(height: 50),
                    const ClockWidget(),
                    Container(
                      margin: EdgeInsets.only(top: 0),
                      width: 100,
                      height: 4,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        AppConfig.getMaintextHome(),
                        style: TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        AppConfig.getSubtextHome(),
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    Center(
                      child: CheckInButton(
                        objectId: objectId,
                      ),
                    ),
                    SizedBox(height: 80),
                  ],
                ),
              ),
            )
          );
      }
    );
  }
}

// Clock Widget for Real-Time Time Display
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: DateFormat('h:mma', 'en_US').format(DateTime.now()).substring(0, DateFormat('h:mma', 'en_US').format(DateTime.now()).length - 2), // Hour and Minute (e.g. 12:45)
                style: TextStyle(
                  fontSize: 36, // Larger font size for time
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: DateFormat('h:mma', 'en_US').format(DateTime.now()).substring(DateFormat('h:mma', 'en_US').format(DateTime.now()).length - 2), // AM/PM
                style: TextStyle(
                  fontSize: 20, // Smaller font size for AM/PM
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: '부터', // AM/PM
                style: TextStyle(
                  fontSize: 20, // Smaller font size for AM/PM
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Date Widget for Real-Time Date Display
class DateWidget extends StatelessWidget {
  final String workplace;
  const DateWidget({super.key, required this.workplace});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        return Text(
          '${DateFormat('yyyy.MM.dd').format(DateTime.now())} | $workplace',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}