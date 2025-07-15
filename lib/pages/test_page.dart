import 'package:flutter/material.dart';
import 'package:pe_emoease_mobileapp_flutter/pages/result_page.dart';
import '../models/question.dart';
import '../models/test_result.dart';
import '../services/question_service.dart';
import '../services/test_service.dart';

class TestPage extends StatefulWidget {
  final String? testName;
  const TestPage({Key? key, this.testName}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> with TickerProviderStateMixin {
  final MaterialColor purple = Colors.deepPurple;
  final String _testId = '8fc88dbb-daee-4b17-9eca-de6cfe886097';
  late final QuestionService _qService;
  late final TestService _tService;

  List<Question> _questions = [];
  List<int?> _answers = [];
  bool _loading = true;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _qService = QuestionService();
    _tService = TestService();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final qs = await _qService.fetchQuestions(_testId);
      setState(() {
        _questions = qs;
        _answers = List<int?>.filled(qs.length, null);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Load câu hỏi thất bại: \$e')),
      );
    }
  }

  void _next() {
    if (_answers[_current] == null) return;
    if (_current < _questions.length - 1) {
      setState(() => _current++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_current > 0) {
      setState(() => _current--);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _submit() async {
    final selectedIds = <String>[];
    for (var i = 0; i < _answers.length; i++) {
      final idx = _answers[i];
      if (idx != null) {
        selectedIds.add(_questions[i].options[idx].id);
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await _tService.submitTestResult(
        testId: _testId,
        selectedOptionIds: selectedIds,
      );
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ResultPage(testResult: result),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Lỗi'),
          content: Text('Không gửi được kết quả: \$e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.testName ?? 'Đánh giá DASS-21';

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Không có câu hỏi')),
      );
    }

    final total = _questions.length;
    final progressValue = (_current + 1) / total;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF3E5F5), Color(0xFFD1C4E9)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: progressValue),
                      duration: const Duration(milliseconds: 400),
                      builder: (context, value, child) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Color(0xFFCE93D8)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_current + 1}/\$total',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  layoutBuilder: (currentChild, previousChildren) {
                    return Stack(
                      alignment: Alignment.center,
                      children: <Widget>[...previousChildren, if (currentChild != null) currentChild],
                    );
                  },
                  child: Card(
                    key: ValueKey<int>(_current),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Câu ${_current + 1}',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: purple.shade700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _questions[_current].content,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            const SizedBox(height: 20),
                            ...List.generate(
                              _questions[_current].options.length,
                                  (i) {
                                final selected = _answers[_current] == i;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => setState(() => _answers[_current] = i),
                                    borderRadius: BorderRadius.circular(12),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      decoration: BoxDecoration(
                                        color: selected ? const Color(0xFFE1BEE7) : Colors.white,
                                        border: Border.all(
                                          color: selected ? const Color(0xFFAB47BC) : Colors.grey.shade300,
                                          width: selected ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: selected ? const Color(0xFF8E24AA) : Colors.grey.shade300,
                                            child: Text(
                                              String.fromCharCode(65 + i),
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(child: Text(_questions[_current].options[i].content)),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _current > 0 ? _back : null,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('← Quay lại', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _answers[_current] != null ? _next : null,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        elevation: 4,
                        shadowColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(_current < total - 1 ? 'Tiếp theo →' : 'Hoàn thành'),
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
