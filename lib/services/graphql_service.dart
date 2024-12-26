//Client Setup: The GraphQLClient is initialized and held in a ValueNotifier for HttpLink or GraphQLCache
//For query and mutate Method
//Better Error Handling:rethrow keyword optionally rethrows the error so higher-level code can handle it if needed.
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../env_config.dart'; // graphqlendpoint
import "package:gql_websocket_link/gql_websocket_link.dart" as gql_ws;
import '../logger_config.dart';
class GraphQLService {
  // WebSocket endpoint
  static final String webSocketUrl = EnvConfig.apiWebSocketUrl; // Add WebSocket URL in `env_config.dart`
  // HttpLink for queries and mutations
  static final HttpLink httpLink = HttpLink(EnvConfig.apiUrl);
  
  // Initialize the GraphQL client
  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink, //
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  // Query data from the backend with optional variables
  static Future<QueryResult> query(
      String query,
      {Map<String, dynamic>? variables,
      FetchPolicy fetchPolicy = FetchPolicy.cacheFirst, // Default fetch policy
       }) async {
    final GraphQLClient graphqlClient = client.value;
    try {
      final result = await graphqlClient.query(
        QueryOptions(
          document: gql(query),
          variables: variables ?? {},
          fetchPolicy: fetchPolicy, // Use the provided fetch policy
        ),
      );
      if (result.hasException) {
        LoggerConfig().logger.e("Query Exception: ${result.exception}");
      }
      return result;
    } catch (e) {
      LoggerConfig().logger.e("Error during query: $e");
      rethrow; // Optionally rethrow the error for higher-level handling
    }
  }

  // Mutate data on the backend with optional variables
  static Future<QueryResult> mutate(
      String mutation, {
        Map<String, dynamic>? variables,
        FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork, // Default fetch policy
        }) async {
    final GraphQLClient graphqlClient = client.value;
    try {
      final result = await graphqlClient.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variables ?? {},
          fetchPolicy: fetchPolicy, // Use the provided fetch policy
        ),
      );
      if (result.hasException) {
        LoggerConfig().logger.e("Query Exception: ${result.exception}");
      }
      return result;
    } catch (e) {
      LoggerConfig().logger.e("Error during query: $e");
      rethrow; // Optionally rethrow the error for higher-level handling
    }
  }
// Subscribe to real-time data
  static Stream<QueryResult> subscribe(String subscription, {Map<String, dynamic>? variables}) {
    final GraphQLClient graphqlClient = client.value;
    LoggerConfig().logger.i("Starting subscription...");
    return graphqlClient.subscribe(
      SubscriptionOptions(
        document: gql(subscription),
        variables: variables ?? {},
      ),
    ).map((result) {
      if (result.hasException) {
        LoggerConfig().logger.e("Query Exception: ${result.exception}");
      }
      LoggerConfig().logger.i("Subscription Data: ${result.data}");
      return result;
    }).handleError((error) {
      LoggerConfig().logger.e("Error in subscription stream: $error");
    });
  }

}
