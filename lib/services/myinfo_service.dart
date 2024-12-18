// send a POST request to the GraphQL endpoint and parse the response

import 'package:flutter/cupertino.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/employee.dart'; // Import the Employee model
import '../models/attendance.dart'; // Import the Attendance model
import '../services/graphql_service.dart'; // Import GraphQLService


class MyInfoService {

// Fetch attendance history
  Future<List<Attendance>> fetchAttendanceHistory({
    required String objectId,
    //required int employeeId,
    required String startDate,
    required String endDate,
    required List<String> workTypeList,
  }) async {
    final query = '''
    query GetEmployeeAttendance(\$objectId: String!, \$startDate: String!, \$endDate: String!, \$workTypeList: [String!]) {
      getEmployeeAttendance(objectId: \$objectId, startDate: \$startDate, endDate: \$endDate, workTypeList: \$workTypeList) {
        employeeId
        date
        checkInTime
        checkOutTime
        status
        checkInStatus
        checkOutStatus
        workTypeList
        
      }
    }
    ''';

    final variables = {
      'objectId': objectId,
      //'employeeId': employeeId,
      'startDate': startDate,
      'endDate': endDate,
      'workTypeList': workTypeList,
    };

    try {

      final result = await GraphQLService.query(
          query,
          variables: variables,
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch

      );// Ensure data is fetched from the server
      if (result.hasException) {
        print('Query Exception: ${result.exception}');
        return [];
      }

      final data = result.data;
      print('API Response: $data'); // Print the response for debugging

      if (data != null && data['getEmployeeAttendance'] != null) {
        final List<dynamic> attendanceList = data['getEmployeeAttendance'];
        return attendanceList.map((json) => Attendance.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load attendance history');
    }
  }


}
