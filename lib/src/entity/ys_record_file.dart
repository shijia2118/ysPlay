class YsRecordFile {
  String? begin;
  String? cameraType;
  String? end;
  int? type;

  YsRecordFile({
    this.begin,
    this.cameraType,
    this.end,
    this.type,
  });

  YsRecordFile.fromJson(Map<String, dynamic> json) {
    begin = json['begin'];
    cameraType = json['cameraType'];
    end = json['end'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['begin'] = begin;
    data['cameraType'] = cameraType;
    data['end'] = end;
    data['type'] = type;
    return data;
  }
}
