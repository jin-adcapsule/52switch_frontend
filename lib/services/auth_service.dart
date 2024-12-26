
import 'package:flutter/material.dart';
import '../services/graphql_service.dart';
import '../screens/config_screen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../logger_config.dart';


class AuthService extends ChangeNotifier {

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Subscription stream
  Stream<QueryResult>? _subscriptionStream;

  // Validates the Firebase UID and phone number and retrieves the associated objectId.
  Future<Map<String, dynamic>?> validateUidAndPhone(String uid, String phone) async {
    const String query = '''
      query ValidateUidAndPhone(\$uid: String!, \$phone: String!) {
        validateUidAndPhone(uid: \$uid, phone: \$phone) {
          objectId
          isSupervisor
          currently_marked
          employeeName
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'uid': uid,
      'phone': phone,
    };

    try {
      setLoading(true);

      final result = await GraphQLService.query(query, variables: variables);

      setLoading(false);

      if (result.hasException) {
        LoggerConfig().logger.e('GraphQL Exception: ${result.exception}');
        throw Exception('Validation failed due to server error.');
      }

      final data = result.data?['validateUidAndPhone'];
      if (data != null) {
        final objectId = data['objectId'];
  
      } else {
        throw Exception('Invalid UID or phone number.');
      }
    } catch (e) {
      setLoading(false);
      LoggerConfig().logger.e('Error in validateUidAndPhone: $e');
      rethrow;
    }
  }

  
}
