import 'package:flutter/material.dart';

/// Page with information about the applications.
class ApplicationInformation extends StatelessWidget {
  const ApplicationInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text('This is small application that tries to '
        'address the situation when you urgently need a meeting room, '
        'but it is hard to find one in Google Calendar. '
        'Just click on `Sign in with Google` in the right top corner.');
  }
}
