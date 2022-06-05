import 'package:url_launcher/url_launcher_string.dart';

launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    print('Launching $url...');
    await launchUrlString(url);
  } else {
    print('Error launching $url!');
  }
}

launchURLforweb(String url) async {
  if (await canLaunchUrlString(url)) {
    print('Launching $url...');
    await launchUrlString(url);
  } else {
    print('Error launching $url!');
  }
}

void doNothing() {
  print('Nothing is happening here (yet)');
}
