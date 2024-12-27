import 'graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/dayoff.dart'; // Import the Attendance model
import '../logger_config.dart';
class DayoffService {
  // Request a day off for the employee
  Future<List<String>> requestDayoff(String objectId, List<String> dateList, String dayoffType, String requestComment,int beforeDateRemaining) async {
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
        LoggerConfig().logger.e("Error requesting day off: ${result.exception}");
        return ["Error: ${result.exception.toString()}"];
      }

      // Parse and return the response
      if (result.data != null) {
        var response = result.data?["requestDayoff"];
        LoggerConfig().logger.i("Day off request response: $response");

        // Return the list of messages
        return List<String>.from(response);
      }

      // Fallback if data is null
      return ["Error: No response from server"];
    } catch (e) {
      LoggerConfig().logger.e("Exception during day off request: $e");
      return ["Error: ${e.toString()}"];
    }
  }

// Fetch employee info including supervisor and dayoffRemaining
  Future<Map<String, dynamic>> fetchDayoffInfo(String employeeOid) async {
    if (employeeOid.isEmpty) {
      throw Exception('Invalid objectId: It is null or empty');
    }

    final query = '''
    query GetDayoffInfo(\$employeeOid: String!) {
      getDayoffInfo(employeeOid: \$employeeOid) {
        supervisorName
        supervisorOid
        dayoffRemaining
      }
    }
    ''';

    final variables = {'employeeOid': employeeOid};

    try {
      final response = await GraphQLService.query(
          query,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );

      if (response.hasException) {
        LoggerConfig().logger.e('Employee Query Exception: ${response.exception}');
        throw Exception('Failed to fetch getDayoffInfo data');
      }

      final responseData = response.data?['getDayoffInfo'];
      if (responseData == null) {
        throw Exception('Employee not found');
      }
      final returnData={
        'supervisorName': responseData['supervisorName'] ?? 'N/A',
        'supervisorId': responseData['supervisorOid'] ?? 'N/A',
        'dayoffRemaining': responseData['dayoffRemaining'] ?? 0,};
      return returnData;
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load getDayoffInfo data');
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
        LoggerConfig().logger.e("Query Exception: ${result.exception}");
        return [];
      }

      final data = result.data;
      LoggerConfig().logger.i('API Response: $data');// Print the response for debugging

      if (data != null && data['getEmployeeDayoff'] != null) {
        final List<dynamic> dayoffList = data['getEmployeeDayoff'];
        return dayoffList.map((json) => Dayoff.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load dayoff history');
    }
  }
}
