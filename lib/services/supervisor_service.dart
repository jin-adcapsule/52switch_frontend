import 'graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/request.dart' as rq; // Import the Attendance model
class SupervisorService {
  // Request a day off for the employee
  Future<void> answerRequest(String objectId,String requestStatus, String answerComment, String requestKey ) async {
    String mutation = """
      mutation {
        answerRequest(objectId: "$objectId",
                      requestStatus: "$requestStatus",
                      answerComment: "$answerComment",
                      requestKey:"$requestKey",
                      )}
    """;
    final variables = {
      'objectId': objectId,
      'requestStatus': requestStatus,
      'answerComment': answerComment,
      'requestKey':requestKey,
    };
    print(requestKey+'1');
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    print(variables);
    if (result.hasException) {
      print("Error requesting day off: ${result.exception}");
    } else {
      print("Day off request status: ${result.data}");
    }
  }

// Fetch request info by current object Id as supervisor
  Future<Map<String, dynamic>> fetchRequestInfo(String objectId) async {
    if (objectId.isEmpty) {
      throw Exception('Invalid objectId: It is null or empty');
    }

    final employeeQuery = '''
    query GetRequestInfo(\$objectId: String!) {
      getRequestInfo(objectId: \$objectId) {
        supervisor {
          name
        }
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
        'supervisorName': employeeData['supervisor']?['name'] ?? 'N/A',
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
  Future<List<rq.Request>> fetchRequestHistory({
    required String objectId,
    required String startDate,
    required String endDate,
    List<String>? requestStatusList,
  }) async {
    final query = '''
    query GetRequestHistory(\$objectId: String!, \$startDate: String!, \$endDate: String!, \$requestStatusList: [String!] ) {
      getRequestHistory(objectId: \$objectId, startDate: \$startDate, endDate: \$endDate, requestStatusList: \$requestStatusList) {
        employeeId
        employeeName
        requestStatus
        requestType
        requestDate
        requestComment
        supervisorId
        requestKey
        
        dayoffDateText
        dayoffType
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

      if (data != null && data['getRequestHistory'] != null) {
        final List<dynamic> requestList = data['getRequestHistory'];
        return requestList.map((json) => rq.Request.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load dayoff history');
    }
  }

  // Fetch Pending Request
  Future<List<rq.Request>> fetchPendingRequests({
    required String objectId,
  }) async {
    final query = '''
    query GetPendingRequests(\$objectId: String!) {
      getPendingRequests(objectId: \$objectId) {
        employeeId
        employeeName
        requestType
        requestStatus
        supervisorId
        requestKey
        requestDate
        requestComment
        dayoffDateText
        dayoffType

      }
    }
    ''';

    final variables = {
      'objectId': objectId,
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
      //print('API Response: $data'); // Print the response for debugging

      if (data != null && data['getPendingRequests'] != null) {
        final List<dynamic> requestList = data['getPendingRequests'];
        return requestList.map((json) => rq.Request.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load pending requests');
    }
  }
}
