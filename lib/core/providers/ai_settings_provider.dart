import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiSettings {
  final bool accessTasks;
  final bool accessCalendar;
  final bool accessGroups;
  final bool voiceResponses;
  final bool proactiveSuggestions;
  final int toneIndex; // 0=Formal, 1=Amigable, 2=Motivacional

  const AiSettings({
    this.accessTasks = true,
    this.accessCalendar = true,
    this.accessGroups = true,
    this.voiceResponses = false,
    this.proactiveSuggestions = true,
    this.toneIndex = 1,
  });

  AiSettings copyWith({
    bool? accessTasks,
    bool? accessCalendar,
    bool? accessGroups,
    bool? voiceResponses,
    bool? proactiveSuggestions,
    int? toneIndex,
  }) =>
      AiSettings(
        accessTasks: accessTasks ?? this.accessTasks,
        accessCalendar: accessCalendar ?? this.accessCalendar,
        accessGroups: accessGroups ?? this.accessGroups,
        voiceResponses: voiceResponses ?? this.voiceResponses,
        proactiveSuggestions: proactiveSuggestions ?? this.proactiveSuggestions,
        toneIndex: toneIndex ?? this.toneIndex,
      );

  static const _kAccessTasks = 'ai_access_tasks';
  static const _kAccessCalendar = 'ai_access_calendar';
  static const _kAccessGroups = 'ai_access_groups';
  static const _kVoiceResponses = 'ai_voice_responses';
  static const _kProactiveSuggestions = 'ai_proactive_suggestions';
  static const _kToneIndex = 'ai_tone_index';

  static Future<AiSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AiSettings(
      accessTasks: prefs.getBool(_kAccessTasks) ?? true,
      accessCalendar: prefs.getBool(_kAccessCalendar) ?? true,
      accessGroups: prefs.getBool(_kAccessGroups) ?? true,
      voiceResponses: prefs.getBool(_kVoiceResponses) ?? false,
      proactiveSuggestions: prefs.getBool(_kProactiveSuggestions) ?? true,
      toneIndex: prefs.getInt(_kToneIndex) ?? 1,
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAccessTasks, accessTasks);
    await prefs.setBool(_kAccessCalendar, accessCalendar);
    await prefs.setBool(_kAccessGroups, accessGroups);
    await prefs.setBool(_kVoiceResponses, voiceResponses);
    await prefs.setBool(_kProactiveSuggestions, proactiveSuggestions);
    await prefs.setInt(_kToneIndex, toneIndex);
  }
}

class AiSettingsNotifier extends AsyncNotifier<AiSettings> {
  @override
  Future<AiSettings> build() => AiSettings.load();

  Future<void> save(AiSettings updated) async {
    await updated.save();
    state = AsyncData(updated);
  }
}

final aiSettingsProvider =
    AsyncNotifierProvider<AiSettingsNotifier, AiSettings>(
  AiSettingsNotifier.new,
);
