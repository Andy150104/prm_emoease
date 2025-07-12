import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/models/chat_session.dart';
import 'package:pe_emoease_mobileapp_flutter/services/chat_service.dart';
import 'chat_detail_page.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with SingleTickerProviderStateMixin {
  final ChatService _chatService = ChatService();

  List<ChatSession> _sessions = [];
  bool _loading = false;
  bool _createLoading = false;
  bool _deleteLoading = false;
  String? _error;
  int _pageIndex = 1;
  int _pageSize = 5;
  bool _hasMore = true;

  // Modal tạo session mới
  bool _modalVisible = false;
  String _sessionName = "";

  // Animation cho modal
  late AnimationController _modalAnimCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _fetchSessions(reset: true);
    _modalAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_modalAnimCtrl);
    _scaleAnim = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _modalAnimCtrl, curve: Curves.easeOutBack),
    );
  }

  Future<void> _fetchSessions({bool reset = false}) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      if (reset) _sessions.clear();
      if (reset) _pageIndex = 1;
      _error = null;
    });
    try {
      final sessions = await _chatService.fetchSessions(pageIndex: _pageIndex, pageSize: _pageSize);
      setState(() {
        if (reset) {
          _sessions = sessions;
        } else {
          _sessions.addAll(sessions);
        }
        _hasMore = sessions.length == _pageSize;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchSessions(reset: true);
  }

  void _openCreateModal() {
    setState(() {
      _modalVisible = true;
    });
    _modalAnimCtrl.forward(from: 0);
  }

  void _closeCreateModal() {
    _modalAnimCtrl.reverse().then((_) {
      setState(() {
        _modalVisible = false;
        _sessionName = "";
      });
    });
  }

  Future<void> _handleCreateSession() async {
    if (_createLoading) return;
    setState(() => _createLoading = true);
    try {
      final newSession = await _chatService.createSession(sessionName: _sessionName.trim().isEmpty ? null : _sessionName);
      _closeCreateModal();
      await _fetchSessions(reset: true);
      // Sau khi tạo, mở luôn detail page cho tiện UX
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ChatDetailPage(session: newSession)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể tạo phiên chat mới")));
      }
    } finally {
      setState(() => _createLoading = false);
    }
  }

  Future<void> _handleDeleteSession(String sessionId, String? sessionName) async {
    if (_deleteLoading) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá cuộc trò chuyện'),
        content: Text('Bạn có chắc muốn xoá "${sessionName ?? 'cuộc trò chuyện này'}"? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Huỷ')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _deleteLoading = true);
    try {
      await _chatService.deleteSession(sessionId);
      _fetchSessions(reset: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Không thể xoá phiên chat")));
      }
    } finally {
      setState(() => _deleteLoading = false);
    }
  }

  void _goToDetail(ChatSession session) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatDetailPage(session: session)),
    );
  }

  String _formatDate(DateTime date) {
    // Tuỳ chỉnh cho đẹp hơn nếu muốn!
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  void dispose() {
    _modalAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 18),
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
                      const Text('Chat với Emo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                      const Spacer(),
                      Container(
                        height: 36,
                        width: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset('assets/images/emo.jpg', fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF502484),
                    child: _loading && _sessions.isEmpty
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(color: Color(0xFF502484)),
                          SizedBox(height: 14),
                          Text('Đang tải cuộc trò chuyện...', style: TextStyle(color: Colors.deepPurple)),
                        ],
                      ),
                    )
                        : _sessions.isEmpty
                        ? _buildEmpty(height)
                        : ListView.builder(
                      itemCount: _sessions.length + (_hasMore ? 1 : 0),
                      padding: const EdgeInsets.only(top: 20, bottom: 120),
                      itemBuilder: (context, idx) {
                        if (idx == _sessions.length) {
                          _pageIndex += 1;
                          _fetchSessions();
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircularProgressIndicator(color: Colors.deepPurple.shade400),
                            ),
                          );
                        }
                        final s = _sessions[idx];
                        return _buildSessionCard(s);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Nút tạo phiên mới
            Positioned(
              right: 24,
              bottom: 32,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF502484),
                elevation: 12,
                onPressed: _openCreateModal,
                child: const Icon(Icons.add, size: 28, color: Colors.white),
              ),
            ),

            // Modal tạo phiên mới
            if (_modalVisible) ...[
              GestureDetector(
                onTap: _closeCreateModal,
                child: Container(
                  color: Colors.black.withOpacity(0.42),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: width - 40,
                      constraints: const BoxConstraints(maxWidth: 400),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 22, offset: Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Text('Tạo cuộc trò chuyện mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF502484))),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: _closeCreateModal),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            enableIMEPersonalizedLearning: true,
                            decoration: InputDecoration(
                              hintText: "Nhập tên cuộc trò chuyện (tùy chọn)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            autofocus: true,
                            onChanged: (val) => setState(() => _sessionName = val),
                          ),
                          const SizedBox(height: 8),
                          const Text("Nếu bỏ trống, hệ thống sẽ tự động tạo tên cho bạn", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: _closeCreateModal,
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey.shade100,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: const Text("Huỷ", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _createLoading ? null : _handleCreateSession,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF502484),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  child: _createLoading
                                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.8, color: Colors.white))
                                      : const Text("Tạo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(ChatSession s) {
    return GestureDetector(
      onTap: () => _goToDetail(s),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x11502484), blurRadius: 12, offset: Offset(0, 4)),
          ],
          border: Border.all(color: const Color(0xFFF3F0FF), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF502484), width: 2),
              ),
              margin: const EdgeInsets.only(right: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset('assets/images/emo.jpg', width: 36, height: 36, fit: BoxFit.cover),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.sessionName.isNotEmpty ? s.sessionName : "Đoạn chat mới",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17, color: Color(0xFF1A0536)),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text(_formatDate(s.createdAt), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
              onPressed: _deleteLoading ? null : () => _handleDeleteSession(s.id, s.sessionName),
              tooltip: "Xoá phiên chat",
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF502484), size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(double height) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: height * 0.85,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(color: const Color(0xFF502484), width: 3),
                boxShadow: const [BoxShadow(color: Color(0x22502484), blurRadius: 20, offset: Offset(0, 8))],
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Image.asset('assets/images/emo.jpg', width: 80, height: 80, fit: BoxFit.cover),
              ),
            ),
            const Text('Chào mừng đến với Emo Chat!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF502484))),
            const SizedBox(height: 8),
            const Text(
              "Bắt đầu cuộc trò chuyện đầu tiên với AI Emo để chia sẻ cảm xúc và nhận được hỗ trợ tâm lý",
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)), textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _openCreateModal,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text("Tạo cuộc trò chuyện đầu tiên", style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF502484),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 5,
                shadowColor: const Color(0xFF502484),
              ),
            )
          ],
        ),
      ),
    );
  }
}
