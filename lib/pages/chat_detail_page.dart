import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pe_emoease_mobileapp_flutter/models/chat_session.dart';
import 'package:pe_emoease_mobileapp_flutter/models/chat_message.dart';
import 'package:pe_emoease_mobileapp_flutter/services/chat_service.dart';

class ChatDetailPage extends StatefulWidget {
  final ChatSession session;
  const ChatDetailPage({super.key, required this.session});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();

  List<ChatMessage> _messages = [];
  bool _loading = false;
  bool _sendLoading = false;
  String? _error;
  String _inputText = "";
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  // Pending delayed messages
  List<ChatMessage>? _pendingDelayedMessages;
  List<Timer> _delayedTimers = [];
  bool _showingDelayed = false;

  // Animation cho Emo đang suy nghĩ
  late AnimationController _dotsAnimCtrl;
  late Animation<double> _dot1, _dot2, _dot3;

  // Keyboard
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _dotsAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _dot1 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _dotsAnimCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );
    _dot2 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _dotsAnimCtrl, curve: const Interval(0.2, 0.7, curve: Curves.easeInOut)),
    );
    _dot3 = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _dotsAnimCtrl, curve: const Interval(0.4, 0.9, curve: Curves.easeInOut)),
    );
    _fetchMessages();
    // Listen to keyboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardListener();
    });
  }

  void _keyboardListener() {
    // Use WidgetsBinding observer if muốn chuẩn platform hơn
    // Ở đây đơn giản dùng viewInsets
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async => setState(() {}),
        suspendingCallBack: () async => setState(() {}),
      ),
    );
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final msgs = await _chatService.fetchMessages(sessionId: widget.session.id);
      setState(() {
        _messages = msgs;
      });
      _scrollToEnd();
    } catch (e) {
      setState(() => _error = "Không thể tải tin nhắn.");
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_inputText.trim().isEmpty || _sendLoading) return;
    final text = _inputText.trim();
    setState(() {
      _sendLoading = true;
      _inputText = "";
      _inputCtrl.clear();
      _messages.add(ChatMessage(
        id: "temp-${DateTime.now().millisecondsSinceEpoch}",
        content: text,
        sender: "user",
        timestamp: DateTime.now()
      ));
    });
    _scrollToEnd();
    _dotsAnimCtrl.repeat();

    try {
      final aiMessages = await _chatService.sendMessage(sessionId: widget.session.id, userMessage: text);
      // Xử lý delayed message (giả lập, tuỳ response backend)
      if (aiMessages.length > 1) {
        setState(() {
          _messages.add(aiMessages.first);
          _pendingDelayedMessages = aiMessages.sublist(1);
          _showingDelayed = true;
        });
        _scheduleDelayedMessages();
      } else {
        setState(() {
          _messages.addAll(aiMessages);
        });
      }
    } catch (e) {
      setState(() {
        _error = "Không thể gửi tin nhắn.";
        // Gỡ message user nếu failed
        _messages.removeWhere((m) => m.id?.startsWith('temp-') ?? false);
      });
    } finally {
      if (!_showingDelayed) _dotsAnimCtrl.reset();
      setState(() => _sendLoading = false);
    }
    _scrollToEnd();
  }

  void _scheduleDelayedMessages() {
    _delayedTimers.forEach((t) => t.cancel());
    _delayedTimers.clear();
    if (_pendingDelayedMessages == null) return;
    for (int i = 0; i < _pendingDelayedMessages!.length; i++) {
      final msg = _pendingDelayedMessages![i];
      final t = Timer(Duration(seconds: (i + 1) * 3), () {
        if (mounted) {
          setState(() {
            _messages.add(msg);
            //Nếu là cuối cùng thì tắt "đang suy nghĩ"
            if (i == _pendingDelayedMessages!.length - 1) {
              _showingDelayed = false;
              _pendingDelayedMessages = null;
              _dotsAnimCtrl.reset(); //Dừng luôn hiệu ứng chấm
            }
          });
          _scrollToEnd();
        }
      });
      _delayedTimers.add(t);
    }
    // Clear pending để không lặp lại khi rebuild
    setState(() {
      _pendingDelayedMessages = null;
    });
  }

  void _scrollToEnd() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _dotsAnimCtrl.dispose();
    _delayedTimers.forEach((t) => t.cancel());
    super.dispose();
  }

  Widget _typingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar Emo
          Container(
            width: 34, height: 34,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF502484), width: 2),
            ),
            child: ClipOval(
              child: Image.asset('assets/images/emo.jpg', fit: BoxFit.cover),
            ),
          ),
          // Cột gồm: dòng chữ + dấu chấm
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Emo đang suy nghĩ...", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(18).copyWith(bottomLeft: const Radius.circular(6)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(opacity: _dot1, child: _buildDot()),
                    const SizedBox(width: 5),
                    FadeTransition(opacity: _dot2, child: _buildDot()),
                    const SizedBox(width: 5),
                    FadeTransition(opacity: _dot3, child: _buildDot()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildDot() => Container(
    width: 9, height: 9,
    decoration: BoxDecoration(color: Colors.grey[500], shape: BoxShape.circle),
  );

  Widget _buildMessage(ChatMessage msg) {
    final isUser = msg.sender == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Row(
              children: [
                Container(
                  width: 34, height: 34,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF502484), width: 2),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/images/emo.jpg', fit: BoxFit.cover),
                  ),
                ),
                const Text("Emo AI", style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          Container(
            margin: const EdgeInsets.only(top: 5),
            constraints: const BoxConstraints(maxWidth: 310),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF502484) : Colors.grey[100],
              borderRadius: BorderRadius.circular(18)
                  .copyWith(bottomRight: isUser ? const Radius.circular(7) : null, bottomLeft: !isUser ? const Radius.circular(7) : null),
            ),
            child: Text(
              msg.content,
              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2, left: 6, right: 6),
            child: Text(
              _formatTime(msg.timestamp),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    // Hiển thị giờ:phút (ví dụ 09:42)
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 68, left: 28, right: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF502484), width: 3),
              ),
              margin: const EdgeInsets.only(bottom: 18),
              child: ClipOval(
                child: Image.asset('assets/images/emo.jpg', fit: BoxFit.cover),
              ),
            ),
            const Text(
              "Chào mừng bạn đến với Emo Chat!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF502484)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Hãy chia sẻ cảm xúc và suy nghĩ của bạn. Emo AI sẽ lắng nghe và hỗ trợ bạn.",
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)), textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.fromLTRB(18, isTablet ? 30 : 18, 18, isTablet ? 20 : 14),
              decoration: BoxDecoration(
                color: const Color(0xFF502484),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: const [BoxShadow(color: Color(0x22502484), blurRadius: 14, offset: Offset(0, 5))],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.session.sessionName.isNotEmpty
                              ? widget.session.sessionName
                              : "Đoạn chat mới",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          children: [
                            Text(
                              _sendLoading || _showingDelayed
                                  ? "Emo đang suy nghĩ..."
                                  : "Emo AI  ",
                              style: const TextStyle(fontSize: 14, color: Color(0xFFD1BCFF)),
                            ),
                            if (!_sendLoading && !_showingDelayed)
                              const Padding(
                                padding: EdgeInsets.only(left: 3),
                                child: Icon(Icons.circle, color: Color(0xFF2ecc71), size: 12),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 38,
                    width: 38,
                    margin: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(19),
                      child: Image.asset('assets/images/emo.jpg', fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border(left: BorderSide(color: Colors.red, width: 4)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 15)),
                ),
              ),
            Expanded(
              child: _loading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(color: Color(0xFF502484)),
                    SizedBox(height: 14),
                    Text('Đang tải tin nhắn...', style: TextStyle(color: Colors.deepPurple)),
                  ],
                ),
              )
                  : _messages.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.only(bottom: 10, top: 16),
                itemCount: _messages.length +
                    ((_sendLoading || _showingDelayed) ? 1 : 0),
                itemBuilder: (ctx, i) {
                  if ((_sendLoading || _showingDelayed) && i == _messages.length) {
                    return _typingIndicator();
                  }
                  return _buildMessage(_messages[i]);
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                left: 14, right: 10,
                top: 10,
                bottom: 12
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 100),
                      child: TextField(
                        enableIMEPersonalizedLearning: true,
                        controller: _inputCtrl,
                        enabled: !_sendLoading,
                        onChanged: (val) => setState(() => _inputText = val),
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        onSubmitted: (_) => _sendMessage(),
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: _inputText.trim().isNotEmpty && !_sendLoading
                            ? const Color(0xFF502484)
                            : Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _sendLoading
                            ? const SizedBox(
                          width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                            : const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
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

// Nếu muốn handle keyboard viewInsets chuẩn iOS/Android hơn, bạn có thể dùng thêm package flutter_keyboard_visibility hoặc context.viewInsets.bottom

// Dùng để trigger rebuild khi resume/suspend nếu muốn giữ lại UI như React Native SafeArea
class LifecycleEventHandler extends WidgetsBindingObserver {
  final Future<void> Function()? resumeCallBack;
  final Future<void> Function()? suspendingCallBack;

  LifecycleEventHandler({this.resumeCallBack, this.suspendingCallBack});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (resumeCallBack != null) resumeCallBack!();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        if (suspendingCallBack != null) suspendingCallBack!();
        break;
      default:
        break;
    }
  }
}
