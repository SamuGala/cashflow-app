import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final receiptStorageServiceProvider = Provider<ReceiptStorageService>((ref) {
  return ReceiptStorageService();
});

class ReceiptStorageService {
  final ImagePicker _picker;
  final Uuid _uuid;

  ReceiptStorageService({ImagePicker? picker, Uuid? uuid})
    : _picker = picker ?? ImagePicker(),
      _uuid = uuid ?? const Uuid();

  Future<String?> capture() => _pick(ImageSource.camera);

  Future<String?> chooseFromLibrary() => _pick(ImageSource.gallery);

  Future<String?> _pick(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 88,
      maxWidth: 2400,
      requestFullMetadata: false,
    );
    if (image == null) return null;
    return storeFile(image.path);
  }

  /// Copies a camera or gallery file into the app's private receipt archive.
  /// The source can safely be a temporary file owned by a platform plugin.
  Future<String> storeFile(String sourcePath) async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(root.path, 'receipts'));
    await directory.create(recursive: true);
    final extension = p.extension(sourcePath).toLowerCase();
    final destination = File(
      p.join(
        directory.path,
        '${_uuid.v4()}${extension.isEmpty ? '.jpg' : extension}',
      ),
    );
    await File(sourcePath).copy(destination.path);
    return destination.path;
  }

  Future<void> remove(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
