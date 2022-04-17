import 'dart:math';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:wallpaper_app/blocs/userdata_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/config.dart';
import '../pages/home.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool signInStartGoogle = false;
  double leftPaddingGoogle = 20;
  double rightPaddingGoogle = 20;
  bool signInCompleteGoogle = false;

  handleAnimationGoogle() {
    setState(() {
      leftPaddingGoogle = 10;
      rightPaddingGoogle = 10;
      signInStartGoogle = true;
    });
  }

  handleReverseAnimationGoogle() {
    setState(() {
      leftPaddingGoogle = 20;
      rightPaddingGoogle = 20;
      signInStartGoogle = false;
    });
  }

  handleGuestUser() async {
    final sb = context.read<SignInBloc>();
    final ub = context.read<UserBloc>();
    await sb.setGuestUser();
    await sb.saveGuestUserData();
    await ub.getUserData().then((_) => nextScreenReplace(context, HomePage()));
  }

  handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(_scaffoldKey, 'Check your internet connection!');
    } else {
      handleAnimationGoogle();
      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          openSnacbar(_scaffoldKey, 'Something is wrong. Please try again.');
          setState(() {
            signInStartGoogle = false;
          });
          handleReverseAnimationGoogle();
        } else {
          sb.checkUserExists().then((value) {
            if (sb.userExists == true) {
              sb.getUserData(sb.uid).then((value) => sb
                  .saveDataToSP()
                  .then((value) => sb.setSignIn().then((value) {
                        setState(() => signInCompleteGoogle = true);
                        handleAfterSignupGoogle();
                      })));
            } else {
              sb.getTimestamp().then((value) => sb.saveDataToSP().then(
                  (value) => sb
                      .saveToFirebase()
                      .then((value) => sb.setSignIn().then((value) {
                            setState(() => signInCompleteGoogle = true);
                            handleAfterSignupGoogle();
                          }))));
            }
          });
        }
      });
    }
  }

  handleAfterSignupGoogle() {
    setState(() {
      leftPaddingGoogle = 20;
      rightPaddingGoogle = 20;
      Future.delayed(Duration(milliseconds: 1000)).then((f) {
        nextScreenReplace(context, HomePage());
      });
    });
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
    return Stack(children: <Widget>[
      Image.network(
        showgifs,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: false,
            actions: [
              TextButton( //TextButton
                  onPressed: () {
                    handleGuestUser();
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 90, left: 40, right: 40, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Image(
                          image: AssetImage(Config().splashIcon),
                          height: 80,
                          width: 80,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          'Welcome to ${Config().appName}!',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          'Explore thousands of free wallpapers for your phone and set them as your Lockscreen or HomeScreen anytime you want.',
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        )
                      ],
                    ),
                  ),
                  Flexible(
                      flex: 2,
                      child: Column(
                        //crossAxisAlignment: cr,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.only(top: 80),
                              height: 45,
                              decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  borderRadius: BorderRadius.circular(25)),
                              child: AnimatedPadding(
                                  padding: EdgeInsets.only(
                                    left: leftPaddingGoogle,
                                    right: rightPaddingGoogle,
                                  ),
                                  duration: Duration(milliseconds: 1000),
                                  child: AnimatedCrossFade(
                                    duration: Duration(milliseconds: 400),
                                    firstChild: _firstChildGoogle(),
                                    secondChild: signInCompleteGoogle == false
                                        ? _secondChildGoogle()
                                        : _firstChildGoogle(),
                                    crossFadeState: signInStartGoogle == false
                                        ? CrossFadeState.showFirst
                                        : CrossFadeState.showSecond,
                                  ))),
                        ],
                      ))
                ],
              ),
            ),
          )),
    ]);
  }

  Widget _firstChildGoogle() {
    return TextButton.icon( //TextButton
      icon: signInCompleteGoogle == false
          ? Icon(
              FontAwesomeIcons.google,
              size: 22,
              color: Colors.white,
            )
          : Icon(
              Icons.done,
              size: 25,
              color: Colors.white,
            ),
      label: signInCompleteGoogle == false
          ? Text(
              ' Continue with Google',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            )
          : Text(
              ' Completed',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white),
            ),
      onPressed: () {
        handleGoogleSignIn();
      },
    );
  }

  Widget _secondChildGoogle() {
    return Container(
        padding: EdgeInsets.all(10),
        height: 45,
        width: 45,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          backgroundColor: Colors.white,
        ));
  }
}
