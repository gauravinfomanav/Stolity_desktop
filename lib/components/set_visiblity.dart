import 'package:flutter/material.dart';
import 'package:stolity_desktop_application/Constants.dart';

class VisibilitySelector extends StatefulWidget {
  final bool? isForDownload; // optional flag

  const VisibilitySelector({Key? key, this.isForDownload}) : super(key: key);

  @override
  _VisibilitySelectorState createState() => _VisibilitySelectorState();
}

class _VisibilitySelectorState extends State<VisibilitySelector> {
  String selected = 'Public';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: widget.isForDownload == true
              ? CrossAxisAlignment.start 
              : CrossAxisAlignment.center,
      children: [
        Text(
          "  Set Visibility:",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            fontFamily: Constants.FONT_DEFAULT_NEW,
          ),
        ),
        SizedBox(height: 6),
        Row(
          mainAxisAlignment: widget.isForDownload == true
              ? MainAxisAlignment.start 
              : MainAxisAlignment.center, 
          children: [
            Row(
              children: [
                Radio<String>(
                  value: 'Public',
                  groupValue: selected,
                  onChanged: (value) {
                    setState(() {
                      selected = value!;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                Text(
                  'Public',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(width: 20),
            Row(
              children: [
                Radio<String>(
                  value: 'Private',
                  groupValue: selected,
                  onChanged: (value) {
                    setState(() {
                      selected = value!;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                Text(
                  'Private',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
