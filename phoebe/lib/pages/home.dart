import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_awesome_icons/line_awesome_icons.dart';

import 'package:provider/provider.dart';

import 'package:wallpaper_app/blocs/sign_in_bloc.dart';

import 'package:wallpaper_app/utils/dialog.dart';
import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/config.dart';
import '../pages/bookmark.dart';
import '../pages/catagories.dart';
import '../pages/details.dart';
import '../pages/explore.dart';
import '../pages/internet.dart';
import '../widgets/drawer.dart';
import '../widgets/loading_animation.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int listIndex = 0;
  int option;
  final List<Color> colors = [Colors.white, Colors.black];
  final List<Color> borders = [Colors.black, Colors.white];
  final List<String> themes = ['Light', 'Darkest'];
  //MusicPlayer musicPlayer;
  var _scaffoldKey = new GlobalKey<ScaffoldState>();

  //-------admob--------

  // initAdmobAd() {
  //FirebaseAdMob.instance.initialize(appId: Config().admobAppId);
  // context.read<AdsBloc>().loadAdmobInterstitialAd();
  // }

  static List gifs = [
    'https://i.pinimg.com/originals/bd/7d/cf/bd7dcf911fe1a807220fcb98806958c7.gif',
    'https://i.pinimg.com/originals/44/9e/05/449e058844d89d45822a44c9f5f60fe2.gif',
    'https://i.imgur.com/glzWdig.gif',
    'https://45.media.tumblr.com/e8529b4c194f41fcc55de74f4eb64c96/tumblr_nylde0Y3U01rs9cyvo1_1280.gif',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcSeGtpNjMt-nNMP_j4OTh7wVNq5Sh6mlf5pcw&usqp=CAU',
    "https://i.pinimg.com/originals/2f/f6/91/2ff691508ac61bbb78de957d0cb77016.gif",
    'https://i0.wp.com/media0.giphy.com/media/y30LCMuHRVbxK/giphy.gif',
    "https://i.pinimg.com/originals/bc/db/8a/bcdb8abb2e74d02c206739558366ea8f.gif",
    "https://thumbs.gfycat.com/CloudyNecessaryKitten-size_restricted.gif",
    "https://64.media.tumblr.com/b2ce02be37b7416784c0d8d99f014fe9/24305b26b92e5c0c-10/s500x750/ae67e29ed0ee763e59dcdb1c90135ede812534c5.gif",
    "https://66.media.tumblr.com/8072c169209a410edad136246ebd5a33/tumblr_pg8vt11nQe1xhud4ho1_400.gifv",
    "https://thumbs.gfycat.com/BiodegradableSingleDobermanpinscher-size_restricted.gif",
    "https://media4.giphy.com/media/68Xeo9bMgyNoY/giphy.gif",
    "https://media2.giphy.com/media/1sw6w7ConI2bowYNew/giphy.gif",
    "https://thumbs.gfycat.com/ShabbyOblongDove-size_restricted.gif",
    "https://i.pinimg.com/originals/d1/de/5a/d1de5ab789284bc7f6a8988bc4756989.gif",
  ];
  static Random random = new Random();
  var showgifs = gifs[random.nextInt(gifs.length)];

  //------fb-------
  //bool _isInterstitialAdLoaded = false;
  //initFbAd (){
  // context.read<AdsBloc>().loadFbAd();
  //}

  @override
  void initState() {
    // musicPlayer = MusicPlayer();
    //musicPlayer.play(MusicItem(
    // url: "http://radio.plaza.one/mp3",
    //coverUrl:
    // trackName: "Phoebe 24/7 Music",
    // artistName: "NightWave Plaza",
    // albumName: "",
    //duration: Duration(days: 365)));

    Future.delayed(Duration(milliseconds: 0)).then((f) {
      final ub = context.read<UserBloc>();
      ub.getUserData();
    });
    //FacebookAudienceNetwork.init(
    // testingId: "d36e14b4-8d97-4219-a1ab-1a327c0963df",
    //);

    //_loadInterstitialAd();
    //initAdmobAd(); //-------admob--------
    //initFbAd();

    //O//neSignal.shared.init(Config().onesignalAppId);

    super.initState();
  }

  final List<String> zones = [
    "vz94de33ed15ca4602b3",
  ];
/*
  void _loadInterstitialAd() {
    FacebookInterstitialAd.loadInterstitialAd(
      placementId:
          "1018267318600571_1018267605267209", //"IMG_16_9_APP_INSTALL#2312433698835503_2650502525028617" YOUR_PLACEMENT_ID
      listener: (result, value) {
        print(">> FAN > Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED)
          _isInterstitialAdLoaded = true;
        //_showInterstitialAd();

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          _isInterstitialAdLoaded = false;
          _loadInterstitialAd();
        }
      },
    );
  }

  _showInterstitialAd() {
    if (_isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
    else
      print("Interstial Ad not yet loaded!");
  }
  */

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final db = context.watch<DataBloc>();
    final ub = context.watch<UserBloc>();
    final ib = context.watch<InternetBloc>();
    final sb = context.watch<SignInBloc>();

    return Stack(children: <Widget>[
      Image.network(
        showgifs,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      ib.hasInternet == false
          ? NoInternetPage()
          // :
          //BlocBuilder(
          // bloc: changeThemeBloc,
          // builder: (BuildContext context, ChangeThemeState state) {
          //  return Theme(
          //data: state.themeData,
          // child:
          : Scaffold(
              key: _scaffoldKey,
              backgroundColor: Colors.transparent,
              endDrawer: DrawerWidget(),
              body: Column(
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(
                        top: 20,
                        left: 30,
                        right: 10,
                      ),
                      alignment: Alignment.centerLeft,
                      height: 110,
                      child: Row(
                        children: <Widget>[
                          Text(
                            Config().appName,
                            style: TextStyle(
                                fontSize: 27,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          ),
                          Spacer(),
                          InkWell(
                            child: Icon(
                              LineAwesomeIcons.music,
                              size: 24,
                              color: Colors.white,
                            ),
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg:
                                      "Check notification to pause/play live music",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor: Colors.white,
                                  textColor: Colors.black,
                                  fontSize: 16.0);
                            },
                          ),
                          SizedBox(width: 15),
                          InkWell(
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[300],
                                  image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                          context.watch<UserBloc>().imageUrl))),
                            ),
                            onTap: () {
                              sb.guestUser == true
                                  ? showGuestUserInfo(context, ub.userName,
                                      ub.email, ub.imageUrl)
                                  : showUserInfo(context, ub.userName, ub.email,
                                      ub.imageUrl);
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.stream,
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _scaffoldKey.currentState.openEndDrawer();
                            },
                          )
                        ],
                      )),
                  Stack(
                    children: <Widget>[
                      CarouselSlider(
                        options: CarouselOptions(
                          //realPage: 0,
                          initialPage: 0,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, _) {
                            setState(() {
                              listIndex = index;
                            });
                          },
                          height: h * 0.70,
                          enlargeCenterPage: true,
                          viewportFraction: 0.90,
                        ),
                        items: db.alldata.length == 0
                            ? [0, 1]
                                .take(1)
                                .map((f) => LoadingWidget())
                                .toList()
                            : db.alldata.map((i) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        margin:
                                            EdgeInsets.symmetric(horizontal: 0),
                                        child: InkWell(
                                          child: CachedNetworkImage(
                                            imageUrl: i['image url'],
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    Hero(
                                              tag: i['timestamp'],
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 50),
                                                decoration: BoxDecoration(
                                                    //color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    boxShadow: <BoxShadow>[
                                                      BoxShadow(
                                                          color:
                                                              Color(0xFFAFAFA),
                                                          blurRadius: 5,
                                                          spreadRadius: 1.0,
                                                          offset: Offset(6, 4)),
                                                      BoxShadow(
                                                          color:
                                                              Color(0xFFACBACA),
                                                          blurRadius: 5,
                                                          spreadRadius: 1.0,
                                                          offset:
                                                              Offset(-6, -4))
                                                    ],
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover)),
                                                child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 30,
                                                            bottom: 40),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: <Widget>[
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              Config().hashTag,
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 14),
                                                            ),
                                                            Text(
                                                              i['category'],
                                                              style: TextStyle(
                                                                  decoration:
                                                                      TextDecoration
                                                                          .none,
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 25),
                                                            )
                                                          ],
                                                        ),
                                                        Spacer(),
                                                        Icon(
                                                          Icons.favorite,
                                                          size: 25,
                                                          color: Colors.white
                                                              .withOpacity(0.5),
                                                        ),
                                                        SizedBox(width: 2),
                                                        Text(
                                                          i['loves'].toString(),
                                                          style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .none,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.7),
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        SizedBox(
                                                          width: 15,
                                                        )
                                                      ],
                                                    )),
                                              ),
                                            ),
                                            placeholder: (context, url) =>
                                                LoadingWidget(),
                                            errorWidget:
                                                (context, url, error) => Icon(
                                              Icons.error,
                                              size: 40,
                                            ),
                                          ),
                                          onTap: () {
                                            // _showInterstitialAd();
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        DetailsPage(
                                                            tag: i['timestamp'],
                                                            imageUrl:
                                                                i['image url'],
                                                            credits:
                                                                i['credits'],
                                                            catagory:
                                                                i['category'],
                                                            timestamp: i[
                                                                'timestamp'])));
                                          },
                                        ));
                                  },
                                );
                              }).toList(),
                      ),
                      Positioned(
                        top: 40,
                        left: w * 0.23,
                        child: Text(
                          'WALL OF THE DAY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        left: w * 0.34,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          child: DotsIndicator(
                            dotsCount: 5,
                            position: listIndex.toDouble(),
                            decorator: DotsDecorator(
                              activeColor: Colors.white,
                              color: Colors.white,
                              spacing: EdgeInsets.all(3),
                              size: const Size.square(8.0),
                              activeSize: const Size(40.0, 6.0),
                              activeShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                  Container(
                    height: 50,
                    width: w * 0.80,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(FontAwesomeIcons.dashcube,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CatagoryPage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCompass,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ExplorePage()));
                          },
                        ),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidHeart,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => BookmarkPage()));
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
    ]);
    //  );
    //});
  }
}
