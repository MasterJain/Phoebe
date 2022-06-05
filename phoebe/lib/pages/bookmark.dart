import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phoebe_app/blocs/sign_in_bloc.dart';

import 'package:phoebe_app/models/contentmodel.dart';

import 'package:phoebe_app/pages/empty_page.dart';

import 'package:phoebe_app/widgets/gridcard.dart';
import 'package:provider/provider.dart';
import '../blocs/bookmark_bloc.dart';

class FavouritePage extends StatefulWidget {
  FavouritePage({Key? key, required this.userUID}) : super(key: key);
  final String? userUID;

  @override
  _FavouritePageState createState() => _FavouritePageState();
}

class _FavouritePageState extends State<FavouritePage> {
  Future<List> _getData(List bookmarkedList) async {
    print('main list: ${bookmarkedList.length}]');

    List d = [];
    if (bookmarkedList.length <= 10) {
      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: bookmarkedList)
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      });
    } else if (bookmarkedList.length > 10) {
      int size = 10;
      var chunks = [];

      for (var i = 0; i < bookmarkedList.length; i += size) {
        var end = (i + size < bookmarkedList.length)
            ? i + size
            : bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i, end));
      }

      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: chunks[0])
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[1])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(
              snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      });
    } else if (bookmarkedList.length > 20) {
      int size = 10;
      var chunks = [];

      for (var i = 0; i < bookmarkedList.length; i += size) {
        var end = (i + size < bookmarkedList.length)
            ? i + size
            : bookmarkedList.length;
        chunks.add(bookmarkedList.sublist(i, end));
      }

      await FirebaseFirestore.instance
          .collection('contents')
          .where('timestamp', whereIn: chunks[0])
          .get()
          .then((QuerySnapshot snap) {
        d.addAll(snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[1])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(
              snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      }).then((value) async {
        await FirebaseFirestore.instance
            .collection('contents')
            .where('timestamp', whereIn: chunks[2])
            .get()
            .then((QuerySnapshot snap) {
          d.addAll(
              snap.docs.map((e) => ContentModel.fromFirestore(e)).toList());
        });
      });
    }

    return d;
  }

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
    final String _collectionName = 'users';
    final String _snapText = 'loved items';

    return Stack(children: <Widget>[
      Image.network(
        showgifs,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      RefreshIndicator(
          onRefresh: () async {
            await context.read<BookmarkBloc>().getData();
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.white,
              ),
              centerTitle: false,
              title: Text('Saved Items', style: TextStyle(color: Colors.white)),
            ),
            body: context.read<SignInBloc>().guestUser == true ||
                    widget.userUID == null
                ? EmptyPage(
                    icon: FontAwesomeIcons.heart,
                    title:
                        'No wallpapers found.\n Sign in to access this feature',
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(_collectionName)
                        .doc(widget.userUID!)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snap) {
                      if (!snap.hasData) return CircularProgressIndicator();

                      List bookamrkedList = snap.data[_snapText];
                      return FutureBuilder(
                          future: _getData(bookamrkedList),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(
                                child: Text('Error'),
                              );
                            } else if (snapshot.hasData &&
                                snapshot.data.length == 0) {
                              return EmptyPage(
                                icon: FontAwesomeIcons.heart,
                                title: 'No wallpapers found',
                              );
                            } else {
                              return _buildList(snapshot);
                            }
                          });
                    },
                  ),
          ))
    ]);
  }

  Widget _buildList(snapshot) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        final ContentModel d = snapshot.data[index];
        return GridCard(
          d: d,
          heroTag: 'bookmark-${d.timestamp}',
        );
      },
      staggeredTileBuilder: (int index) =>
          new StaggeredTile.count(2, index.isEven ? 4 : 3),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(15),
    );
  }
}
