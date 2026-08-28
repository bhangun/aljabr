enum AttachmentType {
  image,
  audio,
  video,
  file,
  code,
  link,
}

enum AttachmentStatus {
  uploading,
  uploaded,
  processing,
  ready,
  failed,
}

class Attachment {
  final String id;
  final String name;
  final AttachmentType type;
  final String? url;
  final String? localPath;
  final int size;
  final String? mimeType;
  final AttachmentStatus status;
  final String? thumbnailUrl;
  final Duration? duration; // For audio/video
  final Map<String, dynamic>? metadata;
  final String? errorMessage;

  const Attachment({
    required this.id,
    required this.name,
    required this.type,
    this.url,
    this.localPath,
    required this.size,
    this.mimeType,
    this.status = AttachmentStatus.uploading,
    this.thumbnailUrl,
    this.duration,
    this.metadata,
    this.errorMessage,
  });

  Attachment copyWith({
    String? id,
    String? name,
    AttachmentType? type,
    String? url,
    String? localPath,
    int? size,
    String? mimeType,
    AttachmentStatus? status,
    String? thumbnailUrl,
    Duration? duration,
    Map<String, dynamic>? metadata,
    String? errorMessage,
  }) {
    return Attachment(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      status: status ?? this.status,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'url': url,
      'localPath': localPath,
      'size': size,
      'mimeType': mimeType,
      'status': status.toString(),
      'thumbnailUrl': thumbnailUrl,
      'duration': duration?.inSeconds,
      'metadata': metadata,
      'errorMessage': errorMessage,
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      name: json['name'],
      type:
          AttachmentType.values.firstWhere((e) => e.toString() == json['type']),
      url: json['url'],
      localPath: json['localPath'],
      size: json['size'],
      mimeType: json['mimeType'],
      status: AttachmentStatus.values
          .firstWhere((e) => e.toString() == json['status']),
      thumbnailUrl: json['thumbnailUrl'],
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
      metadata: json['metadata']?.cast<String, dynamic>(),
      errorMessage: json['errorMessage'],
    );
  }
}
