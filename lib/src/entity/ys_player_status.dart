class YsPlayerStatus {
  bool? isSuccess;
  String? errorInfo;

  YsPlayerStatus({
    this.isSuccess,
    this.errorInfo,
  });

  YsPlayerStatus.fromJson(Map<String, dynamic> json) {
    isSuccess = json['isSuccess'] ?? false;
    errorInfo = json['errorInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccess'] = isSuccess;
    data['errorInfo'] = errorInfo;
    return data;
  }
}
