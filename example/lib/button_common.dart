import 'package:flutter/material.dart';

class ButtonCommon extends StatelessWidget {
  final Function()? onPressed;
  final String text;
  const ButtonCommon({
    super.key,
    this.onPressed,
    this.text = '',
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
