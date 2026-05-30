import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory JWT used by [dioClientProvider] for authenticated API calls.
final accessTokenProvider = StateProvider<String?>((ref) => null);
