import 'graphql_service.dart';
import '../logger_config.dart';

import 'package:graphql_flutter/graphql_flutter.dart';

class AttendanceService {
  // Mark attendance for the employee with objectId and status
  Future<Map<String, dynamic>> markAttendance(
      String? employeeOid, bool status) async {
    // Define the GraphQL mutation
    const String mutation = """
      mutation MarkAttendance(\$employeeOid: String!, \$status: Boolean!) {
        markAttendance(employeeOid: \$employeeOid, status: \$status) {
          status
        }
      }
    """;

    // Construct variables for the GraphQL mutation
    final Map<String, dynamic> variables = {
      'employeeOid': employeeOid,
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
        LoggerConfig()
            .logger
            .e("GraphQL Exception: ${result.exception.toString()}");
        throw Exception("Failed to mark attendance: ${result.exception}");
      }

      // Extract response data
      final data = result.data?['markAttendance'];

      if (data != null) {
        final bool updatedStatus =
            data['status']; // Get the status from the response
        LoggerConfig().logger.i("Attendance Status: $updatedStatus");
        return {
          'mutationSuccess': true,
          'status': updatedStatus
        }; // Return both success and status
      } else {
        LoggerConfig()
            .logger
            .e("Attendance Mutation Failed: No data returned.");
        return {
          'mutationSuccess': false,
          'status': false
        }; // If no data is returned
      }
    } catch (e) {
      LoggerConfig().logger.e("Error in markAttendance: $e");
      return {'mutationSuccess': false, 'status': false}; // If error occurs
    }
  }

// Fetch attendance status bool
  Future<Map<String, dynamic>> fetchAttendanceStatus(
      String? employeeOid) async {
    final attendanceStatusQuery = '''
    query GetAttendanceStatus(\$employeeOid: String!) {
      getAttendanceStatus(employeeOid: \$employeeOid){
      status
      }

    }
    ''';

    final variables = {
      'employeeOid': employeeOid,
    };

    ///employee response to date with exception handling
    try {
      final result = await GraphQLService.query(
        attendanceStatusQuery,
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
      );
      if (result.hasException) {
        LoggerConfig()
            .logger
            .e('Attendance Status Query Exception: ${result.exception}');
        throw Exception(
            "Failed to fetch attendance Status: ${result.exception}");
      }

      final data = result.data?['getAttendanceStatus'];
      if (data != null) {
        final bool updatedStatus =
            data['status']; // Get the status from the response
        LoggerConfig()
            .logger
            .i("Attendance Status Query Success: $updatedStatus");
        return {
          'querySuccess': true,
          'status': updatedStatus
        }; // Return both success and status
      } else {
        LoggerConfig()
            .logger
            .e('Attendance Status Query Failed: No data returned.');
        return {
          'querySuccess': false,
          'status': false
        }; // If no data is returned
      }
    } catch (e) {
      LoggerConfig().logger.e('Error in fetchAttendanceStatus: $e');
      return {'querySuccess': false, 'status': false}; // If error occurs
    }
  }

// Fetch attendance status bool
  Future<Map<String, dynamic>> fetchAttendanceStatusAndDetails(
      String? employeeOid) async {
    final query = '''
    query GetAttendanceStatusAndDetails(\$employeeOid: String!) {
      getAttendanceStatusAndDetails(employeeOid: \$employeeOid){
      status
      workTypeList
      startTime
      endTime
      locationName
      }

    }
    ''';

    final variables = {
      'employeeOid': employeeOid,
    };

    ///employee response to date with exception handling
    try {
      final result = await GraphQLService.query(
        query,
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
      );
      if (result.hasException) {
        LoggerConfig().logger.e(
            'Attendance Status with Details Query Exception: ${result.exception}');
        throw Exception(
            "Failed to fetch attendance Status with Details: ${result.exception}");
      }

      final data = result.data?['getAttendanceStatusAndDetails'];
      if (data != null) {
        return data; // Return both success and status
      } else {
        throw Exception(
            'Attendance Status with Dateils Query Failed: No data returned.');
      }
    } catch (e) {
      throw Exception('Error in fetchAttendanceStatusAndDetails: $e');
    }
  }
}
