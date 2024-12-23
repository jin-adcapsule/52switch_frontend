import 'graphql_service.dart';
import '../logger_config.dart';

class AttendanceService {
  // Mark attendance for the employee with objectId and status
  Future<bool> markAttendance(String? objectId, bool status) async {
    // Define the GraphQL mutation
    const String mutation = """
      mutation MarkAttendance(\$objectId: String!, \$status: Boolean!) {
        markAttendance(objectId: \$objectId, status: \$status) {
          employeeId
          date
          checkInTime
          checkOutTime
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
        LoggerConfig().logger.i("Attendance Mutation Success: $data");
        return true;
      } else {
        LoggerConfig().logger.e("Attendance Mutation Failed: No data returned.");
        return false;
      }
    } catch (e) {
      LoggerConfig().logger.e("Error in markAttendance: $e");
      return false;
    }
  }



}