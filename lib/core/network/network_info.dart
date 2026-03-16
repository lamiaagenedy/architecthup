/// Placeholder connectivity abstraction for later online/offline work.
class NetworkInfo {
  const NetworkInfo();

  Future<bool> get isConnected async => true;
}
