class YsPwResult {
  bool? isSuccess;
  String? msg;

  YsPwResult({
    this.isSuccess,
    this.msg,
  });

  YsPwResult.fromJson(Map<String, dynamic> json) {
    isSuccess = json['isSuccess'] ?? false;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['isSuccess'] = isSuccess;
    data['msg'] = msg;
    return data;
  }
}
