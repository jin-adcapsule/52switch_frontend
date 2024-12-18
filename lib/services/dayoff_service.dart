import 'graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/dayoff.dart'; // Import the Attendance model
class DayoffService {
  // Request a day off for the employee
  Future<List<String>> RequestDayoff(String objectId, List<String> dateList, String dayoffType, String requestComment,int beforeDateRemaining) async {
    String formattedDateList = dateList.map((date) => '"$date"').toList().toString();
    String mutation = """
      mutation {
        requestDayoff(objectId: "$objectId",
                      dateList: $formattedDateList,
                      dayoffType: "$dayoffType",
                      requestComment: "$requestComment",
                      beforeDateRemaining:$beforeDateRemaining
                        ) 
      }
    """;
    final variables = {
      'objectId': objectId,
      'dateList': formattedDateList,
      'dayoffType': dayoffType,
      'requestComment': requestComment,
      'beforeDateRemaining':beforeDateRemaining,
    };// Assuming dateList is already a properly formatted list of strings// No quotes for integers
    try {
      // Execute the mutation
      var result = await GraphQLService.mutate(
        mutation,
        variables: variables,
      );

      // Check for exceptions
      if (result.hasException) {
        print("Error requesting day off: ${result.exception}");
        return ["Error: ${result.exception.toString()}"];
      }

      // Parse and return the response
      if (result.data != null) {
        var response = result.data?["requestDayoff"];
        print("Day off request response: $response");

        // Return the list of messages
        return List<String>.from(response);
      }

      // Fallback if data is null
      return ["Error: No response from server"];
    } catch (e) {
      print("Exception during day off request: $e");
      return ["Error: ${e.toString()}"];
    }
  }

// Fetch employee info including supervisor and dayoffRemaining
  Future<Map<String, dynamic>> fetchDayoffInfo(String objectId) async {
    if (objectId.isEmpty) {
      throw Exception('Invalid objectId: It is null or empty');
    }

    final employeeQuery = '''
    query GetDayoffInfo(\$objectId: String!) {
      getEmployeeInfo(objectId: \$objectId) {
        supervisorName
        
        supervisorId
        dayoffRemaining
      }
    }
    ''';

    final variables = {'objectId': objectId};

    try {
      final employeeResult = await GraphQLService.query(
          employeeQuery,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );

      if (employeeResult.hasException) {
        print('Employee Query Exception: ${employeeResult.exception}');
        throw Exception('Failed to fetch employee data');
      }

      final employeeData = employeeResult.data?['getEmployeeInfo'];
      if (employeeData == null) {
        throw Exception('Employee not found');
      }
      final return_data={
        'supervisorName': employeeData['supervisorName'] ?? 'N/A',
        'supervisorId': employeeData['supervisorId'] ?? 'N/A',
        'dayoffRemaining': employeeData['dayoffRemaining'] ?? 0,};
      print(return_data);
      return return_data;
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load employee data');
    }
  }
// Fetch attendance history
  Future<List<Dayoff>> fetchDayoffHistory({
    required String objectId,
    required String startDate,
    required String endDate,
    required List<String> requestStatusList,
  }) async {
    final query = '''
    query GetEmployeeDayoff(\$objectId: String!, \$startDate: String!, \$endDate: String!, \$requestStatusList: [String!]) {
      getEmployeeDayoff(objectId: \$objectId, startDate: \$startDate, endDate: \$endDate, requestStatusList: \$requestStatusList) {
        requestStatus
        requestDate
        dayoffDateText
        dayoffType
        requestComment
        requestKey
      }
    }
    ''';

    final variables = {
      'objectId': objectId,
      //'employeeId': employeeId,
      'startDate': startDate,
      'endDate': endDate,
      'requestStatusList': requestStatusList, // Include only if workType is not null
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

      if (data != null && data['getEmployeeDayoff'] != null) {
        final List<dynamic> dayoffList = data['getEmployeeDayoff'];
        return dayoffList.map((json) => Dayoff.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load dayoff history');
    }
  }
}
