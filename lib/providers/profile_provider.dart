import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  static const _storageKey = 'user_profile_v1';

  UserProfile get profile => _profile;

  ProfileProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      _profile = UserProfile.fromJson(jsonDecode(raw));
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(_profile.toJson()));
  }

  void updateProfile(UserProfile updated) {
    _profile = updated;
    _save();
    notifyListeners();
  }

  void updateName(String name) {
    _profile.name = name;
    _save();
    notifyListeners();
  }

  void updateEmail(String email) {
    _profile.email = email;
    _save();
    notifyListeners();
  }

  void updateHeadline(String headline) {
    _profile.headline = headline;
    _save();
    notifyListeners();
  }

  void updateSkills(List<String> skills) {
    _profile.skills = skills;
    _save();
    notifyListeners();
  }

  void addSkill(String skill) {
    if (!_profile.skills.contains(skill)) {
      _profile.skills = [..._profile.skills, skill];
      _save();
      notifyListeners();
    }
  }

  void removeSkill(String skill) {
    _profile.skills = _profile.skills.where((s) => s != skill).toList();
    _save();
    notifyListeners();
  }

  void updateExperience(String experience) {
    _profile.experience = experience;
    _save();
    notifyListeners();
  }

  void updateEducation(String education) {
    _profile.education = education;
    _save();
    notifyListeners();
  }

  void updatePreferredRole(String role) {
    _profile.preferredRole = role;
    _save();
    notifyListeners();
  }

  void updatePreferredLocation(String location) {
    _profile.preferredLocation = location;
    _save();
    notifyListeners();
  }

  void updateResumeSummary(String summary) {
    _profile.resumeSummary = summary;
    _save();
    notifyListeners();
  }

  void updatePreferredCategory(String category) {
    _profile.preferredCategory = category;
    _save();
    notifyListeners();
  }
}
