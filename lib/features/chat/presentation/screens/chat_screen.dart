import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/chat_provider.dart';
import '../../domain/message.dart';
import '../../data/chat_repository.dart';
import '../../../voice_control/domain/voice_input_service.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final repository = ChatRepository();
        repository.init();
        return ChatProvider(repository: repository);
      },
      child: const _ChatScreenContent(),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent();

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final VoiceInputService _voiceInput = VoiceInputService();
  late AnimationController _micAnimationController;
  late Animation<double> _micGlowAnimation;
  String _currentLocaleId = 'en_US';
  final List<Map<String, String>> _supportedLanguages = [
    {'name': 'English', 'locale': 'en_US'},
    {'name': 'Urdu', 'locale': 'ur_PK'},
    {'name': 'Hindi', 'locale': 'hi_IN'},
    // Add more languages as needed
  ];

  @override
  void initState() {
    super.initState();
    _voiceInput.initSpeech();
    _micAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _micGlowAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _micAnimationController, curve: Curves.easeInOut),
    );
    _micAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _micAnimationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _micAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _micAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final provider = context.read<ChatProvider>();
    provider.sendMessage(_messageController.text);
    _messageController.clear();

    // Scroll to bottom after sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _retryMessage(Message message) {
    context.read<ChatProvider>().retryFailedMessage(message);
  }

  void _refreshChat() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear Chat History'),
            content: const Text('Are you sure you want to clear all messages?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ChatProvider>().clearMessages();
                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
    );
  }

  void _onLanguageChanged(String? localeId) {
    if (localeId != null) {
      setState(() {
        _currentLocaleId = localeId;
      });
    }
  }

  void _onMicPressed() async {
    if (_voiceInput.isListening) {
      _voiceInput.stopListening();
      _micAnimationController.stop();
    } else {
      _micAnimationController.forward();
      await _voiceInput.startListening((spokenText) {
        setState(() {
          _messageController.text = spokenText;
        });
      }, localeId: _currentLocaleId);
      _micAnimationController.stop();
      _micAnimationController.value = 1.0;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          Consumer<ChatProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: Row(
                    children: [
                      Icon(
                        provider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                        size: 16,
                        color: provider.isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        provider.isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 14,
                          color: provider.isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshChat),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red[100],
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => provider.clearError(),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: Consumer<ChatProvider>(
                builder: (context, provider, child) {
                  if (provider.messages.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Start a Conversation',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Send a message to begin chatting',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: provider.messages.length,
                    itemBuilder: (context, index) {
                      final message = provider.messages[index];
                      final isUser = message.sender == 'user';

                      return Align(
                        alignment:
                            isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black,
                                ),
                              ),
                              if (!message.isSynced) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.sync_problem,
                                      size: 12,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      message.syncError ?? 'Sending...',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                    if (message.syncError != null) ...[
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () => _retryMessage(message),
                                        child: const Icon(
                                          Icons.refresh,
                                          size: 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 8.0,
                right: 8.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 8.0,
              ),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _currentLocaleId,
                    items:
                        _supportedLanguages.map((lang) {
                          return DropdownMenuItem<String>(
                            value: lang['locale'],
                            child: Text(lang['name']!),
                          );
                        }).toList(),
                    onChanged: _onLanguageChanged,
                    underline: Container(),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _micGlowAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale:
                            _voiceInput.isListening
                                ? _micGlowAnimation.value
                                : 1.0,
                        child: IconButton(
                          onPressed: _onMicPressed,
                          icon: Icon(
                            Icons.mic,
                            color: _voiceInput.isListening ? Colors.red : null,
                          ),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
