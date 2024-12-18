import 'package:flutter/material.dart';


import 'package:intl/intl.dart'; // For date formatting
import 'config_screen.dart'; // Import AppConfig
import '../services/supervisor_service.dart';
import '../models/request.dart' as rq;
import '../widgets/request_history_filter.dart';
import '../widgets/supervisor_request_answer.dart';

class SupervisorScreen extends StatefulWidget {
  final String? objectId;

  const SupervisorScreen({Key? key, required this.objectId}) : super(key: key);

  @override
  _SupervisorScreenState createState() => _SupervisorScreenState();
}

class _SupervisorScreenState extends State<SupervisorScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SupervisorService _supervisorService = SupervisorService();


  // Filter State

  static const String statusAll="전체";
  static const List<String> default_requestStatusList=["대기중","승인","반려"];
  // Create a Map<String, bool> with all keys having a value of true
  static Map<String, bool> default_requestStatusSelection = {
    for (String status in [statusAll, ...default_requestStatusList]) status: true,
  };
  Map<String,bool> _requestStatusSelection = Map<String, bool>.from(default_requestStatusSelection); // make mutable Map

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();




  ///get a response for search from service
  Future<List<rq.Request>> _fetchRequestHistory() async {
    try {
      List<String> requestStatusList=[
        for (var entry in _requestStatusSelection.entries)
          if (entry.value && default_requestStatusList.contains(entry.key))
            entry.key
      ];
      final requestHistoryData = await _supervisorService.fetchRequestHistory(
        objectId: AppConfig.objectId,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
        requestStatusList: requestStatusList //null directs get all regardless of status
      );
      return requestHistoryData;
    } catch (e) {
      throw Exception('Failed to fetch day-off history: $e');
    }
  }
  ///get a response for pending requests
  Future<List<rq.Request>> _fetchPendingRequests() async {
    try {
      final requestPendingData = await _supervisorService.fetchPendingRequests(
        objectId: AppConfig.objectId,
      );
      return requestPendingData;
    } catch (e) {
      throw Exception('Failed to fetch pending requests: $e');
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
                minHeight: 80.0,
                // Height when fully collapsed
                maxHeight: 130.0,
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
            Column(
              children: [
              // Row with Refresh Icon
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: () {
                          setState(() {
                            _fetchPendingRequests(); // Trigger refresh
                          });
                        },
                      ),
                    ],
                  ),
                ),


            // Tab 1: 승인대기중 tab content
            Expanded(
              child:  FutureBuilder<List<rq.Request>>(
                    future: _fetchPendingRequests(), // Use the new method for pending requests
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('승인 대기중인 요청이 없습니다.'));
                      }

                      // List of pending requests
                      return ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final request = snapshot.data![index];
                          return GestureDetector(
                              onTap: () {
                                // Handle item tap action
                                _onRequestTap(request);
                              },
                              child:Padding(
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



                                      // Use ListTile for the main request information
                                      ListTile(
                                        title: Text(
                                          "${request.employeeName} - ${request.requestType}",
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          "${request.requestDate}",
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey, // Optional: change the color for better visual hierarchy
                                          ),
                                        ),
                                        trailing: Text(
                                          request.requestStatus,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.orange, // Highlight status
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8.0), // Spacing
                                      const Divider(thickness: 1, color: Colors.grey),
                                      const SizedBox(height: 8.0), // Spacing

                                      // Body: Details
                                      // Conditional Details
                                      if (request.requestType == "Dayoff")
                                        ListTile(
                                          title: const Text('기간'),
                                          trailing: Text(
                                            "${request.dayoffDateText ?? 'N/A'}",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      if (request.requestType == "Dayoff")
                                        ListTile(
                                          title: const Text('유형'),
                                          trailing: Text(
                                            "${request.dayoffType ?? 'N/A'}",
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ListTile(
                                        title: const Text('메모'),
                                        trailing: SizedBox(
                                          width: 200, // Set a fixed width to limit the trailing text's width
                                          child: Text(
                                            request.requestComment ?? '없음',
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
                              )
                          );
                        },
                      );
                    },
                  ),
                )
              ]
            ),

            // Tab 2: 승인현황 with FilterBar
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(

                  child: RequestHistoryFilter(
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

                FutureBuilder<List<rq.Request>>(
                  future: _fetchRequestHistory(),
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
                            '검색 결과 없음')),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final request = snapshot.data![index];
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
                                    title: Text(
                                      "${request.employeeName}-${request.requestType}",
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      "${request.requestDate}", // Display the applyDate here
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey, // Optional: change the color for better visual hierarchy
                                      ),
                                    ),
                                    trailing: Text(
                                      request.requestStatus,
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
                                      "${request.dayoffDateText}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('유형'),
                                    trailing: Text(
                                      "${request.dayoffType}",
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                  ListTile(
                                    title: const Text('메모'),
                                    trailing: SizedBox(
                                      width: 200, // Set a fixed width to limit the trailing text's width
                                      child: Text(
                                        request.requestComment ?? '없음',
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
  void _onRequestTap(rq.Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnswerRequestScreen(
          objectId: AppConfig.objectId,
          employeeId: request.employeeId,
          employeeName: request.employeeName,
          requestType: request.requestType,
          requestDate: request.requestDate,
          requestComment: request.requestComment,
          supervisorId: request.supervisorId,
          requestKey: request.requestKey,
        ),
      ),
    );
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
                Tab(text: '승인대기중'),
                Tab(text: '승인현황'),
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
