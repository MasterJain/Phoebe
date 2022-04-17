import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/pages/about_page.dart';

import '../models/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/explore.dart';

import '../pages/sign_in_page.dart';
import '../utils/next_screen.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  DrawerWidget({Key key}) : super(key: key);

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  var textCtrl = TextEditingController();

  final List title = [
    'Categories',
    'Explore',
    'Saved Items',
    'About App',
    'Rate & Review',
    'Report Content',
    'More Info',
    'Follow on Instagram',
    'Logout'
  ];

  final List icons = [
    FontAwesomeIcons.dashcube,
    FontAwesomeIcons.solidCompass,
    FontAwesomeIcons.solidHeart,
    FontAwesomeIcons.info,
    FontAwesomeIcons.star,
    Icons.report_problem,
    FontAwesomeIcons.accessibleIcon,
    FontAwesomeIcons.instagram,
    FontAwesomeIcons.signOutAlt
  ];

  _launchURL() async {
    const url = 'https://www.instagram.com/getphoebe/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future openLogoutDialog(context1) async {
    showDialog(
        context: context1,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Logout?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: Text('Do you really want to Logout?'),
            actions: <Widget>[
              TextButton(
                child: Text('Yes'),
                onPressed: () async {
                  final sb = context.read<SignInBloc>();
                  if (sb.guestUser == false) {
                    Navigator.pop(context);
                    await sb.userSignout().then(
                        (_) => nextScreenCloseOthers(context, SignInPage()));
                  } else {
                    Navigator.pop(context);
                    await sb.guestSignout().then(
                        (_) => nextScreenCloseOthers(context, SignInPage()));
                  }
                },
              ),
              TextButton( //FlatButton
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  aboutAppDialog() {
    showDialog(
        context: context,
        builder: (BuildContext coontext) {
          return AboutDialog(
            applicationVersion: '2.5.0',
            applicationName: Config().appName,
            applicationIcon: Image(
              height: 40,
              width: 40,
              image: AssetImage(Config().appIcon),
            ),
            applicationLegalese: 'Designed & Developed By\nAnish Jain',
          );
        });
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget instagram = TextButton(
      child: Text("Instagram"),
      onPressed: () {
        _launchURL();
      },
    );
    Widget email = TextButton( //FlatButton
      child: Text("Email"),
      onPressed: () {
        FlutterClipboard.copy("masterjain@icloud.com")
            .then((result) {
          final snackBar = SnackBar(
            content: Text('Email Copied'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          Scaffold.of(context).showSnackBar(snackBar);
        });
      },
    );
    Widget close = TextButton( //FlatButton
      child: Text("Close"),
      onPressed: () {},
    );

    // set up the AlertDialog

    // show the dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title:
                Text("Report Content", style: TextStyle(color: Colors.white)),
            content: Text(
                "If this content belongs to you and you want it to get taken down please message me via below options \n\nAfter proper verification  of the ownership,I will take it down",
                style: TextStyle(color: Colors.white)),
            actions: [
              instagram,
              email,
              close,
            ],
          );
        });
  }

  void handleRating() {
    LaunchReview.launch(
        androidAppId: Config().packageName, iOSAppId: null, writeReview: true);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 50, left: 0),
                  alignment: Alignment.center,
                  height: 150,
                  child: Text(
                    Config().hashTag.toUpperCase(),
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: title.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        child: Container(
                          height: 45,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  icons[index],
                                  color: Colors.white,
                                  size: 22,
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(title[index],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500))
                              ],
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          if (index == 0) {
                            nextScreeniOS(context, CatagoryPage());
                          } else if (index == 1) {
                            nextScreeniOS(context, ExplorePage());
                          } else if (index == 2) {
                            nextScreeniOS(context, BookmarkPage());
                          } else if (index == 3) {
                            aboutAppDialog();
                          } else if (index == 4) {
                            handleRating();
                          } else if (index == 5) {
                            showAlertDialog(context);
                          } else if (index == 6) {
                            nextScreeniOS(context, MyAboutPage());
                          } else if (index == 7) {
                            _launchURL();
                          } else if (index == 8) {
                            openLogoutDialog(context);
                          }
                        },
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  ),
                )
              ],
            )),
      ),
    );
  }
}
