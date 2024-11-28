enum UniSysApiRequestType {
  get(),
  post(),
  put(),
  patch(),
  delete();
}

typedef Json = Map<String, dynamic>;

final class UniSystemRequest {
  final Json? body;
  final Map<String, String>? query;
  final String endpoint;
  final UniSysApiRequestType type;
  final bool includeResponseBodyOnException;

  const UniSystemRequest({required this.endpoint, required this.type, this.query, this.body, this.includeResponseBodyOnException = false});

  @override
  String toString() {
    return 'UniSystemRequest{body: $body, query: $query, endpoint: $endpoint, type: $type}';
  }
}
