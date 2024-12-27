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
  NavigationState createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  final String objectId = AppConfig.objectId; // Use from config
  final bool isSupervisor = AppConfig.isSupervisor; // Use from config
    // Cache for storing created screens
  //final Map<String, Widget> _screenCache = {};
  final Map<String, Widget Function()> _screenCache = {};

  void _onItemTapped(String key) {
    if (key == 'supervisor' && !isSupervisor) {
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
      if (tab['key'] == 'supervisor' && !isSupervisor) {
        return false; // Exclude '관리자' if the user is not a supervisor
      }
      return true;
    }).toList();
  }

  Widget _getSelectedScreen(String selectedKey, bool isAttendanceMarked) {
  if (_screenCache.containsKey(selectedKey)) {
    return _screenCache[selectedKey]!(); // Call the cached function to create a fresh screen
  }
  // If the screen isn't cached, create a factory function and store it in the Map
  Widget Function() screenFactory;
  switch (selectedKey) {
    case 'attendance':
      screenFactory = () => createAttendanceScreen();
      break;
    case 'dayoff':
      screenFactory = () => createDayoffScreen(objectId);
      break;
    case 'supervisor':
      screenFactory = () => createSupervisorScreen(objectId);
      break;
    case 'myinfo':
      screenFactory = () => createMyInfoScreen(objectId);
      break;
    case 'more':
      screenFactory = () => MoreScreen();
      break;
    default:
      screenFactory = () => createAttendanceScreen();
      break;
  }
  // Store the factory in the cache
  _screenCache[selectedKey] = screenFactory;

  return screenFactory();
}



//buildformat
  @override
  Widget build(BuildContext context) {
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
