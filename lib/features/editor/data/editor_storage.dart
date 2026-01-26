import 'dart:convert';
import '../../content_studio/data/content_models.dart';
import '../../content_studio/data/draft_storage.dart';
import 'editor_models.dart';

class EditorStorage {
  /// Save editor project as a Draft
  static Future<bool> saveEditorProject(
    EditorProjectState state, {
    String? id,
  }) async {
    try {
      final String projectJson = jsonEncode(state.toJson());

      final draft = ContentDraft(
        id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        mode: ContentMode.image, // Editor predominantly creates images
        platforms: [SocialPlatform.instagram, SocialPlatform.facebook],
        promptText:
            'Visual Edit: ${DateTime.now().hour}:${DateTime.now().minute}',
        caption: 'Edited visual post',
        extraData: projectJson, // Store the editor layers here
      );

      return await DraftStorage.saveDraft(draft);
    } catch (e) {
      return false;
    }
  }

  /// Load editor project from a Draft
  static EditorProjectState? loadProjectFromDraft(ContentDraft draft) {
    if (draft.extraData == null) return null;
    try {
      final Map<String, dynamic> json = jsonDecode(draft.extraData!);
      return EditorProjectState.fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
