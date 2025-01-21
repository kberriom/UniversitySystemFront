enum UniSysApiRequestMethod {
  rest,
  graphQl
}

enum UniSysApiRestRequestType {
  get(),
  post(),
  put(),
  patch(),
  delete();
}

enum UniSysApiGraphQlRequestType {
  query,
  mutation,
}

typedef Json = Map<String, dynamic>;

final class UniSystemRequest {
  final Json? body;
  final Map<String, String>? query;
  final String endpoint;
  final UniSysApiRestRequestType type;
  final bool includeResponseBodyOnException;

  const UniSystemRequest({
    required this.endpoint,
    required this.type,
    this.query,
    this.body,
    this.includeResponseBodyOnException = false,
  });

  factory UniSystemRequest.graphQl({
    required UniSysApiGraphQlRequestType requestType,
    required String operationName,
    required String operation,
  }) {
    return UniSystemRequest(endpoint: 'graphql', type: UniSysApiRestRequestType.post, body: {
      "operationName": operationName,
      "query": '${requestType.name} $operationName {$operation}',
    });
  }

  @override
  String toString() {
    return 'UniSystemRequest{body: $body, query: $query, endpoint: $endpoint, type: $type}';
  }
}
