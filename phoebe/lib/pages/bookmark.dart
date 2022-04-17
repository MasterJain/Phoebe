import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/blocs/sign_in_bloc.dart';
import 'package:wallpaper_app/models/config.dart';
import 'package:wallpaper_app/pages/details.dart';
import 'package:wallpaper_app/pages/empty_page.dart';

import 'package:wallpaper_app/widgets/cached_image.dart';
import '../blocs/bookmark_bloc.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key key}) : super(key: key);

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
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
    final sb = context.watch<SignInBloc>();

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
          body: sb.guestUser == true
              ? EmptyPage(
                  icon: FontAwesomeIcons.heart,
                  title:
                      'No wallpapers found.\n Sign in to access this feature',
                )
              : FutureBuilder(
                  future: context.watch<BookmarkBloc>().getData(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.data.length == 0)
                        return EmptyPage(
                          icon: FontAwesomeIcons.heart,
                          title: 'No wallpapers found',
                        );
                      return _buildList(snapshot);
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error),
                      );
                    }

                    return Center(
                      child: CupertinoActivityIndicator(),
                    );
                  },
                ),
        ),
      ),
    ]);
  }

  Widget _buildList(snapshot) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 4,
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index) {
        List d = snapshot.data;

        return InkWell(
          child: Stack(
            children: <Widget>[
              Hero(
                  tag: 'bookmark$index',
                  child: cachedImage(d[index]['image url'])),
              Positioned(
                bottom: 30,
                left: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      Config().hashTag,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      d[index]['category'],
                      style: TextStyle(color: Colors.white, fontSize: 18),
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
                        color: Colors.white.withOpacity(0.5), size: 25),
                    Text(
                      d[index]['loves'].toString(),
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
                          tag: 'bookmark$index',
                          imageUrl: d[index]['image url'],
                          credits: d[index]['credits'],
                          catagory: d[index]['category'],
                          timestamp: d[index]['timestamp'],
                        )));
          },
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
