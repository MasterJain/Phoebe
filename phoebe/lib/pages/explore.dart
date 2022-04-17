import 'dart:math';

import 'package:flutter/material.dart';

import 'package:wallpaper_app/widgets/new_items.dart';
import 'package:wallpaper_app/widgets/popular_items.dart';

class ExplorePage extends StatefulWidget {
  ExplorePage({Key key}) : super(key: key);

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  ScrollController scrollController;
  var scaffoldKey = GlobalKey<ScaffoldState>();

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

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.network(
        showgifs,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      DefaultTabController(
          length: 2,
          child: DefaultTabController(
            length: 2,
            child: Scaffold(
                backgroundColor: Colors.transparent,
                key: scaffoldKey,
                body: NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder:
                      (BuildContext context, bool innerBoxScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        centerTitle: false,
                        backgroundColor: Colors.transparent,
                        iconTheme: IconThemeData(
                          color: Colors.white,
                        ),
                        titleSpacing: 0,
                        title: Text(
                          'Explore',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxScrolled,
                        elevation: 2,
                        bottom: PreferredSize(
                          preferredSize: Size.fromHeight(35),
                          child: TabBar(
                            labelStyle: TextStyle(
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500),
                            tabs: <Widget>[
                              Tab(
                                child: Text('Popular Wall\'s',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kulim Park',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ),
                              Tab(
                                child: Text(
                                  'New Wall\'s',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Kulim Park',
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            ],
                            labelColor: Colors.black,
                            indicatorColor: Colors.grey[900],
                            unselectedLabelColor: Colors.grey,
                          ),
                        ),
                      )
                    ];
                  },
                  body: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[PopularItems(), NewItems()],
                        ),
                      ),
                    ],
                  ),
                )),
          )),
    ]);
  }
}
