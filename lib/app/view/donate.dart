import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Donate information implemented as link to buymeacoffee.com.
class Donate extends StatelessWidget {
  const Donate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () async {
        const urlString = 'https://www.buymeacoffee.com/zakhio';
        if (await canLaunch(urlString)) {
          await launch(urlString);
        }
      },
      icon: const Icon(Icons.coffee_outlined),
      label: Text(
        'Support me with a coffee',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
              decoration: TextDecoration.underline,
            ),
      ),
    );
  }
}
