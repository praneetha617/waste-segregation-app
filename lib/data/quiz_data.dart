import '../models/quiz_question.dart';

final wetWasteQuestions = [
  QuizQuestion(
    question: "Which of these is considered wet/organic waste?",
    options: ["Plastic Bottle", "Banana Peel", "Battery", "Newspaper"],
    correctIndex: 1,
    explanations: [
      "Plastic bottles are dry/recyclable waste.",
      "Correct! Banana peels are wet/organic waste.",
      "Batteries are hazardous waste.",
      "Newspapers are dry/recyclable waste.",
    ],
  ),
  QuizQuestion(
    question: "Where should vegetable peels go?",
    options: [
      "Green bin",
      "Blue bin",
      "Red bin",
      "Black bin"
      
    ],
    correctIndex: 0,
    explanations: [
      "Correct! Vegetable peels belong in the green bin.",
      "Blue bin is for dry/recyclable waste.",
      "Red bin is for hazardous waste.",
      "Black bin is not typically used in standard segregation.",
    ],
  ),
];

final dryWasteQuestions = [
  QuizQuestion(
    question: "Which item should go in the dry/recyclable waste bin?",
    options: ["Apple core", "Plastic bottle", "Used tissue", "Nail polish bottle"],
    correctIndex: 1,
    explanations: [
      "Apple cores are wet/organic waste.",
      "Correct! Plastic bottles are dry/recyclable waste.",
      "Used tissues are wet/organic waste.",
      "Nail polish bottles are hazardous waste.",
    ],
  ),
  QuizQuestion(
    question: "Where should you throw old newspapers?",
    options: [
      "Green bin",
      "Blue bin",
      "Red bin",
      "Yellow bin"
    ],
    correctIndex: 1,
    explanations: [
      "Green bin is for wet/organic waste.",
      "Correct! Blue bin is for dry/recyclable waste like newspapers.",
      "Red bin is for hazardous waste.",
      "Yellow bin is not typically used in standard segregation.",
    ],
  ),
];

final hazardousWasteQuestions = [
  QuizQuestion(
    question: "Which of these is hazardous waste?",
    options: ["Banana Peel", "Nail polish bottle", "Vegetable Skin", "Newspaper"],
    correctIndex: 1,
    explanations: [
      "Banana peels are wet/organic waste.",
      "Correct! Nail polish bottles are hazardous waste.",
      "Vegetable skins are wet/organic waste.",
      "Newspapers are dry/recyclable waste.",
    ],
  ),
  QuizQuestion(
    question: "Where should you throw used batteries?",
    options: [
      "Green bin",
      "Blue bin",
      "Red bin",
      "pink bin"
    ],
    correctIndex: 2,
    explanations: [
      "Green bin is for wet/organic waste.",
      "Blue bin is for dry/recyclable waste.",
      "Correct! Red bin is for hazardous waste like batteries.",
      "pink bin is typically used in standard segregation.",
    ],
  ),
];
