class PickedImageFile {
  const PickedImageFile({required this.fileName, required this.previewUrl});

  final String fileName;
  final String previewUrl;
}

Future<PickedImageFile?> pickImageFile() async {
  return null;
}

Future<List<PickedImageFile>> pickImageFiles() async {
  return const [];
}
