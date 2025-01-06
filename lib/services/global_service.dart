
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/employee.dart'; // Import the Employee model
import '../services/graphql_service.dart'; // Import GraphQLService
import '../logger_config.dart';


class GlobalService {

  // Fetch employee information
  Future<Map<String,dynamic>> fetchLocationInfo(String employeeOid) async {
    if (employeeOid.isEmpty) {
      throw Exception('Invalid employeeOid: It is null or empty');
    }

    final query = '''
    query GetLocationInfo(\$employeeOid: String!) {
      getLocationInfo(employeeOid: \$employeeOid) {
        workplace
        workhourOn
        workhourOff
        workhourHalf
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
        LoggerConfig().logger.e('Location Query Exception: ${result.exception}');
        throw Exception('Location Query Exception');
        
      }

      final response = result.data?['getLocationInfo'];
      if (response == null) {
        LoggerConfig().logger.e('Error: locationData is null.');
        throw Exception('Location not found');
      }

      return response;
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load location data');
    }
  }

  // Fetch employee information
  Future<Employee?> fetchEmployeeInfo(String employeeOid) async {
    if (employeeOid.isEmpty) {
      throw Exception('Invalid employeeOid: It is null or empty');
    }

    final employeeQuery = '''
    query GetEmployeeInfo(\$employeeOid: String!) {
      getEmployeeInfo(employeeOid: \$employeeOid) {
        employeeId
        name
        email
        phone
        position
        joindate

        department
        workplace
        workhour
        
        supervisorOid
        supervisorName
        dayoffPerYear
      }

    }
    ''';

    final variables = {
      'employeeOid': employeeOid,

    };

    ///employee response to date with exception handling
    try {
      final employeeResult = await GraphQLService.query(
          employeeQuery,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );
      if (employeeResult.hasException) {
        LoggerConfig().logger.e('Employee Query Exception: ${employeeResult.exception}');
        return null;
      }

      final employeeData = employeeResult.data?['getEmployeeInfo'];
      if (employeeData == null) {
        LoggerConfig().logger.e('Error: employeeData is null.');
        throw Exception('Employee not found');
      }

      return Employee.fromJson(employeeData);
    } catch (e) {
      LoggerConfig().logger.e('Error during GraphQL query: $e');
      throw Exception('Failed to load employee dataaaa');
    }
  }

}