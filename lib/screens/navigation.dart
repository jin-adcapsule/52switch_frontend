import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'dayoff_screen.dart';
import 'supervisor_screen.dart';
import 'myinfo_screen.dart';
import 'more_screen.dart';
import 'config_screen.dart'; // For app configuration

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  final String objectId = AppConfig.objectId; // Use from config
  final bool is_supervisor = AppConfig.is_supervisor; // Use from config
  void _onItemTapped(String key) {
    if (key == 'supervisor' && !AppConfig.is_supervisor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관리자 권한이 없습니다.')), // "No admin privileges"
      );
      return;
    }

    setState(() {
      AppConfig.selectedKeyNotifier.value = key; // Update the notifier
    });
  }
  List<Map<String, dynamic>> getVisibleTabs() {
    return AppConfig.tabConfig.where((tab) {
      if (tab['key'] == 'supervisor' && !AppConfig.is_supervisor) {
        return false; // Exclude '관리자' if the user is not a supervisor
      }
      return true;
    }).toList();
  }


  Widget _getSelectedScreen(String selectedKey,bool isAttendanceMarked) {
    switch (selectedKey) {
      case 'attendance':
        return AttendanceScreen(isAttendanceMarked: isAttendanceMarked);
      case 'dayoff':
        return DayoffScreen(objectId: objectId);
      case 'supervisor':
        return SupervisorScreen(objectId: objectId) ;
      case 'myinfo':
        return MyInfoScreen(objectId: objectId);
      case 'more':
        return MoreScreen();
      default:
        return AttendanceScreen(isAttendanceMarked: isAttendanceMarked);
    }
  }


//buildformat
  @override
  Widget build(BuildContext context) {
    print('Building Navigation widget');
    return ValueListenableBuilder<String>(
        valueListenable: AppConfig.selectedKeyNotifier,
        builder: (context, selectedKey, child) {
        return ValueListenableBuilder<bool>(
          valueListenable: AppConfig.isAttendanceMarkedNotifier,
          builder: (context, isAttendanceMarked, child) {
            final visibleTabs = getVisibleTabs();
            return Scaffold(
              body: _getSelectedScreen(selectedKey,isAttendanceMarked),//bodyscreen load from each screen file

              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: AppConfig.getColor(ColorType.background),
                elevation: 0,
                items: visibleTabs.map((tab) {
                  return BottomNavigationBarItem(
                    icon: Icon(tab['icon']),
                    label: tab['label'],
                  );
                }).toList(),
                currentIndex: visibleTabs.indexWhere((tab) => tab['key'] == selectedKey),
                onTap: (index) => _onItemTapped(visibleTabs[index]['key']),
                selectedItemColor: AppConfig.getColor(ColorType.selectedItem),
                unselectedItemColor: AppConfig.getColor(ColorType.unselectedItem),
                showUnselectedLabels: true,
              ),
            );
          }
        );
      }
    );
  }
}
