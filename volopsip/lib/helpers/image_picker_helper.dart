import 'package:file_picker/file_picker.dart';

Future<String?> pickImageFromDevice() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );

  if (result == null || result.files.single.path == null) return null;

  return result.files.single.path!;
}