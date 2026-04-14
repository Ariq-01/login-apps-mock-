import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'network_toQwen.dart';

// State class untuk menampung status chat
class ChatState {
  final bool isLoading;
  final String? response;
  
  ChatState({this.isLoading = false, this.response});
  
  ChatState copyWith({bool? isLoading, String? response}) {
    return ChatState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
    );
  }
}

// ViewModel menggunakan StateNotifier
class ChatViewModel extends StateNotifier<ChatState> {
  final Ref ref;
  
  ChatViewModel(this.ref) : super(ChatState());

  Future<void> sendMessage(String text) async {
    state = ChatState(isLoading: true); // Set loading
    
    try {
      final dio = ref.read(dioProvider);
      final res = await dio.post('/send', data: {'message': text});
      
      state = ChatState(isLoading: false, response: res.data['status'] ?? res.data['response']);
    } catch (e) {
      state = ChatState(isLoading: false, response: 'Error: $e');
    }
  }
}

// Provider untuk diakses UI
final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  return ChatViewModel(ref);
});
