import 'graphql_service.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/request.dart' as rq; // Import the Attendance model
import '../logger_config.dart';
class SupervisorService {
  // Request a day off for the employee
  Future<void> answerRequest(String employeeOid,String requestStatus, String answerComment, String requestKey ) async {
    String mutation = """
      mutation {
        answerRequest(employeeOid: "$employeeOid",
                      requestStatus: "$requestStatus",
                      answerComment: "$answerComment",
                      requestKey:"$requestKey",
                      )}
    """;
    final variables = {
      'employeeOid': employeeOid,
      'requestStatus': requestStatus,
      'answerComment': answerComment,
      'requestKey':requestKey,
    };
    // Call the mutate method from GraphQLService
    var result = await GraphQLService.mutate(
      mutation,
      variables: variables,
    );
    if (result.hasException) {
      LoggerConfig().logger.e("Error requesting day off: ${result.exception}");
    } else {
      LoggerConfig().logger.i("Day off request status: ${result.data}");
    }
  }

// Fetch request info by current object Id as supervisor
  Future<Map<String, dynamic>> fetchRequestInfo(String employeeOid) async {
    if (employeeOid.isEmpty) {
      throw Exception('Invalid employeeOid: It is null or empty');
    }

    final employeeQuery = '''
    query GetRequestInfo(\$employeeOid: String!) {
      getRequestInfo(employeeOid: \$employeeOid) {
        supervisor {
          name
        }
        supervisorId
        dayoffRemaining
      }
    }
    ''';

    final variables = {'employeeOid': employeeOid};

    try {
      final employeeResult = await GraphQLService.query(
          employeeQuery,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );

      if (employeeResult.hasException) {
        LoggerConfig().logger.e('Employee Query Exception: ${employeeResult.exception}');
        throw Exception('Failed to fetch employee data');
      }

      final employeeData = employeeResult.data?['getEmployeeInfo'];
      if (employeeData == null) {
        throw Exception('Employee not found');
      }
      final returnData={
        'supervisorName': employeeData['supervisor']?['name'] ?? 'N/A',
        'supervisorId': employeeData['supervisorId'] ?? 'N/A',
        'dayoffRemaining': employeeData['dayoffRemaining'] ?? 0,};
      return returnData;
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load employee data');
    }
  }
// Fetch attendance history
  Future<List<rq.Request>> fetchRequestHistory({
    required String employeeOid,
    required String startDate,
    required String endDate,
    List<String>? requestStatusList,
  }) async {
    final query = '''
    query GetRequestHistory(\$employeeOid: String!, \$startDate: String!, \$endDate: String!, \$requestStatusList: [String!] ) {
      getRequestHistory(employeeOid: \$employeeOid, startDate: \$startDate, endDate: \$endDate, requestStatusList: \$requestStatusList) {
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
      'employeeOid': employeeOid,
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
        LoggerConfig().logger.e('Query Exception: ${result.exception}');
        return [];
      }

      final data = result.data;

      if (data != null && data['getRequestHistory'] != null) {
        final List<dynamic> requestList = data['getRequestHistory'];
        return requestList.map((json) => rq.Request.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load dayoff history');
    }
  }

  // Fetch Pending Request
  Future<List<rq.Request>> fetchPendingRequests({
    required String employeeOid,
  }) async {
    final query = '''
    query GetPendingRequests(\$employeeOid: String!) {
      getPendingRequests(employeeOid: \$employeeOid) {
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
      'employeeOid': employeeOid,
    };

    try {

      final result = await GraphQLService.query(
        query,
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly, // Force network fetch

      );// Ensure data is fetched from the server
      if (result.hasException) {
        LoggerConfig().logger.e('Query Exception: ${result.exception}');
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
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load pending requests');
    }
  }
}
