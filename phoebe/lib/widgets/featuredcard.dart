import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:phoebe_app/pages/details.dart';
import 'package:phoebe_app/utils/next_screen.dart';
import 'package:provider/provider.dart';

import '../blocs/data_bloc.dart';
import '../models/config.dart';
import '../widgets/loading_animation.dart';

class FeatureCard extends StatefulWidget {
  const FeatureCard({Key? key}) : super(key: key);

  @override
  State<FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> {
  int listIndex = 0;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;

    final db = context.watch<DataBloc>();

    return Stack(
      children: <Widget>[
        CarouselSlider(
          options: CarouselOptions(
              enlargeStrategy: CenterPageEnlargeStrategy.height,
              initialPage: 0,
              viewportFraction: 0.90,
              enlargeCenterPage: true,
              enableInfiniteScroll: false,
              height: h * 0.70,
              onPageChanged: (int index, reason) {
                setState(() => listIndex = index);
              }),
          items: db.alldata.length == 0
              ? [0, 1].take(1).map((f) => LoadingWidget()).toList()
              : db.alldata.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 0),
                          child: InkWell(
                              child: CachedNetworkImage(
                                imageUrl: i.imagelUrl!,
                                imageBuilder: (context, imageProvider) => Hero(
                                  tag: 'featured${i.timestamp}',
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                        bottom: 50),
                                    decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: <BoxShadow>[
                                          BoxShadow(
                                              color: Colors.grey[300]!,
                                              blurRadius: 30,
                                              offset: Offset(5, 20))
                                        ],
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover)),
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 30, bottom: 40),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  Config().hashTag,
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                                Text(
                                                  i.category!,
                                                  style: TextStyle(
                                                      decoration:
                                                          TextDecoration.none,
                                                      color: Colors.white,
                                                      fontSize: 25),
                                                )
                                              ],
                                            ),
                                            Spacer(),
                                            Icon(
                                              Icons.favorite,
                                              size: 25,
                                              color:
                                                  Colors.white.withOpacity(0.5),
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              i.loves.toString(),
                                              style: TextStyle(
                                                  decoration:
                                                      TextDecoration.none,
                                                  color: Colors.white
                                                      .withOpacity(0.7),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            SizedBox(
                                              width: 15,
                                            )
                                          ],
                                        )),
                                  ),
                                ),
                                placeholder: (context, url) => LoadingWidget(),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.error,
                                  size: 40,
                                ),
                              ),
                              onTap: () => nextScreen(
                                  context,
                                  DetailsPage(
                                      heroTag: 'featured${i.timestamp}',
                                      d: i))));
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
                color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
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
                activeColor: Colors.black,
                color: Colors.black,
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
    );
  }
}
