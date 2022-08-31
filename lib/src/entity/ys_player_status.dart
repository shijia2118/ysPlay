class YsPlayerStatus {
  bool? success;
  String? description;

  YsPlayerStatus({
    this.success,
    this.description,
  });

  YsPlayerStatus.fromJson(Map<String, dynamic> json) {
    success = json['success']??false;
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['description'] = description;
    return data;
  }
}
