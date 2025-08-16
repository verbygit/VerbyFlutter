// import 'package:flutter/foundation.dart';
// import '../dao/question_dao.dart';
// import '../data_source/local/database_helper.dart';
//
// class QuestionRepositoryImpl extends QuestionRepository {
//   final QuestionDao _questionDao;
//
//   QuestionRepositoryImpl(this._questionDao);
//
//   @override
//   Future<void> storeQuestions(List<Question> questions) async {
//     try {
//       for (final question in questions) {
//         QuestionModel questionModel = QuestionModel.copy(question);
//         await _questionDao.insertQuestion(questionModel);
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }
//
//   @override
//   Future<List<Question>> getQuestion({
//     bool isPPAndPS = false,
//     bool isPPAndNS = false,
//     bool isNPAndPS = false,
//     bool isNPAndNS = false,
//     bool isComplete = false,
//   }) async {
//     return await _questionDao.getAllQuestions(
//         isPPAndPS: isPPAndPS,
//         isPPAndNS: isPPAndNS,
//         isNPAndPS: isNPAndPS,
//         isNPAndNS: isNPAndNS,
//         isComplete: isComplete);
//   }
//
//   @override
//   Future<void> updateQuestion(Question question) async {
//     await _questionDao.updateQuestion(question);
//   }
//
//   @override
//   Future<bool> checkIfIsPPAndPSExists() {
//     return _questionDao.checkIfIsPPAndPSExists();
//   }
//
//   @override
//   Future<bool> checkIfIsPPAndNSExists() {
//     return _questionDao.checkIfIsPPAndNSExists();
//   }
//
//   @override
//   Future<bool> checkIfIsNPAndPSExists() {
//     return _questionDao.checkIfIsNPAndPSExists();
//   }
//
//   @override
//   Future<bool> checkIfIsNPAndNSExists() {
//     return _questionDao.checkIfIsNPAndNSExists();
//   }
//
//   @override
//   Future<void> deleteQuestions(
//       {bool isPPAndPS = false,
//       bool isPPAndNS = false,
//       bool isNPAndPS = false,
//       bool isNPAndNS = false,
//       bool isComplete = true}) async {
//     await _questionDao.deleteEntry(
//       isPPAndPS: isPPAndPS,
//       isPPAndNS: isPPAndNS,
//       isNPAndPS: isNPAndPS,
//       isNPAndNS: isNPAndNS,
//     );
//   }
//
//   @override
//   Future<bool> deleteDatabase() async {
//     return await _questionDao.deleteAppDatabase();
//   }
// }
