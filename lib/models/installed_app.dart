import 'dart:typed_data';

/// Represents an application installed on the host Android device (or realistic mock apps).
class InstalledApp {
  final String name;
  final String packageName;
  final Uint8List? iconBytes;
  bool isSelected;

  InstalledApp({
    required this.name,
    required this.packageName,
    this.iconBytes,
    this.isSelected = false,
  });

  InstalledApp copyWith({
    String? name,
    String? packageName,
    Uint8List? iconBytes,
    bool? isSelected,
  }) {
    return InstalledApp(
      name: name ?? this.name,
      packageName: packageName ?? this.packageName,
      iconBytes: iconBytes ?? this.iconBytes,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
