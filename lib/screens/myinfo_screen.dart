//pass the employeeId from the HomeScreen when navigating.
import 'package:flutter/material.dart';
import '../services/myinfo_service.dart'; // Import the service file
import '../models/employee.dart'; // Import the Employee model
import '../models/attendance.dart'; // Import Attendance model
import '../widgets/show_myinfo_widget.dart';
import 'config_screen.dart'; // Import AppConfig

import '../widgets/myinfo_filter.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../services/global_service.dart'; // Import the service file

class MyInfoScreen extends StatefulWidget {
  final String? objectId;// Accept objectId as a parameter

  const MyInfoScreen({super.key, required this.objectId});

  @override
  _MyInfoScreenState createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  late Future<Employee?> _employeeFuture;
  late Future<List<Attendance>> _attendanceHistoryFuture;

  //scroll for edgebox
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  // Filters
  static const String statusAll="전체";
  static const List<String> statusList=["정상근무","휴가","지각","결근","주말근무","오전반차","오후반차","경조휴가","휴직"];
  // Create a Map<String, bool> with all keys having a value of true
  static Map<String, bool> default_workTypeSelection = {
    for (String status in [statusAll, ...statusList]) status: true,
  };
  Map<String,bool> _workTypeSelection = Map<String, bool>.from(default_workTypeSelection); // make mutable Map
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();

  List<String> get workTypeList {
    return [
      for (var entry in _workTypeSelection.entries)
        if (entry.value && statusList.contains(entry.key))
          entry.key
    ];
  }
  //overlapping box
  int lateCount = 0; // initial count for overlapping box
  int absentCount = 0; // initial count for overlapping box
  int dayoffCount = 0; // initial count for overlapping box
  bool isDataFetched = false; // Flag to control box visibility


  ///initial setup
  @override
  void initState() {
    super.initState();
    // Ensure objectId is non-null before calling the service
    print("objectid");
    print(widget.objectId);
    if (widget.objectId != null) {
      _employeeFuture = GlobalService().fetchEmployeeInfo(widget.objectId!);
      _attendanceHistoryFuture = _fetchAttendanceHistory();
    } else {
      // Handle the case where objectId is null
      _employeeFuture = Future.value(null);
      _attendanceHistoryFuture = Future.value([]);
    }
// Attach listener to scroll controller
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset; // Update _scrollOffset
      });
    });
  }



  void _showMyinfo(BuildContext context,
      Future<Employee?> employeeFuture) async {
      final employee = await employeeFuture;

      if (employee != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return ShowMyInfoWidget(employee: employee);
          },
        );
      } else {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return Container(
              height: 100,
              padding: const EdgeInsets.all(16.0),
              child: const Center(
                child: Text('Employee data not available or not found.'),
              ),
            );
         },
        );
      }
  }

  ///get a response for search from service
  Future<List<Attendance>> _fetchAttendanceHistory() async {
    final attendanceData = await MyInfoService().fetchAttendanceHistory(
      //employeeId: AppConfig.employeeId!,
      objectId: AppConfig.objectId!,
      startDate: DateFormat('yyyy-MM-dd').format(_startDate),
      endDate: DateFormat('yyyy-MM-dd').format(_endDate),
      workTypeList: workTypeList,
    );

    // Update state variables
    setState(() {
      isDataFetched = true; // Data has been fetched, show the box
      lateCount = attendanceData
          .where((attendance) => attendance.checkInStatus?.trim() == "지각")
          .length;
      absentCount = attendanceData
          .where((attendance) => attendance.checkInStatus?.trim() == "결근")
          .length;
      dayoffCount = attendanceData
          .where((attendance) => attendance.workTypeList?.any((workType) =>
          workType.trim() == '오전반차' ||
              workType.trim() == '오후반차' ||
              workType.trim() == '정기휴가'
          ) ?? false) // null check if workTypeList is null
              .length;
    });
    return attendanceData;

  }

  ///when filter changed then get a response again
  void _applyFilters(DateTime startDate, DateTime endDate, Map<String,bool> workTypeSelection) {
    setState(() {
      _startDate = startDate;
      _endDate = endDate;
      _workTypeSelection = workTypeSelection;
      _attendanceHistoryFuture = _fetchAttendanceHistory();
    });
  }

  ///main
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children:[

        NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [

              // SliverAppBar with only the title and icon
              SliverAppBar(
                expandedHeight: 60.0, // Standard AppBar height
                pinned: false,// AppBar scrolls out of view
                floating: false,
                backgroundColor: AppConfig.getColor(ColorType.background),
                centerTitle: false, // Ensures left alignment on both platforms
                title: Text(
                  AppConfig.getAppbarTitle(AppConfig.selectedKeyNotifier.value),
                  style: TextStyle(color: AppConfig.getColor(ColorType.text)),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.account_circle),
                    color: AppConfig.getColor(ColorType.text),
                    onPressed: () {
                      _showMyinfo(context, _employeeFuture);
                    },
                  ),
                ],
              ),
              // Persistent filter bar
              SliverPersistentHeader(
                pinned: true,
                floating: false,
                delegate: FilterBarDelegate(

                    startDate: _startDate, // Pass startDate
                    endDate: _endDate, // Pass endDate
                    workTypeSelection: _workTypeSelection,
                    onApplyFilters: _applyFilters,
            ),
              ),
            ];
          },
          body: FutureBuilder<List<Attendance>>(
            future: _attendanceHistoryFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No attendance records found.'));
              } else {



                return Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final attendance = snapshot.data![index];
                      String date = attendance.date;
                      String checkInTime = attendance.checkInTime ?? '';//if null then smpty as ''
                      String checkOutTime = attendance.checkOutTime ?? '';//if null then smpty as ''
                      String workduration = attendance.workduration ?? '';
                      String checkInStatus = attendance.checkInStatus ?? '';
                      String checkOutStatus = attendance.checkOutStatus ?? '';
                      List<String> workTypeList = attendance.workTypeList ?? [''];
                      return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Date with checkInStatus
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "$date",
                                    style: TextStyle(fontSize: 14),//fontWeight: FontWeight.bold), // Bold for emphasis
                                  ),
                                  Text(
                                    "$checkInTime - $checkOutTime",
                                    style: TextStyle(fontSize: 14), // Standard font size
                                  ),

                                ],
                              ),
                              const SizedBox(height: 4), // Add a small gap between rows

                              // Time range with workDuration
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Combine first and second text with a dash
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Text(
                                          checkInStatus,
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          " - ", // Dash between the two texts
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                        Text(
                                          checkOutStatus,
                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Right-aligned third text
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        workTypeList.join(", "), // Join the list items with a comma and space
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      );




                    },
                  ),
                );
              }
            },
          ),
        ),

            OverlappingBox(
              scrollOffset: _scrollOffset,
              lateCount: lateCount,
              absentCount: absentCount,
              dayoffCount: dayoffCount,
              isDataFetched: isDataFetched,
            ),
      ]
    )
    );
  }



}

class OverlappingBox extends StatelessWidget {
  final double scrollOffset;
  final int lateCount;
  final int absentCount;
  final int dayoffCount;
  final bool isDataFetched; // Flag to control displaying count values

  const OverlappingBox({
    required this.scrollOffset,
    required this.lateCount,
    required this.absentCount,
    required this.dayoffCount,
    required this.isDataFetched, // Pass the flag to control visibility
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double position = 160.0 - scrollOffset; // Adjust position dynamically
    double opacity = (position > 100) ? 1.0 : (position / 100).clamp(0.0, 1.0);

    return Positioned(
      top: position.clamp(-100.0, 160.0),
      left: 30,
      right: 30,
      child: Opacity(
        opacity: opacity,
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Late Count with Label
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isDataFetched ? "$lateCount" : "", // Display "" until data is fetched
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "지각", // Label below the count
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
                // Late Count with Label
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isDataFetched ? "$absentCount" : "",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "결근", // Label below the count
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),
                // Late Count with Label
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isDataFetched ? "$dayoffCount" : "",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "휴가", // Label below the count
                      style: TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ],
                ),

              ],
            ),
          ),
        ),



      ),
    );
  }
}
/*
class _ExpandingFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool hasOverlappingBox; // Flag for overlapping box visibility

  _ExpandingFilterBarDelegate({required this.child, required this.hasOverlappingBox});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate height for the main blue box
    double currentHeight = maxExtent - shrinkOffset;
    currentHeight = currentHeight.clamp(minExtent, maxExtent);


    return Stack(
      fit: StackFit.expand,
      children: [
        // Blue box
        Container(
          color: const Color.fromRGBO(97, 124, 255, 1.0), // Blue background
        ),

        // Filter bar content
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: minExtent,
            child: child,
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => 140.0; // Initial height with overlapping box
  @override
  double get minExtent => 60.0; // Minimum height when fully scrolled
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
*/