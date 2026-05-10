import 'dart:async';
import 'dart:html' as html;

class PickedImageFile {
  const PickedImageFile({required this.fileName, required this.previewUrl});

  final String fileName;
  final String previewUrl;
}

Future<PickedImageFile?> pickImageFile() {
  final completer = Completer<PickedImageFile?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.onLoadEnd.first.then((_) {
      final previewUrl = reader.result?.toString();
      if (previewUrl == null || previewUrl.isEmpty) {
        completer.complete(null);
        return;
      }

      completer.complete(
        PickedImageFile(fileName: file.name, previewUrl: previewUrl),
      );
    });
    reader.readAsDataUrl(file);
  });

  input.click();
  return completer.future;
}

Future<List<PickedImageFile>> pickImageFiles() {
  final completer = Completer<List<PickedImageFile>>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = true;

  input.onChange.first.then((_) async {
    final files = input.files;
    if (files == null || files.isEmpty) {
      completer.complete(const []);
      return;
    }

    final picked = <PickedImageFile>[];
    for (var index = 0; index < files.length; index += 1) {
      final file = files[index];
      final previewUrl = await _readAsDataUrl(file);
      if (previewUrl == null || previewUrl.isEmpty) {
        continue;
      }
      picked.add(PickedImageFile(fileName: file.name, previewUrl: previewUrl));
    }

    completer.complete(picked);
  });

  input.click();
  return completer.future;
}

Future<String?> _readAsDataUrl(html.File file) {
  final completer = Completer<String?>();
  final reader = html.FileReader();
  reader.onLoadEnd.first.then((_) {
    completer.complete(reader.result?.toString());
  });
  reader.readAsDataUrl(file);
  return completer.future;
}
