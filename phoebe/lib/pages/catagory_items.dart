import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../models/config.dart';

import '../pages/details.dart';
import '../widgets/cached_image.dart';

class CatagoryItem extends StatefulWidget {
  final String title;
  final String selectedCatagory;
  CatagoryItem({Key key, @required this.title, this.selectedCatagory})
      : super(key: key);

  @override
  _CatagoryItemState createState() =>
      _CatagoryItemState(this.title, this.selectedCatagory);
}

class _CatagoryItemState extends State<CatagoryItem> {
  String title;
  String selectedCatagory;
  _CatagoryItemState(this.title, this.selectedCatagory);
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
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    _isLoading = true;
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController controller;
  DocumentSnapshot _lastVisible;
  bool _isLoading;
  List<DocumentSnapshot> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: selectedCatagory)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection('contents')
          .where('category', isEqualTo: selectedCatagory)
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible['timestamp']])
          .limit(10)
          .get();

    if (data != null && data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _data.addAll(data.docs);
        });
      }
    } else {
      setState(() => _isLoading = false);
      scaffoldKey.currentState?.build(context);
      SnackBar(
        content: Text('No more posts!'),
      );
      //);
    }
    return null;
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.network(
        showgifs,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: Colors.transparent,
          centerTitle: false,
          title: Text('Categories',
              style: TextStyle(
                color: Colors.white,
              )),
        ),
        body: Column(
          children: [
            Expanded(
              child: StaggeredGridView.countBuilder(
                crossAxisCount: 4,
                controller: controller,
                itemCount: _data.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index < _data.length) {
                    final DocumentSnapshot d = _data[index];
                    return InkWell(
                      child: Stack(
                        children: <Widget>[
                          Hero(
                              tag: 'category$index',
                              child: cachedImage(d['image url'])),
                          Positioned(
                            bottom: 30,
                            left: 10,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  Config().hashTag,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                ),
                                Text(
                                  d['category'],
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              ],
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 20,
                            child: Row(
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.white.withOpacity(0.5),
                                    size: 25),
                                Text(
                                  d['loves'].toString(),
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                      tag: 'category$index',
                                      imageUrl: d['image url'],
                                      credits: d['credits'],
                                      catagory: d['category'],
                                      timestamp: d['timestamp'],
                                    )));
                      },
                    );
                  }
                  return Center(
                    child: new Opacity(
                      opacity: _isLoading ? 1.0 : 0.0,
                      child: new SizedBox(
                          width: 32.0,
                          height: 32.0,
                          child: CupertinoActivityIndicator()),
                    ),
                  );
                },
                staggeredTileBuilder: (int index) =>
                    new StaggeredTile.count(2, index.isEven ? 4 : 3),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                padding: EdgeInsets.all(15),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
