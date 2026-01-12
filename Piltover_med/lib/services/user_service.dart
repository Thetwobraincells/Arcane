
import 'package:flutter/foundation.dart';

class UserProfile {
  final String name;
  final int age;
  final String sex; // 'male', 'female', 'other'

  UserProfile({
    required this.name,
    required this.age,
    required this.sex,
  });
}

class UserService extends ChangeNotifier {
  // Hardcoded for now as per requirements
  UserProfile _currentUser = UserProfile(
    name: 'Jinx', // Keeping with the Arcane theme
    age: 25,
    sex: 'female',
  );

  UserProfile get currentUser => _currentUser;

  void updateUser(UserProfile newProfile) {
    _currentUser = newProfile;
    notifyListeners();
  }
}
