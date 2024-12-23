
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
        if (objectId!=null){startToggleStatusSubscription(objectId);}
        return {
          'objectId': objectId,
          'is_supervisor': data['isSupervisor'],
          'currently_marked': data['currently_marked'],
          'employeeName': data['employeeName']
        };
      } else {
        throw Exception('Invalid UID or phone number.');
      }
    } catch (e) {
      setLoading(false);
      LoggerConfig().logger.e('Error in validateUidAndPhone: $e');
      rethrow;
    }
  }

  // Starts the toggleStatus subscription
  void startToggleStatusSubscription(String objectId) {

    const String subscriptionQuery = '''
      subscription ToggleStatus(\$objectId: String!) {
        toggleStatus(objectId: \$objectId) {
          objectId
          date
          status
        }
      }
    ''';

    final Map<String, dynamic> variables = {
      'objectId': objectId,
    };

    try {
      //stopToggleStatusSubscription();// Stop any existing subscription
      //print('Subscription stoped');
      _subscriptionStream = GraphQLService.subscribe(
        subscriptionQuery,
        variables: variables,
      );


      _subscriptionStream?.listen(
            (QueryResult result) {
          if (result.hasException) {
            LoggerConfig().logger.e('Subscription Exception: ${result.exception}');
            return;
          }

          final data = result.data?['toggleStatus'];
          if (data != null) {
            final status = data['status'];
            LoggerConfig().logger.i('Subscription Update - New Status: $status');
            AppConfig.isAttendanceMarkedNotifier.value = status; // Update global state
          } else {
            LoggerConfig().logger.e('Subscription Data is null');
          }
        },
        onError: (error) {
          LoggerConfig().logger.e('Subscription Stream Error: $error');
        },
        onDone: () {
          LoggerConfig().logger.i('Subscription Stream Completed');
        },
      );

    } catch (e) {
      LoggerConfig().logger.e('Error starting subscription: $e');
    }


  }

  // Stop the subscription (e.g., on logout)
  void stopToggleStatusSubscription() {
    if (_subscriptionStream != null) {
      _subscriptionStream?.listen(null).cancel();
      _subscriptionStream = null; // Reset the stream
      LoggerConfig().logger.i('Subscription stopped.');
    } else {
      LoggerConfig().logger.i('No active subscription to stop.');
    }

  }
  @override
  void dispose() {
    stopToggleStatusSubscription(); // Ensure cleanup
    super.dispose();
  }
}
