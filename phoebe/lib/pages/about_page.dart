import 'package:eva_icons_flutter/eva_icons_flutter.dart';

import 'package:flutter/material.dart';

import 'package:wallpaper_app/abouthelpers/sexy_title.dart';
import 'package:wallpaper_app/abouthelpers/ui_helpers.dart';

class MyAboutPage extends StatefulWidget {
  @override
  _MyAboutPageState createState() => _MyAboutPageState();
}

class _MyAboutPageState extends State<MyAboutPage> {
  List<String> itemContent = [
    'What is this app about?',
    'Phoebe is a Wallpaper App which shows images artwork and wallpaper of vaporwave aesthetic gamewave and other wallpapers listed in the app, and helps users to set Wallpapers in Ease.\n\nYou can Set Wallpaper and Download easily,More Wallpapers will updated by time to time.\n\nThanks for downloading the app! Do Rate and Review',
    'Credits',
    'All the Images shown in this app belongs to their respective owners,this app is just a showcase for users to set wallpapers.None of the images shown here belongs to me.Ads are placed to support myself  \n\nIf you are the owner of one of the images or art shown here and want it get removed please click on the facebook logo below my profile to contact me and get it removed. \n\nThis app would not have been possible without the Flutter framework, the open source projects that I\'ve used and the tireless efforts of developers and contributors in the Flutter community.',
  ]; //the text in the tile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "About",
          style: TextStyle(
              fontFamily: 'Sans', fontSize: 16.0, color: Colors.black),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Hero(
                    tag: 'tile2',
                    child: SexyTile(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 70.0,
                              height: 70.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage('assets/images/anish.jpg'),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  EvaIcons.code,
                                  color: Colors.black,
                                  size: 18.0,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  'with',
                                  style: TextStyle(
                                      fontFamily: 'Sans', fontSize: 16.0),
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Icon(
                                  EvaIcons.heart,
                                  color: Colors.red,
                                  size: 18.0,
                                ),
                                SizedBox(
                                  width: 6.0,
                                ),
                                Text(
                                  'by',
                                  style: TextStyle(
                                      fontFamily: 'Sans', fontSize: 16.0),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Text(
                              'Anish Jain',
                              //style: Color(Colors.black),
                              softWrap: true,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              style:
                                  TextStyle(fontFamily: 'Sans', fontSize: 16.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                IconButton(
                                  icon: Icon(
                                    EvaIcons.person,
                                    color: Colors.black,
                                    size: 24.0,
                                  ),
                                  onPressed: () => launchURL(
                                      'https://play.google.com/store/apps/details?id=jain.phoebe'),
                                ),
                                IconButton(
                                  icon: Icon(
                                    EvaIcons.facebook,
                                    color: Colors.blue,
                                    size: 26.0,
                                  ),
                                  onPressed: () => launchURL(
                                      'https://www.facebook.com/ItsAnishJain'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      splashColor: Colors.red,
                    ),
                  ),
                  SexyTile(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            itemContent[0],
                            //style: HeadingStylesDefault.accent,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style:
                                TextStyle(fontFamily: 'Sans', fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            itemContent[1],
                            textAlign: TextAlign.left,
                            softWrap: true,
                            style:
                                TextStyle(fontFamily: 'Sans', fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    splashColor: Colors.red,
                  ),
                  SexyTile(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            itemContent[2],

                            ///style: HeadingStylesDefault.accent,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style:
                                TextStyle(fontFamily: 'Sans', fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            itemContent[3],
                            // style: isThemeCurrentlyDark(context)
                            //    ? BodyStylesDefault.white
                            //  : BodyStylesDefault.black,
                            textAlign: TextAlign.left,
                            softWrap: true,
                            style:
                                TextStyle(fontFamily: 'Sans', fontSize: 16.0),
                            overflow: TextOverflow.fade,
                          ),
                        ],
                      ),
                    ),
                    splashColor: Colors.red,
                  ),
                  SizedBox(
                    height: 36.0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab',
        child: Icon(
          EvaIcons.globe,
          size: 36.0,
        ),
        tooltip: 'View GitHub repo',
        foregroundColor: Colors.white,
        backgroundColor: Colors.red[800],
        elevation: 5.0,
        onPressed: () => launchURL(
            'https://play.google.com/store/apps/details?id=jain.phoebe'),
      ),
    );
  }
}
