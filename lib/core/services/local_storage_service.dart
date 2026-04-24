import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception(
          'LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  static const String usersKey = 'local_users';
  static const String currentUserKey = 'current_user';
  static const String tasksKey = 'local_tasks';
  static const String coursesKey = 'local_courses';
  static const String eventsKey = 'local_events';
  static const String groupsKey = 'local_groups';
  static const String chatMessagesKey = 'local_chat_messages';
  static const String streakKey = 'user_streak';
  static const String statisticsKey = 'user_statistics';
  static const String categoriesKey = 'local_categories';
  static const String onboardingKey = 'onboarding_completed';
  static const String notesKey = 'local_notes';

  static Future<void> setString(String key, String value) async {
    await _instance.setString(key, value);
  }

  static String? getString(String key) {
    return _instance.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _instance.setBool(key, value);
  }

  static bool getBool(String key) {
    return _instance.getBool(key) ?? false;
  }

  static Future<void> setInt(String key, int value) async {
    await _instance.setInt(key, value);
  }

  static int getInt(String key) {
    return _instance.getInt(key) ?? 0;
  }

  static Future<void> setJson(String key, dynamic data) async {
    await _instance.setString(key, jsonEncode(data));
  }

  static dynamic getJson(String key) {
    final str = _instance.getString(key);
    if (str == null) return null;
    try {
      return jsonDecode(str);
    } catch (_) {
      return null;
    }
  }

  static Future<void> setList(
      String key, List<Map<String, dynamic>> list) async {
    await _instance.setString(key, jsonEncode(list));
  }

  static List<Map<String, dynamic>> getList(String key) {
    final str = _instance.getString(key);
    if (str == null) return [];
    try {
      final decoded = jsonDecode(str) as List;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<void> remove(String key) async {
    await _instance.remove(key);
  }

  static Future<void> clear() async {
    await _instance.clear();
  }

  static bool get onboardingCompleted => getBool(onboardingKey);
  static Future<void> setOnboardingCompleted(bool value) =>
      setBool(onboardingKey, value);

  static int get userStreak => getInt(streakKey);
  static Future<void> setUserStreak(int value) => setInt(streakKey, value);

  static Map<String, dynamic>? get userStatistics {
    final str = getString(statisticsKey);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setUserStatistics(Map<String, dynamic> stats) async {
    await setString(statisticsKey, jsonEncode(stats));
  }

  static Map<String, dynamic>? get currentUserData {
    final str = getString(currentUserKey);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> setCurrentUserData(Map<String, dynamic> user) async {
    await setString(currentUserKey, jsonEncode(user));
  }

  static Future<void> clearCurrentUser() async {
    await remove(currentUserKey);
  }

  static List<Map<String, dynamic>> get users {
    return getList(usersKey);
  }

  static Future<void> addUser(Map<String, dynamic> user) async {
    final list = users;
    list.add(user);
    await setList(usersKey, list);
  }

  static Map<String, dynamic>? findUserByEmail(String email) {
    final list = users;
    for (final user in list) {
      if (user['email']?.toString().toLowerCase() == email.toLowerCase()) {
        return user;
      }
    }
    return null;
  }

  static List<Map<String, dynamic>> get tasks {
    return getList(tasksKey);
  }

  static Future<void> addTask(Map<String, dynamic> task) async {
    final list = tasks;
    list.insert(0, task);
    await setList(tasksKey, list);
  }

  static Future<void> updateTask(String id, Map<String, dynamic> task) async {
    final list = tasks;
    final index = list.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      list[index] = task;
      await setList(tasksKey, list);
    }
  }

  static Future<void> deleteTask(String id) async {
    final list = tasks;
    list.removeWhere((t) => t['id'] == id);
    await setList(tasksKey, list);
  }

  static List<Map<String, dynamic>> get courses {
    return getList(coursesKey);
  }

  static Future<void> setCourses(List<Map<String, dynamic>> courseList) async {
    await setList(coursesKey, courseList);
  }

  static List<Map<String, dynamic>> get events {
    return getList(eventsKey);
  }

  static Future<void> addEvent(Map<String, dynamic> event) async {
    final list = events;
    list.insert(0, event);
    await setList(eventsKey, list);
  }

  static Future<void> updateEvent(String id, Map<String, dynamic> event) async {
    final list = events;
    final index = list.indexWhere((e) => e['id'] == id);
    if (index != -1) {
      list[index] = event;
      await setList(eventsKey, list);
    }
  }

  static Future<void> deleteEvent(String id) async {
    final list = events;
    list.removeWhere((e) => e['id'] == id);
    await setList(eventsKey, list);
  }

  static List<Map<String, dynamic>> get groups {
    return getList(groupsKey);
  }

  static Future<void> setGroups(List<Map<String, dynamic>> groupList) async {
    await setList(groupsKey, groupList);
  }

  static List<Map<String, dynamic>> get categories {
    return getList(categoriesKey);
  }

  static Future<void> addCategory(Map<String, dynamic> category) async {
    final list = categories;
    list.add(category);
    await setList(categoriesKey, list);
  }

  static Future<void> updateCategory(
      String id, Map<String, dynamic> category) async {
    final list = categories;
    final index = list.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      list[index] = category;
      await setList(categoriesKey, list);
    }
  }

  static Future<void> deleteCategory(String id) async {
    final list = categories;
    list.removeWhere((c) => c['id'] == id);
    await setList(categoriesKey, list);
  }

  static List<Map<String, dynamic>> getCategoriesByUserId(String userId) {
    final list = categories;
    return list.where((c) => c['user_id'] == userId).toList();
  }

  static List<Map<String, dynamic>> get chatMessages {
    return getList(chatMessagesKey);
  }

  static Future<void> addChatMessage(Map<String, dynamic> message) async {
    final list = chatMessages;
    list.add(message);
    await setList(chatMessagesKey, list);
  }

  static Future<void> clearChatMessages() async {
    await remove(chatMessagesKey);
  }

  // ── Notes ─────────────────────────────────────────────────────────────────

  static List<Map<String, dynamic>> get notes {
    return getList(notesKey);
  }

  static Future<void> addNote(Map<String, dynamic> note) async {
    final list = notes;
    list.insert(0, note);
    await setList(notesKey, list);
  }

  static Future<void> updateNote(String id, Map<String, dynamic> note) async {
    final list = notes;
    final index = list.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      list[index] = note;
      await setList(notesKey, list);
    }
  }

  static Future<void> deleteNote(String id) async {
    final list = notes;
    list.removeWhere((n) => n['id'] == id);
    await setList(notesKey, list);
  }
}
