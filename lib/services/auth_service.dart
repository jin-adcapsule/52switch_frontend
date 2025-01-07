
import 'package:flutter/material.dart';
import '../services/graphql_service.dart';
import '../logger_config.dart';


class AuthService extends ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }


  // Validates the Firebase UID and phone number and retrieves the associated objectId.
  Future<Map<String, dynamic>?> validateUidAndPhone(String uid, String phone) async {
    const String query = '''
      query ValidateUidAndPhone(\$uid: String!, \$phone: String!) {
        validateUidAndPhone(uid: \$uid, phone: \$phone) {
          employeeOid
          isSupervisor
          currentlyMarked
          employeeName
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'uid': uid,
      'phone': phone,
    };

    try {
        // Indicate the start of a loading process
      setLoading(true);

      // Perform the GraphQL query
      final result = await GraphQLService.query(query, variables: variables);

      // Stop the loading indicator after query completion
      setLoading(false);

      // Handle GraphQL exceptions
      if (result.hasException) {
        LoggerConfig().logger.e('GraphQL Exception: ${result.exception}');
        throw Exception('Validation failed due to server error.');
      }

      // Extract and validate the data
      final data = result.data?['validateUidAndPhone'];
      if (data != null) {
        return {
          'employeeOid': data['employeeOid'],
          'isSupervisor': data['isSupervisor'],
          'currentlyMarked': data['currentlyMarked'],
          'employeeName': data['employeeName'],
        };
      } else {
        throw Exception('Invalid UID or phone number.');
      }
    } catch (e, stackTrace) {
      // Ensure loading is stopped even if an exception occurs
      setLoading(false);

      // Log the error with stack trace for debugging purposes
      LoggerConfig().logger.e('Error in validateUidAndPhone: $e', stackTrace);

      // Rethrow the error for higher-level handling
      rethrow;
    }
  }

  
}
