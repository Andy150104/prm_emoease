// lib/models/question.dart
class Option {
  final String id;
  final String content;

  Option({
    required this.id,
    required this.content,
  });
}

class Question {
  final String id;
  final String content;
  final List<Option> options;

  Question({
    required this.id,
    required this.content,
    required this.options,
  });
}
