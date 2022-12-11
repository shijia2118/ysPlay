class YsRequestEntity {
  String? accessToken;
  String? deviceSerial;
  String? validateCode;
  String? ipcSerial;
  int? channelNo;
  int? direction;
  int? speed;
  int? command;
  int? index;

  YsRequestEntity(
      {this.accessToken,
      this.deviceSerial,
      this.validateCode,
      this.ipcSerial,
      this.channelNo,
      this.direction,
      this.speed,
      this.command,
      this.index});

  YsRequestEntity.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    deviceSerial = json['deviceSerial'];
    validateCode = json['validateCode'];
    ipcSerial = json['ipcSerial'];
    channelNo = json['channelNo'];
    direction = json['direction'];
    speed = json['speed'];
    command = json['command'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['deviceSerial'] = deviceSerial;
    data['validateCode'] = validateCode;
    data['ipcSerial'] = ipcSerial;
    data['channelNo'] = channelNo;
    data['direction'] = direction;
    data['speed'] = speed;
    data['command'] = command;
    data['index'] = index;
    return data;
  }
}
