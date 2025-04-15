import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final List<String> options;
  final String correctAnswer;

  Question({
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();
    
    final questionText = unescape.convert(json['question'] as String);
    final correctAnswerText = unescape.convert(json['correct_answer'] as String);
    
    List<String> options = (json['incorrect_answers'] as List)
        .map((answer) => unescape.convert(answer as String))
        .toList();
    
    options.add(correctAnswerText);
    options.shuffle();

    return Question(
      question: questionText,
      options: options,
      correctAnswer: correctAnswerText,
    );
  }
}