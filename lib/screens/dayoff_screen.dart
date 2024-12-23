import 'package:flutter/material.dart';
import '../widgets/dayoff_request.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'config_screen.dart'; // Import AppConfig
import '../services/dayoff_service.dart';
import '../models/dayoff.dart';
import '../widgets/dayoff_history_filter.dart';
// Public create function
Widget createDayoffScreen(String objectId) {
  return _DayoffScreen(objectId: objectId);
}
class _DayoffScreen extends StatefulWidget {
  final String? objectId;

  const _DayoffScreen({super.key, required this.objectId});

  @override
  _DayoffScreenState createState() => _DayoffScreenState();
}

class _DayoffScreenState extends State<_DayoffScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DayoffService _dayoffService = DayoffService();


  // Filter State
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  static const String statusAll="전체";
  static const List<String> defaultRequestStatusList=["대기중","승인","반려"];
  // Create a Map<String, bool> with all keys having a value of true
  static Map<String, bool> defaultRequestStatusSelection = {
    for (String status in [statusAll, ...defaultRequestStatusList]) status: true,
  };
  Map<String,bool> _requestStatusSelection = Map<String, bool>.from(defaultRequestStatusSelection); // make mutable Map


  ///get a response for search from service
  Future<List<Dayoff>> _fetchDayoffHistory() async {
    try {
      List<String>  requestStatusList =
        [
          for (var entry in _requestStatusSelection.entries)
            if (entry.value && defaultRequestStatusList.contains(entry.key))
              entry.key
        ];

      final dayoffData = await _dayoffService.fetchDayoffHistory(
        objectId: AppConfig.objectId,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
        requestStatusList: requestStatusList , //null directs get all regardless of status
      );
      return dayoffData;
    } catch (e) {
      throw Exception('Failed to fetch day-off history: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Initialize TabController
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose of the controller to avoid memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // SliverPersistentHeader with text and TabBar
            SliverPersistentHeader(
              pinned: true,
              delegate: _DynamicTextWithTabBarSliverPersistentHeaderDelegate(
                minHeight: 100.0,
                // Height when fully collapsed
                maxHeight: 150.0,
                // Height when fully expanded
                text: AppConfig.getAppbarTitle(AppConfig.selectedKeyNotifier
                    .value),
                backgroundColor: AppConfig.getColor(ColorType.background),
                textColor: AppConfig.getColor(ColorType.text),
                tabController: _tabController, // Pass the TabController
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController, // Attach the TabController
          children: [
            // Tab 1: 신청 tab content with "Request Day Off" button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _onDayoffRequestTap, // Call the function on tap
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          left: 20.0, top: 40.0, bottom: 40.0, right: 20.0),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // Background color
                        borderRadius: BorderRadius.circular(8),
                        // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            // Shadow color
                            blurRadius: 6.0,
                            // Blur radius
                            offset: Offset(0, 3), // Shadow offset
                          ),
                        ],
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // Spread content
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // Align vertically in the center
                          children: [
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    '휴가신청',
                                    style: TextStyle(
                                      color: Colors.black, // Text color
                                      fontSize: 18, // Font size
                                    ),
                                  ),
                                  SizedBox(height: 8.0), // Space between lines
                                  Text(
                                    '명일 이후 휴가신청 가능', // Second line of text
                                    style: TextStyle(
                                      color: Colors.black54,
                                      // Text color for second line
                                      fontSize: 14, // Font size for second line
                                    ),
                                  ),
                                ]
                            ),
                            const Icon(
                              Icons.luggage, // Luggage icon
                              color: Colors.blue, // Icon color
                              size: 80, // Icon size
                            ),
                          ]
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tab 2: 신청현황 with FilterBar
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(

                    child: DayoffHistoryFilter(
                      startDate: _startDate,
                      endDate: _endDate,
                      requestStatusSelection: _requestStatusSelection,
                      onApplyFilters: (start, end, stat) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                          _requestStatusSelection = stat;
                        });
                      },
                    ),
                  ),

                FutureBuilder<List<Dayoff>>(
                  future: _fetchDayoffHistory(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text('Error: ${snapshot.error}')),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Center(child: Text(
                            'No day-off history available')),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final dayoff = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.white, // Box background color
                                borderRadius: BorderRadius.circular(8.0), // Rounded corners
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade300,
                                    blurRadius: 5.0, // Soft shadow
                                    offset: const Offset(0, 3), // Shadow position
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Use ListTile for "휴가신청"
                                  ListTile(
                                    title: const Text(
                                      "휴가신청",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      dayoff.requestDate, // Display the applyDate here
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey, // Optional: change the color for better visual hierarchy
                                      ),
                                    ),
                                    trailing: Text(
                                      dayoff.requestStatus,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.blue, // Status color
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8.0), // Spacing
                                  const Divider(thickness: 1, color: Colors.grey),
                                  const SizedBox(height: 8.0), // Spacing

                                  // Body: Details

                                      ListTile(
                                        title: const Text('기간'),
                                        trailing: Text(
                                          dayoff.dayoffDateText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('유형'),
                                        trailing: Text(
                                          dayoff.dayoffType,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('메모'),
                                        trailing: SizedBox(
                                          width: 200, // Set a fixed width to limit the trailing text's width
                                          child: Text(
                                            dayoff.requestComment,
                                            textAlign: TextAlign.right, // Align the text to the right
                                            style: const TextStyle(fontSize: 12, height: 1.5), // Add line spacing
                                            maxLines: 3, // Limit the number of lines (adjust as needed)
                                            overflow: TextOverflow.ellipsis, // Handle text overflow with ellipsis
                                          ),
                                        ),
                                      ),


                                ],
                              ),
                            ),
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _onDayoffRequestTap() async {
    if (widget.objectId == null || widget.objectId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid user ID')),
      );
      return;
    }

    try {
      // Fetch data
      final employeeData = await _dayoffService.fetchDayoffInfo(
          widget.objectId!);

      // Navigate to DayoffRequestScreen with fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DayoffRequestScreen(
                objectId: widget.objectId,
                supervisorName: employeeData['supervisorName'],
                supervisorId: employeeData['supervisorId'],
                dayoffRemaining: employeeData['dayoffRemaining'],
              ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

}
// Custom Delegate for Dynamic Text with TabBar
class _DynamicTextWithTabBarSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final TabController tabController;

  _DynamicTextWithTabBarSliverPersistentHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Calculate position and opacity
    double fadeStart = 0.0; // Start fading out immediately
    double fadeEnd = maxHeight - minHeight; // Fully faded out when collapsed
    double opacity = 1.0 - ((shrinkOffset - fadeStart) / (fadeEnd - fadeStart)).clamp(0.0, 1.0);

    // Get status bar height to adjust for safe area (iOS specific)
    double statusBarHeight = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        // Background container
        Container(
          color: backgroundColor,
        ),

        // Top-left fading text
        Positioned(
          top: statusBarHeight + 8.0, // Add padding below the status bar
          left: 16.0,
          child: Opacity(
            opacity: opacity,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 24,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Bottom-left aligned TabBar
        Positioned(
          bottom: 0.0,
          left: 0.0,
          right: 0.0, // Stretch across the bottom
          child: Container(
            color: Colors.transparent, // TabBar background
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: tabController,
              isScrollable: true,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              indicatorWeight: 2.0,
              indicatorPadding: EdgeInsets.zero,
              tabs: const [
                Tab(text: '신청'),
                Tab(text: '신청현황'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true; // Rebuild if any parameter changes
  }
}
