import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';

class JkLevelBtn extends StatefulWidget {
  final Function(int)? onSelectLevelHandle;
  final bool isShow;
  const JkLevelBtn({
    super.key,
    this.onSelectLevelHandle,
    this.isShow = true,
  });

  @override
  State<JkLevelBtn> createState() => _JkLevelBtnState();
}

class _JkLevelBtnState extends State<JkLevelBtn> {
  List<String> videoLevels = ['流畅', '标清', '高清'];
  int level = 2;

  @override
  Widget build(BuildContext context) {
    if (!widget.isShow) return Container();
    return GestureDetector(
      onTap: onSelectLevelHandle,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Text(
          videoLevels[level],
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// 选择清晰度
  void onSelectLevelHandle() {
    Pickers.showSinglePicker(
      context,
      data: videoLevels,
      selectData: videoLevels[level],
      onConfirm: (data, position) {
        setState(() {
          level = position;
        });

        if (widget.onSelectLevelHandle != null) {
          widget.onSelectLevelHandle!(level);
        }
      },
    );
  }
}
