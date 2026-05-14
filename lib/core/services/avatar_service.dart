import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AvatarService {
  static final AvatarService _instance = AvatarService._();
  static AvatarService get instance => _instance;

  AvatarService._();

  final ImagePicker _picker = ImagePicker();
  static const String _bucketName = 'avatars';

  /// Selecciona avatar — funciona en web y móvil via image_picker
  Future<XFile?> pickAvatar({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? result = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      return result;
    } catch (e) {
      debugPrint('[AvatarService] Error picking avatar: $e');
      return null;
    }
  }

  /// Sube el avatar a Supabase Storage
  Future<String?> uploadAvatar(XFile imageFile) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        debugPrint('[AvatarService] No user logged in');
        return null;
      }

      final userId = user.id;
      final extension = imageFile.name.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      final ext = validExtensions.contains(extension) ? extension : 'jpg';

      const mimeTypes = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
      };
      final contentType = mimeTypes[ext] ?? 'image/jpeg';

      final path = '$userId/avatar.$ext';
      final bucket = Supabase.instance.client.storage.from(_bucketName);
      final bytes = await imageFile.readAsBytes();

      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(
          contentType: contentType,
          upsert: true,
        ),
      );

      final rawUrl = bucket.getPublicUrl(path);
      final publicUrl = '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      debugPrint('[AvatarService] Avatar subido: $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('[AvatarService] Error uploading avatar: $e');
      return null;
    }
  }

  /// Actualiza la URL del avatar en la tabla users
  Future<String?> updateUserAvatarUrl(String avatarUrl) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return null;

      await Supabase.instance.client
          .from('users')
          .update({'avatarUrl': avatarUrl})
          .eq('id', user.id);

      return avatarUrl;
    } catch (e) {
      debugPrint('[AvatarService] Error updating avatarUrl: $e');
      return null;
    }
  }

  /// Elimina el avatar de storage y limpia la URL en BD
  Future<bool> deleteAvatar() async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) return false;

      final userId = user.id;
      final bucket = Supabase.instance.client.storage.from(_bucketName);

      await bucket.remove([
        '$userId/avatar.jpg',
        '$userId/avatar.jpeg',
        '$userId/avatar.png',
        '$userId/avatar.webp',
      ]).catchError((_) => <FileObject>[]);

      await Supabase.instance.client
          .from('users')
          .update({'avatarUrl': ''})
          .eq('id', userId);

      return true;
    } catch (e) {
      debugPrint('[AvatarService] Error deleting avatar: $e');
      return false;
    }
  }
}
