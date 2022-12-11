class YsPlayerStatus {
  bool? isSuccess;
  String? playErrorInfo;
  String? talkErrorInfo;

  YsPlayerStatus({
    this.isSuccess,
    this.playErrorInfo,
    this.talkErrorInfo,
  });

  YsPlayerStatus.fromJson(Map<String, dynamic> json) {
    isSuccess = json['isSuccess'] ?? false;
    playErrorInfo = json['playErrorInfo'];
    talkErrorInfo = json['talkErrorInfo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccess'] = isSuccess;
    data['playErrorInfo'] = playErrorInfo;
    data['talkErrorInfo'] = talkErrorInfo;
    return data;
  }
}
