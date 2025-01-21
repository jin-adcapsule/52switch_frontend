import 'package:flutter/material.dart';
import 'attendance_screen.dart';
import 'dayoff_screen.dart';
import 'supervisor_screen.dart';
import 'myinfo_screen.dart';
import 'more_screen.dart';
import '../utils/constants.dart'; // For app configuration

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  NavigationState createState() => NavigationState();
}

class NavigationState extends State<Navigation> {
  final String employeeOid = Constants.employeeOid; // Use from config
  final bool isSupervisor = Constants.isSupervisor; // Use from config
  final Duration animationDuration = const Duration(milliseconds: 300);
  String? oldSelectedKey; // Variable to hold the previous selectedKey
  // Cache for storing created screens
  //final Map<String, Widget> _screenCache = {};
  //final Map<String, Widget Function()> _screenCache = {};

  void _onItemTapped(String key) {
    if (key == 'supervisor' && !isSupervisor) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('관리자 권한이 없습니다.')), // "No admin privileges"
      );
      return;
    }

    setState(() {
      Constants.selectedKeyNotifier.value = key; // Update the notifier
    });
  }

  List<Map<String, dynamic>> getVisibleTabs() {
    return Constants.tabConfig.where((tab) {
      if (tab['key'] == 'supervisor' && !isSupervisor) {
        return false; // Exclude '관리자' if the user is not a supervisor
      }
      return true;
    }).toList();
  }

  Widget _getSelectedScreen(String selectedKey, bool? isAttendanceMarked) {
    /*if (_screenCache.containsKey(selectedKey)) {
      return _screenCache[
          selectedKey]!(); // Call the cached function to create a fresh screen
    }
    */
    // If the screen isn't cached, create a factory function and store it in the Map
    Widget Function() screenFactory;
    switch (selectedKey) {
      case 'attendance':
        screenFactory = () => createAttendanceScreen(isAttendanceMarked);
        break;
      case 'dayoff':
        screenFactory = () => createDayoffScreen(employeeOid);
        break;
      case 'supervisor':
        screenFactory = () => createSupervisorScreen(employeeOid);
        break;
      case 'myinfo':
        screenFactory = () => createMyInfoScreen(employeeOid);
        break;
      case 'more':
        screenFactory = () => MoreScreen();
        break;
      default:
        screenFactory = () => createAttendanceScreen(isAttendanceMarked);
        break;
    }
    /*
    // Store the factory in the cache
    _screenCache[selectedKey] = screenFactory;
*/
    return screenFactory();
  }

//buildformat
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: Constants.selectedKeyNotifier,
        builder: (context, selectedKey, child) {
          return ValueListenableBuilder<bool?>(
              //can be null(isTodayOff)
              valueListenable: Constants.isAttendanceMarkedNotifier,
              builder: (context, isAttendanceMarked, child) {
                final visibleTabs = getVisibleTabs();
                // Whether the selected key has changed, for example
                final bool isKeyChanged = selectedKey != oldSelectedKey;
                // Update the oldSelectedKey after rebuilding
                if (isKeyChanged) {
                  oldSelectedKey = selectedKey; // Save the new key as old
                }
                return Scaffold(
                  backgroundColor: Constants.getColor(ColorType.background,
                      isAttendanceMarked: isAttendanceMarked),
                  body: AnimatedContainer(
                    duration: isKeyChanged ? Duration.zero : animationDuration,
                    color: Constants.getColor(ColorType.background,
                        isAttendanceMarked:
                            isAttendanceMarked), // Match with AnimatedContainer
                    child: _getSelectedScreen(selectedKey, isAttendanceMarked),
                  ),
                  //bodyscreen load from each screen file

                  bottomNavigationBar: AnimatedContainer(
                      // Only animate when the background color needs to change
                      duration:
                          isKeyChanged ? Duration.zero : animationDuration,
                      color: Constants.getColor(ColorType.background,
                          isAttendanceMarked:
                              isAttendanceMarked), // Match with AnimatedContainer
                      child: Theme(
                        // Wrap BottomNavigationBar with Theme to override splash effects
                        data: Theme.of(context).copyWith(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: BottomNavigationBar(
                          //key: ValueKey(selectedKey),  // Use selectedKey as a key to force rebuild
                          type: BottomNavigationBarType.fixed,
                          backgroundColor: Colors
                              .transparent, // Match with AnimatedContainer
                          elevation: 0,
                          items: visibleTabs.map((tab) {
                            return BottomNavigationBarItem(
                              icon: Icon(tab['icon']),
                              label: tab['label'],
                            );
                          }).toList(),
                          currentIndex: visibleTabs
                              .indexWhere((tab) => tab['key'] == selectedKey),
                          onTap: (index) =>
                              _onItemTapped(visibleTabs[index]['key']),
                          selectedItemColor:
                              Constants.getColor(ColorType.selectedItem),
                          unselectedItemColor:
                              Constants.getColor(ColorType.unselectedItem),
                          showUnselectedLabels: true,
                        ),
                      )),
                );
              });
        });
  }
}
