import 'package:image_picker/image_picker.dart';
import 'package:riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, String?>((ref) {
  return ProfileNotifier();
});

class ProfileNotifier extends StateNotifier<String?> {
  ProfileNotifier() : super(null);

  Future<void> load(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('profile_pic_$userId');
  }

  Future<void> pickProfilePicture(int userId) async {
    final picture = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picture == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_pic_$userId', picture.path);
    state = picture.path;
  }

  void clear() => state = null;
}
