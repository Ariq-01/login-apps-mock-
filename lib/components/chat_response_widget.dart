import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/user_send_meesages.dart';

class ChatResponseWidget extends ConsumerStatefulWidget {
  const ChatResponseWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatResponseWidget> createState() => _ChatResponseWidgetState();
}

class _ChatResponseWidgetState extends ConsumerState<ChatResponseWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      ref.read(chatViewModelProvider.notifier).sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);

    return Column(
      children: [
        // Area tampilan response
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: chatState.isLoading
                  ? const CircularProgressIndicator()
                  : chatState.response != null
                      ? SelectableText(
                          chatState.response!,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: 18,
                              ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          'Belum ada pesan',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
            ),
          ),
        ),

        // Area input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Ketik pesan...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    filled: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                onPressed: chatState.isLoading ? null : _sendMessage,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
