

import 'package:url_launcher/url_launcher.dart';

launchURL(String url) async {
  if (await canLaunch(url)) {
    print('Launching $url...');
    await launch(url);
  } else {
    print('Error launching $url!');
  }
}

launchURLforweb(String url) async {
  if (await canLaunch(url)) {
    print('Launching $url...');
    await launch(url);
  } else {
    print('Error launching $url!');
  }
}

void doNothing() {
  print('Nothing is happening here (yet)');
} 
