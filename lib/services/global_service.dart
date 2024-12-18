
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/employee.dart'; // Import the Employee model
import '../services/graphql_service.dart'; // Import GraphQLService

class GlobalService {



  // Fetch employee information
  Future<Employee?> fetchEmployeeInfo(String objectId) async {
    if (objectId.isEmpty) {
      throw Exception('Invalid objectId: It is null or empty');
    }

    final employeeQuery = '''
    query GetEmployeeInfo(\$objectId: String!) {
      getEmployeeInfo(objectId: \$objectId) {
        employeeId
        name
        email
        phone
        position
        joindate

        department
        workplace
        workhour
        
        supervisorId
        supervisorName
        dayoffRemaining
      }

    }
    ''';

    final variables = {
      'objectId': objectId,

    };

    ///employee response to date with exception handling
    try {
      final employeeResult = await GraphQLService.query(
          employeeQuery,
          variables: variables,
          fetchPolicy: FetchPolicy.networkOnly, // Force network fetch
           );
      if (employeeResult.hasException) {
        print('Employee Query Exception: ${employeeResult.exception}');
        return null;
      }

      final employeeData = employeeResult.data?['getEmployeeInfo'];
      print(employeeData);
      if (employeeData == null) {
        print('Error: employeeData is null.');
        throw Exception('Employee not found');
      }

      // Fetch workhour information from the location collection

      // Add supervisor's name
      //final supervisorName = employeeData['supervisor']?['name'] ?? 'N/A';
      //employeeData['supervisorName'] = supervisorName;
      print(employeeData['supervisorName']);
      return Employee.fromJson(employeeData);
    } catch (e) {
      print('Error during GraphQL query: $e');
      throw Exception('Failed to load employee dataaaa');
    }
  }
/*
  // Fetch workhour from the location collection
  Future<Map<String, String>?> fetchWorkHour(String workplace) async {
    final locationQuery = '''
    query GetLocationInfo(\$workplace: String!) {
      getLocationInfo(workplace: \$workplace) {
        workhourOn
        workhourOff
      }
    }
    ''';

    final variables = {
      'workplace': workplace,
    };

    try {
      final locationResult = await GraphQLService.query(
          locationQuery, variables: variables);

      if (locationResult.hasException) {
        print('Location Query Exception: ${locationResult.exception}');
        return null;
      }

      final locationData = locationResult.data?['getLocationInfo'];
      if (locationData != null) {
        return {
          'workhourOn': locationData['workhourOn'],
          'workhourOff': locationData['workhourOff'],
        };
      } else {
        return null;
      }
    } catch (e) {
      print('Error during GraphQL query (Location): $e');
      return null;
    }
  }*/
}