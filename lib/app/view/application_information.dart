import 'package:flutter/material.dart';

/// Page with information about the applications.
class ApplicationInformation extends StatelessWidget {
  const ApplicationInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This is a small application which provides an overview over free '
            'and busy meetings rooms that are available to book in your Google '
            'Calendar.',
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 24),
          Text(
            'Just click on `Sign in with Google` in the right top corner.',
            style: Theme.of(context).textTheme.headline6,
          ),
        ],
      ),
    );
  }
}
