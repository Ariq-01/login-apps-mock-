import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Global read-only Dio provider for Qwen API (Alibaba proxy)
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000', // Alibaba backend proxy
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  return dio;
});

// Provider untuk memanggil endpoint /api/chat
final chatProvider = FutureProvider<Map<String, dynamic>>((ref, {
  required String message,
  List<Map<String, String>>? messages,
  String model = 'qwen-plus',
}) async {
  final dio = ref.watch(dioProvider);

  final response = await dio.post('/api/chat', data: {
    'message': message,
    if (messages != null) 'messages': messages,
    'model': model,
  });

  return response.data as Map<String, dynamic>;
});
