import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/database_helper.dart';

final profileProvider = AsyncNotifierProvider<ProfileNotifier, String?>(
  ProfileNotifier.new,
);

class ProfileNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null; // loaded explicitly via load()

  /// Called after login/session restore to fetch the stored path from the DB.
  Future<void> load(int userId) async {
    state = const AsyncLoading();
    state = AsyncData(await DatabaseHelper.instance.getProfilePic(userId));
  }

  //picks an image from the gallery, copies it to the app directory, saves the path to the DB, and updates state.
  Future<void> pickProfilePicture(int userId) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    //copy from OS temp/cache to permanent storage so the path survives
    //app restarts and OS cache clears.
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = 'profile_$userId.jpg';
    final savedPath = p.join(appDir.path, fileName);
    await File(picked.path).copy(savedPath);

    await DatabaseHelper.instance.saveProfilePic(userId, savedPath);
    state = AsyncData(savedPath);
  }

  void clear() => state = const AsyncData(null);
}
