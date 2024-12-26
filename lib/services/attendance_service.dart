import 'graphql_service.dart';
import '../logger_config.dart';

import 'package:graphql_flutter/graphql_flutter.dart';


class AttendanceService {
  // Mark attendance for the employee with objectId and status
  Future<Map<String, dynamic>> markAttendance(String? objectId, bool status) async {
    // Define the GraphQL mutation
    const String mutation = """
      mutation MarkAttendance(\$objectId: String!, \$status: Boolean!) {
        markAttendance(objectId: \$objectId, status: \$status) {
          status
        }
      }
    """;

    // Construct variables for the GraphQL mutation
    final Map<String, dynamic> variables = {
      'objectId': objectId,
      'status': status,
    };

    try {
      // Execute the mutation
      final result = await GraphQLService.mutate(
        mutation,
        variables: variables,
      );

      // Handle potential GraphQL exceptions
      if (result.hasException) {
        LoggerConfig().logger.e("GraphQL Exception: ${result.exception.toString()}");
        throw Exception("Failed to mark attendance: ${result.exception}");
      }

      // Extract response data
      final data = result.data?['markAttendance'];

      if (data != null) {
        final bool updatedStatus = data['status']; // Get the status from the response
        LoggerConfig().logger.i("Attendance Mutation Success: $updatedStatus");
        return {'mutationSuccess': true, 'status': updatedStatus}; // Return both success and status
      } else {
        LoggerConfig().logger.e("Attendance Mutation Failed: No data returned.");
        return {'mutationSuccess': false, 'status': false}; // If no data is returned
      }
    } catch (e) {
      LoggerConfig().logger.e("Error in markAttendance: $e");
      return {'mutationSuccess': false, 'status': false}; // If error occurs
    }
  }

// Fetch attendance status bool
  Future<Map<String, dynamic>> fetchAttendanceStatus(String? objectId) async {

    final attendanceStatusQuery = '''
    query GetAttendanceStatus(\$objectId: String!) {
      getAttendanceStatus(objectId: \$objectId){
      status
      }

    }
    ''';

    final variables = {
      'objectId': objectId,

    };

    ///employee response to date with exception handling
    try {
      final result = await GraphQLService.query(
          attendanceStatusQuery,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );
      if (result.hasException) {
        LoggerConfig().logger.e('Attendance Status Query Exception: ${result.exception}');
        throw Exception("Failed to fetch attendance Status: ${result.exception}");
      }

      final data = result.data?['getAttendanceStatus'];
      if (data != null) {
        final bool updatedStatus = data['status']; // Get the status from the response
        LoggerConfig().logger.i("Attendance Status Query Success: $updatedStatus");
        return {'querySuccess': true, 'status': updatedStatus}; // Return both success and status
      }else{
        LoggerConfig().logger.e('Attendance Status Query Failed: No data returned.');
        return {'querySuccess': false, 'status': false}; // If no data is returned
      }
    } catch (e) {
      LoggerConfig().logger.e('Error in fetchAttendanceStatus: $e');
      return {'querySuccess': false, 'status': false}; // If error occurs
    }

  }

}