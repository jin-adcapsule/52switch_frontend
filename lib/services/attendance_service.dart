import 'graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AttendanceService {
  static Stream<QueryResult> _subscribeToToggleStatus(String objectId) {
    const subscription = """
      subscription ToggleStatus(\$objectId: String!) {
        toggleStatus(objectId: \$objectId) {
          objectId
          status
        }
      }
    """;
    final stream = GraphQLService.subscribe(
      subscription,
      variables: {'objectId': objectId},
    );
    return GraphQLService.subscribe(
        subscription,
        variables: {'objectId': objectId},

    );
  }

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
        print("GraphQL Exception: ${result.exception.toString()}");
        throw Exception("Failed to mark attendance: ${result.exception}");
      }

      // Extract response data
      final data = result.data?['markAttendance'];

      if (data != null) {
        print("Attendance Mutation Success: $data");
        return true;
      } else {
        print("Attendance Mutation Failed: No data returned.");
        return false;
      }
    } catch (e) {
      print("Error in markAttendance: $e");
      return false;
    }
  }



}