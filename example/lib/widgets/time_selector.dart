import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:ys_play_example/utils/time_util.dart';

class TimeSelector extends StatefulWidget {
  final String text;
  final String time;
  final Function(String) onSelected;
  const TimeSelector({
    super.key,
    this.text = '',
    required this.time,
    required this.onSelected,
  });

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  late String time;

  @override
  void initState() {
    super.initState();
    time = widget.time;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelectHandle,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.text + ': '),
            Text(time),
          ],
        ),
      ),
    );
  }

  /// 选择时间
  void onSelectHandle() {
    DateTime dt = DateTime.parse(time);
    PDuration pt = PDuration.parse(dt);
    Pickers.showDatePicker(
      context,
      selectDate: pt,
      mode: DateMode.YMDHMS,
      onConfirm: (t) {
        DateTime dateTime = DateTime(
          t.year ?? 0,
          t.month ?? 0,
          t.day ?? 0,
          t.hour ?? 0,
          t.minute ?? 0,
          t.second ?? 0,
        );
        time = TimeUtil.timeFormat(dateTime.millisecondsSinceEpoch);
        widget.onSelected(time);
        setState(() {});
      },
    );
  }
}
