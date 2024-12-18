//Client Setup: The GraphQLClient is initialized and held in a ValueNotifier for HttpLink or GraphQLCache
//For query and mutate Method
//Better Error Handling:rethrow keyword optionally rethrows the error so higher-level code can handle it if needed.
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../env_config.dart'; // graphqlendpoint
import "package:gql_websocket_link/gql_websocket_link.dart" as gql_ws;
class GraphQLService {
  // WebSocket endpoint
  static final String webSocketUrl = EnvConfig.apiWebSocketUrl; // Add WebSocket URL in `env_config.dart`
  // HttpLink for queries and mutations
  static final HttpLink httpLink = HttpLink(EnvConfig.apiUrl);
  /*
  // WebSocketLink for subscriptions
  static final WebSocketLink webSocketLink = WebSocketLink(
    webSocketUrl,
    config: SocketClientConfig(
      autoReconnect: true,
      inactivityTimeout: Duration(minutes: 1),
      initialPayload: () => {
    "type": "connection_init",
    "payload": {}, // Optional authentication or metadata
    },
    
    ),
  );*/
// WebSocketLink for subscriptions by gql_websocket_link
  //static final gql_ws.WebSocketLink webSocketLink = gql_ws.WebSocketLink(webSocketUrl);

  static final gql_ws.TransportWebSocketLink webSocketLink = gql_ws.TransportWebSocketLink(
      gql_ws.TransportWsClientOptions(
          // Provide the WebSocket URL
        socketMaker: gql_ws.WebSocketMaker.url(() => webSocketUrl)
      ),

    );

  // Combine HttpLink and WebSocketLink
  static final Link link = Link.split(
        (request) => request.isSubscription, // Route subscriptions to WebSocketLink
    //webSocketLink,
    webSocketLink,
    httpLink,
  );
  // Initialize the GraphQL client
  static ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link, //
      cache: GraphQLCache(store: InMemoryStore()),
    ),
  );

  // Query data from the backend with optional variables
  static Future<QueryResult> query(
      String query,
      {Map<String, dynamic>? variables,
      FetchPolicy fetchPolicy = FetchPolicy.cacheFirst, // Default fetch policy
       }) async {
    final GraphQLClient _client = client.value;
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(query),
          variables: variables ?? {},
          fetchPolicy: fetchPolicy, // Use the provided fetch policy
        ),
      );
      if (result.hasException) {
        print("Query Exception: ${result.exception}");
      }
      return result;
    } catch (e) {
      print("Error during query: $e");
      rethrow; // Optionally rethrow the error for higher-level handling
    }
  }

  // Mutate data on the backend with optional variables
  static Future<QueryResult> mutate(
      String mutation, {
        Map<String, dynamic>? variables,
        FetchPolicy fetchPolicy = FetchPolicy.cacheAndNetwork, // Default fetch policy
        }) async {
    final GraphQLClient _client = client.value;
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(mutation),
          variables: variables ?? {},
          fetchPolicy: fetchPolicy, // Use the provided fetch policy
        ),
      );
      if (result.hasException) {
        print("Mutation Exception: ${result.exception}");
      }
      return result;
    } catch (e) {
      print("Error during mutation: $e");
      rethrow; // Optionally rethrow the error for higher-level handling
    }
  }
// Subscribe to real-time data
  static Stream<QueryResult> subscribe(String subscription, {Map<String, dynamic>? variables}) {
    final GraphQLClient _client = client.value;
    print("Starting subscription...");
    return _client.subscribe(
      SubscriptionOptions(
        document: gql(subscription),
        variables: variables ?? {},
      ),
    ).map((result) {
      if (result.hasException) {
        print("Subscription Exception: ${result.exception}");
      }
      print("Subscription Data: ${result.data}");
      return result;
    }).handleError((error) {
      print("Error in subscription stream: $error");
    });
  }

}
