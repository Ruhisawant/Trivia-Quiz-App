import 'package:flutter/material.dart';
import 'question.dart';
import 'api_service.dart';
import 'package:confetti/confetti.dart'; 

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _loading = true;
  bool _answered = false;
  String _selectedAnswer = "";
  String _feedbackText = "";
  late ConfettiController confetti; 

  @override
  void initState() {
    super.initState();
    confetti = ConfettiController(duration: const Duration(seconds: 2)); 
    _loadQuestions();
  }

  @override
  void dispose(){
    confetti.dispose();
    super.dispose(); 
  }

  Future<void> _loadQuestions() async {
    try {
      final questions = await ApiService.fetchQuestions();
      setState(() {
        _questions = questions;
        _loading = false;
      });
    } catch (e) {
      print('Failed to load questions: $e');
    }
  }

  void _submitAnswer(String selectedAnswer) {
    setState(() {
      _answered = true;
      _selectedAnswer = selectedAnswer;
      final correctAnswer = _questions[_currentQuestionIndex].correctAnswer;

      if (selectedAnswer == correctAnswer) {
        _score++;
        _feedbackText = "Correct! The answer is $correctAnswer.";
      } else {
        _feedbackText = "Incorrect. The correct answer is $correctAnswer.";
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _answered = false;
      _selectedAnswer = "";
      _feedbackText = "";
      _currentQuestionIndex++;
    });
  }

  Widget _buildOptionButton(String option) {
    return ElevatedButton(
      onPressed: _answered ? null : () => _submitAnswer(option),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
      ),
      child: Text(option),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentQuestionIndex >= _questions.length) {
      final percentage = (_score / _questions.length) * 100;
      if (percentage >= 70){
        confetti.play(); 
      }

      return Scaffold(
        body: Stack(
          alignment: Alignment.center, 
          children: [
            Center(
              child: Text(
                'Quiz Finished! Your Score: $_score/${_questions.length}', 
                style: TextStyle(fontSize: 20), 
              ),
            ),
            Align(
              alignment: Alignment.topCenter, 
              child: ConfettiWidget(
                confettiController: confetti, 
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false, 
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple], 
              ),
            ),
          ],
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(title: Text('Quiz App')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Question ${_currentQuestionIndex + 1}/${_questions.length}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 16),
            Text(
              question.question,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            ...question.options.map((option) => _buildOptionButton(option)),
            SizedBox(height: 20),
            if (_answered)
              Text(
                _feedbackText,
                style: TextStyle(
                  fontSize: 16,
                  color: _selectedAnswer == question.correctAnswer
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text('Next Question'),
              ),
          ],
        ),
      ),
    );
  }
}
