class PhotoData {
  const PhotoData({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final int width;
  final int height;

  PhotoData copyWith({
    String? path,
    int? width,
    int? height,
  }) {
    return PhotoData(
      path: path ?? this.path,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'width': width,
      'height': height,
    };
  }

  factory PhotoData.fromMap(Map<String, dynamic> map) {
    return PhotoData(
      path: map['path'] as String? ?? '',
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
    );
  }
}

