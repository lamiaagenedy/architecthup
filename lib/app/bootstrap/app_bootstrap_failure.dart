class AppBootstrapFailure implements Exception {
  const AppBootstrapFailure(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'AppBootstrapFailure(message: $message, cause: $cause)';
}
