class YsResponseEntity {
  YS7ResponseDataEntity? data;
  String? code;
  String? msg;

  YsResponseEntity({this.data, this.code, this.msg});

  YsResponseEntity.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? YS7ResponseDataEntity.fromJson(json['data']) : null;
    code = json['code'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['code'] = code;
    data['msg'] = msg;
    return data;
  }
}

class YS7ResponseDataEntity {
  String? supportCloud;
  String? supportIntelligentTrack;
  String? supportP2pMode;
  String? supportResolution;
  String? supportTalk;
  String? supportWifiUserId;
  String? supportRemoteAuthRandcode;
  String? supportUpgrade;
  String? supportSmartWifi;
  String? supportSsl;
  String? supportWeixin;
  String? ptzCloseScene;
  String? supportPresetAlarm;
  String? supportRelatedDevice;
  String? supportMessage;
  String? ptzPreset;
  String? supportWifi;
  String? supportCloudVersion;
  String? ptzCenterMirror;
  String? supportDefence;
  String? ptzTopBottom;
  String? supportFullscreenPtz;
  String? supportDefenceplan;
  String? supportDisk;
  String? supportAlarmVoice;
  String? ptzLeftRight;
  String? supportModifyPwd;
  String? supportCapture;
  String? supportPrivacy;
  String? supportEncrypt;
  String? supportAutoOffline;
  int? index;

  YS7ResponseDataEntity(
      {this.supportCloud,
      this.supportIntelligentTrack,
      this.supportP2pMode,
      this.supportResolution,
      this.supportTalk,
      this.supportWifiUserId,
      this.supportRemoteAuthRandcode,
      this.supportUpgrade,
      this.supportSmartWifi,
      this.supportSsl,
      this.supportWeixin,
      this.ptzCloseScene,
      this.supportPresetAlarm,
      this.supportRelatedDevice,
      this.supportMessage,
      this.ptzPreset,
      this.supportWifi,
      this.supportCloudVersion,
      this.ptzCenterMirror,
      this.supportDefence,
      this.ptzTopBottom,
      this.supportFullscreenPtz,
      this.supportDefenceplan,
      this.supportDisk,
      this.supportAlarmVoice,
      this.ptzLeftRight,
      this.supportModifyPwd,
      this.supportCapture,
      this.supportPrivacy,
      this.supportEncrypt,
      this.supportAutoOffline,
      this.index});

  YS7ResponseDataEntity.fromJson(Map<String, dynamic> json) {
    supportCloud = json['support_cloud'];
    supportIntelligentTrack = json['support_intelligent_track'];
    supportP2pMode = json['support_p2p_mode'];
    supportResolution = json['support_resolution'];
    supportTalk = json['support_talk'];
    supportWifiUserId = json['support_wifi_userId'];
    supportRemoteAuthRandcode = json['support_remote_auth_randcode'];
    supportUpgrade = json['support_upgrade'];
    supportSmartWifi = json['support_smart_wifi'];
    supportSsl = json['support_ssl'];
    supportWeixin = json['support_weixin'];
    ptzCloseScene = json['ptz_close_scene'];
    supportPresetAlarm = json['support_preset_alarm'];
    supportRelatedDevice = json['support_related_device'];
    supportMessage = json['support_message'];
    ptzPreset = json['ptz_preset'];
    supportWifi = json['support_wifi'];
    supportCloudVersion = json['support_cloud_version'];
    ptzCenterMirror = json['ptz_center_mirror'];
    supportDefence = json['support_defence'];
    ptzTopBottom = json['ptz_top_bottom'];
    supportFullscreenPtz = json['support_fullscreen_ptz'];
    supportDefenceplan = json['support_defenceplan'];
    supportDisk = json['support_disk'];
    supportAlarmVoice = json['support_alarm_voice'];
    ptzLeftRight = json['ptz_left_right'];
    supportModifyPwd = json['support_modify_pwd'];
    supportCapture = json['support_capture'];
    supportPrivacy = json['support_privacy'];
    supportEncrypt = json['support_encrypt'];
    supportAutoOffline = json['support_auto_offline'];
    index = json['index'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['support_cloud'] = supportCloud;
    data['support_intelligent_track'] = supportIntelligentTrack;
    data['support_p2p_mode'] = supportP2pMode;
    data['support_resolution'] = supportResolution;
    data['support_talk'] = supportTalk;
    data['support_wifi_userId'] = supportWifiUserId;
    data['support_remote_auth_randcode'] = supportRemoteAuthRandcode;
    data['support_upgrade'] = supportUpgrade;
    data['support_smart_wifi'] = supportSmartWifi;
    data['support_ssl'] = supportSsl;
    data['support_weixin'] = supportWeixin;
    data['ptz_close_scene'] = ptzCloseScene;
    data['support_preset_alarm'] = supportPresetAlarm;
    data['support_related_device'] = supportRelatedDevice;
    data['support_message'] = supportMessage;
    data['ptz_preset'] = ptzPreset;
    data['support_wifi'] = supportWifi;
    data['support_cloud_version'] = supportCloudVersion;
    data['ptz_center_mirror'] = ptzCenterMirror;
    data['support_defence'] = supportDefence;
    data['ptz_top_bottom'] = ptzTopBottom;
    data['support_fullscreen_ptz'] = supportFullscreenPtz;
    data['support_defenceplan'] = supportDefenceplan;
    data['support_disk'] = supportDisk;
    data['support_alarm_voice'] = supportAlarmVoice;
    data['ptz_left_right'] = ptzLeftRight;
    data['support_modify_pwd'] = supportModifyPwd;
    data['support_capture'] = supportCapture;
    data['support_privacy'] = supportPrivacy;
    data['support_encrypt'] = supportEncrypt;
    data['support_auto_offline'] = supportAutoOffline;
    data['index'] = index;
    return data;
  }
}
