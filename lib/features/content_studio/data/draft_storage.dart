import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'content_models.dart';

/// Storage service for drafts using SharedPreferences
class DraftStorage {
  static const String _key = 'content_drafts';
  static SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Save a draft
  static Future<bool> saveDraft(ContentDraft draft) async {
    try {
      final drafts = await loadAllDrafts();

      // Check if draft exists, update it
      final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
      if (existingIndex >= 0) {
        drafts[existingIndex] = draft;
      } else {
        drafts.insert(0, draft); // Add new draft at the beginning
      }

      return await _saveDrafts(drafts);
    } catch (e) {
      return false;
    }
  }

  /// Load all drafts
  static Future<List<ContentDraft>> loadAllDrafts() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_key);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => ContentDraft.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Load drafts by mode
  static Future<List<ContentDraft>> loadDraftsByMode(ContentMode mode) async {
    final drafts = await loadAllDrafts();
    return drafts.where((d) => d.mode == mode).toList();
  }

  /// Delete a draft
  static Future<bool> deleteDraft(String draftId) async {
    try {
      final drafts = await loadAllDrafts();
      drafts.removeWhere((d) => d.id == draftId);
      return await _saveDrafts(drafts);
    } catch (e) {
      return false;
    }
  }

  /// Delete all drafts
  static Future<bool> deleteAllDrafts() async {
    try {
      final prefs = await _preferences;
      return await prefs.remove(_key);
    } catch (e) {
      return false;
    }
  }

  /// Get draft count
  static Future<int> getDraftCount() async {
    final drafts = await loadAllDrafts();
    return drafts.length;
  }

  /// Save drafts list
  static Future<bool> _saveDrafts(List<ContentDraft> drafts) async {
    try {
      final prefs = await _preferences;
      final jsonList = drafts.map((d) => d.toJson()).toList();
      return await prefs.setString(_key, jsonEncode(jsonList));
    } catch (e) {
      return false;
    }
  }

  /// Search drafts
  static Future<List<ContentDraft>> searchDrafts(String query) async {
    if (query.isEmpty) return loadAllDrafts();

    final drafts = await loadAllDrafts();
    final lowerQuery = query.toLowerCase();

    return drafts.where((draft) {
      return draft.promptText.toLowerCase().contains(lowerQuery) ||
          (draft.caption?.toLowerCase().contains(lowerQuery) ?? false) ||
          draft.hashtags.any((h) => h.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}
