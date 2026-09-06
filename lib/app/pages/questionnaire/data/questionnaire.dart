import 'package:jupyter_health/domain/entity/questionnaire/question.dart';


//TODO fetch questionnaire from backend
List<Question> questionnaire = [
  Question.optionalMultipleChoice(
    id: '1',
    question:
        'Family History: Did any of your parents have these health problems?',
    answers: [
      'Cancer',
      'Heart Failure',
      'Heart Attack',
      'Hypertension',
      'Diabetes',
      'Kidney Disease',
    ],
  ),
  Question.optionalMultipleChoice(
    id: '2',
    question: 'Habits',
    answers: ['Smoking', 'Vaping', 'Alcohol use'],
  ),
  Question.optionalText(
    id: '3',
    question: 'Is there anything else you would like to tell us?',
    description:
        'If there\'s anything you think might be helpful, let us know. Otherwise, you can skip this question.',
  ),
];
