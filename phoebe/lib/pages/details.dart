// details page

import 'dart:convert';
import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:phoebe_app/blocs/sign_in_bloc.dart';
import 'package:phoebe_app/models/contentmodel.dart';
import 'package:phoebe_app/utils/dialog.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'package:wallpaper/wallpaper.dart';

import '../blocs/data_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/userdata_bloc.dart';
import '../models/config.dart';
import '../models/icon_data.dart';
import '../utils/circular_button.dart';

class DetailsPage extends StatefulWidget {
  final String heroTag;
  final ContentModel d;

  DetailsPage({Key? key, required this.heroTag, required this.d})
      : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String progress = 'Set as Wallpaper or Download';
  bool downloading = false;
  late Stream<String> progressString;
  Icon dropIcon = Icon(Icons.arrow_upward);
  Icon upIcon = Icon(Icons.arrow_upward);
  Icon downIcon = Icon(Icons.arrow_downward);
  PanelController pc = PanelController();
  PermissionStatus? status;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final Dio _dio = Dio();
  String? _fileName;

  Future<PermissionStatus> _requestPermissions() async {
    var permission = await Permission.storage.status;

    if (permission != PermissionStatus.granted) {
      await Permission.storage.request().then((value) {
        permission = value;
      });
    }

    return permission;
  }

  Future<Directory?> _getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        // ignore: avoid_slow_async_io
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err) {
      setState(() {
        progress = 'Problem with getting the directory. Try to restart the app';
      });
    }
    return directory;
  }

  Future<void> _download() async {
    await _getDownloadPath().then((Directory? dir) async {
      if (dir != null) {
        final isPermissionStatus = await _requestPermissions();
        final ib = context.read<InternetBloc>();
        await ib.checkInternet();
        if (ib.hasInternet) {
          if (isPermissionStatus.isGranted) {
            final savePath = path.join(dir.path, _fileName);
            await _startDownload(savePath);
          } else {
            askOpenSettingsDialog();
          }
        } else {
          setState(() {
            progress = 'Please check your network connection!';
          });
        }
      } else {
        setState(() {
          progress =
              'Problem with getting the directory. Try to restart the app';
        });
      }
    });
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        progress =
            "Downloading: ${(received / total * 100).toStringAsFixed(0)}" + "%";
      });
    }
  }

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };

    try {
      final response = await _dio.download(widget.d.imagelUrl!, savePath,
          onReceiveProgress: _onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      setState(() {
        progress = 'Downloaded Successfully';
      });
      openCompleteDialog();
      await _showNotification(result);
    }
  }

  Future<void> _onSelectNotification(String json) async {
    final obj = jsonDecode(json);

    if (obj['isSuccess']) {
      OpenFile.open(obj['filePath']);
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('${obj['error']}'),
        ),
      );
    }
  }

  Future<void> _showNotification(Map<String, dynamic> downloadStatus) async {
    final String path = downloadStatus['filePath'];
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(path),
    );
    final String channelId = 'download';
    final String channelName = 'download';
    final int notificationId = widget.d.timestamp.hashCode;
    final android = AndroidNotificationDetails(
      channelId,
      channelName,
      priority: Priority.high,
      importance: Importance.max,
      subText: _fileName,
      styleInformation: bigPictureStyleInformation,
    );
    //final iOS = IOSNotificationDetails();
    final platform = NotificationDetails(android: android);
    final json = jsonEncode(downloadStatus);
    final isSuccess = downloadStatus['isSuccess'];

    await flutterLocalNotificationsPlugin.show(
        notificationId, // notification id
        isSuccess ? 'Download Success' : 'Failure',
        isSuccess
            ? 'Image has been downloaded successfully! Click here to open it'
            : 'There was an error while downloading the file.',
        platform,
        payload: json);
  }

  @override
  void initState() {
    super.initState();
    _fileName = '${widget.d.category}${widget.d.timestamp}.png';
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final initSettings = InitializationSettings(android: android);

    flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onSelectNotification: (payload) => _onSelectNotification(payload!),
    );
  }

  void openSetDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('SET AS'),
          contentPadding:
              EdgeInsets.only(left: 30, top: 40, bottom: 20, right: 40),
          children: <Widget>[
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.format_paint, Colors.blueAccent),
              title: Text('Set As Lock Screen'),
              onTap: () async {
                await _setLockScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.donut_small, Colors.pinkAccent),
              title: Text('Set As Home Screen'),
              onTap: () async {
                await _setHomeScreen();
                Navigator.pop(context);
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.all(0),
              leading: circularButton(Icons.compare, Colors.orangeAccent),
              title: Text('Set As Both'),
              onTap: () async {
                await _setBoth();
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 40,
            ),
            Center(
              child: TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            )
          ],
        );
      },
    );
  }

  //lock screen procedure
  _setLockScreen() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.imageDownloadProgress(widget.d.imagelUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting Your Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.lockScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });

      Fluttertoast.showToast(
          msg: "Wallpaper Set", toastLength: Toast.LENGTH_LONG);

      //openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(
          msg: "Some Error Occured", toastLength: Toast.LENGTH_LONG);
      print("Some Error");
    });
  }

  // home screen procedure
  _setHomeScreen() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.imageDownloadProgress(widget.d.imagelUrl!);
    progressString.listen((data) {
      setState(() {
        //res = data;
        downloading = true;
        progress = 'Setting Your Home Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.homeScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });
      Fluttertoast.showToast(
          msg: "Wallpaper Set", toastLength: Toast.LENGTH_LONG);
      //openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(
          msg: "Some Error Occured", toastLength: Toast.LENGTH_LONG);
      print("Some Error");
    });
  }

  // both lock screen & home screen procedure
  _setBoth() {
    Platform.isIOS
        ? setState(() {
            progress = 'iOS is not supported';
          })
        : progressString = Wallpaper.imageDownloadProgress(widget.d.imagelUrl!);
    progressString.listen((data) {
      setState(() {
        downloading = true;
        progress = 'Setting your Both Home & Lock Screen\nProgress: $data';
      });
      print("DataReceived: " + data);
    }, onDone: () async {
      progress = await Wallpaper.bothScreen();
      setState(() {
        downloading = false;
        progress = progress;
      });
      Fluttertoast.showToast(
          msg: "Wallpaper Set", toastLength: Toast.LENGTH_LONG);
      // openCompleteDialog();
    }, onError: (error) {
      setState(() {
        downloading = false;
      });
      Fluttertoast.showToast(
          msg: "Some Error Occured", toastLength: Toast.LENGTH_LONG);
      print("Some Error");
    });
  }

  void openCompleteDialog() async {
    AwesomeDialog(
            context: context,
            dialogType: DialogType.SUCCES,
            title: 'Complete',
            animType: AnimType.SCALE,
            padding: EdgeInsets.all(30),
            body: Center(
              child: Container(
                  alignment: Alignment.center,
                  height: 80,
                  child: Text(
                    progress,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  )),
            ),
            btnOkText: 'Ok',
            dismissOnTouchOutside: false,
            btnOkOnPress: () {
              // context.read<AdsBloc>().showInterstitialAdAdmob();        //-------admob--------
              //context.read<AdsBloc>().showFbAdd();                        //-------fb--------
            })
        .show();
  }

  askOpenSettingsDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Grant Storage Permission to Download'),
            content: Text(
                'You have to allow storage permission to download any wallpaper fro this app'),
            contentTextStyle:
                TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
            actions: [
              TextButton(
                child: Text('Open Settins'),
                onPressed: () async {
                  Navigator.pop(context);
                  await openAppSettings();
                },
              ),
              TextButton(
                child: Text('Close'),
                onPressed: () async {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    final DataBloc db = Provider.of<DataBloc>(context, listen: false);

    return Scaffold(
        key: _scaffoldKey,
        body: SlidingUpPanel(
          controller: pc,
          color: Colors.transparent,
          minHeight: 120,
          maxHeight: 450,
          backdropEnabled: false,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          body: panelBodyUI(h, w),
          panel: panelUI(db),
          onPanelClosed: () {
            setState(() {
              dropIcon = upIcon;
            });
          },
          onPanelOpened: () {
            setState(() {
              dropIcon = downIcon;
            });
          },
        ));
  }

  // floating ui
  Widget panelUI(db) {
    if (Platform.isIOS) {
      return Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                width: double.infinity,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: dropIcon,
                ),
              ),
              onTap: () {
                pc.isPanelClosed ? pc.open() : pc.close();
              },
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Config().hashTag,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${widget.d.category} Wallpaper',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      // //Text(
                      // 'y $credits',
                      //style: TextStyle(color: Colors.white, fontSize: 14),
                      //),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 22,
                      ),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('contents')
                            .doc(widget.d.timestamp)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snap) {
                          if (!snap.hasData) return _buildLoves(0);
                          return _buildLoves(snap.data['loves']);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey[400]!,
                                    blurRadius: 10,
                                    offset: Offset(2, 2))
                              ]),
                          child: Icon(
                            Icons.donut_small,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          _download();
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Download',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 5,
                      height: 30,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        progress,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 40,
            )
          ],
        ),
      );
    } else {
      return Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                width: double.infinity,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: dropIcon,
                ),
              ),
              onTap: () {
                pc.isPanelClosed ? pc.open() : pc.close();
              },
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        Config().hashTag,
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Text(
                        '${widget.d.category} Wallpaper',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      // //Text(
                      // 'y $credits',
                      //style: TextStyle(color: Colors.white, fontSize: 14),
                      //),
                    ],
                  ),
                  Spacer(),
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.favorite,
                        color: Colors.pinkAccent,
                        size: 22,
                      ),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('contents')
                            .doc(widget.d.timestamp)
                            .snapshots(),
                        builder: (context, AsyncSnapshot snap) {
                          if (!snap.hasData) return _buildLoves(0);
                          return _buildLoves(snap.data['loves']);
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey[400]!,
                                    blurRadius: 10,
                                    offset: Offset(2, 2))
                              ]),
                          child: Icon(
                            Icons.format_paint,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () async {
                          final ib = context.read<InternetBloc>();
                          await context.read<InternetBloc>().checkInternet();
                          if (ib.hasInternet == false) {
                            setState(() {
                              progress = 'Check your internet connection!';
                            });
                          } else {
                            openSetDialog();
                          }
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Set Wallpaper',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: <Widget>[
                      InkWell(
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                              color: Colors.pinkAccent,
                              shape: BoxShape.circle,
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey[400]!,
                                    blurRadius: 10,
                                    offset: Offset(2, 2))
                              ]),
                          child: Icon(
                            Icons.donut_small,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          _download();
                        },
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        'Download',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 5,
                      height: 30,
                      color: Colors.blueAccent,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        progress,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                )),
            SizedBox(
              height: 40,
            )
          ],
        ),
      );
    }
  }

  Widget _buildLoves(loves) {
    return Text(
      loves.toString(),
      style: TextStyle(color: Colors.white, fontSize: 16),
    );
  }

  // background ui
  Widget panelBodyUI(h, w) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    return Stack(
      children: <Widget>[
        Container(
          height: h,
          width: w,
          child: Hero(
            tag: widget.heroTag,
            child: CachedNetworkImage(
              imageUrl: widget.d.imagelUrl!,
              imageBuilder: (context, imageProvider) => Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.cover)),
              ),
              placeholder: (context, url) => Icon(Icons.image),
              errorWidget: (context, url, error) =>
                  Center(child: Icon(Icons.error)),
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 20,
          child: InkWell(
            child: Container(
                height: 40,
                width: 40,
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: _buildLoveIcon(sb.uid)),
            onTap: () {
              _loveIconPressed();
            },
          ),
        ),
        Positioned(
          top: 50,
          right: 70,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.report_problem,
                size: 25,
              ),
            ),
            onTap: () {
              showAlertDialog(context);
            },
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: InkWell(
            child: Container(
              height: 40,
              width: 40,
              decoration:
                  BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(
                Icons.close,
                size: 25,
              ),
            ),
            onTap: () {
              //_showInterstitialAd();
              Navigator.pop(context);
            },
          ),
        )
      ],
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons

    Widget email = TextButton(
      child: Text("Email"),
      onPressed: () {
        FlutterClipboard.copy("masterjain@icloud.com").then((result) {
          final snackBar = SnackBar(
            content: Text('Email Copied'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {},
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      },
    );
    Widget close = TextButton(
      child: Text("Close"),
      onPressed: () {
        Navigator.pop(context);
      },
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
              //instagram,
              email,
              close,
            ],
          );
        });
  }

  Widget _buildLoveIcon(uid) {
    final sb = context.watch<SignInBloc>();
    if (sb.guestUser == false) {
      return StreamBuilder(
        stream: firestore.collection('users').doc(uid).snapshots(),
        builder: (context, AsyncSnapshot snap) {
          if (!snap.hasData) return LoveIcon().greyIcon;
          List d = snap.data['loved items'];

          if (d.contains(widget.d.timestamp)) {
            return LoveIcon().pinkIcon;
          } else {
            return LoveIcon().greyIcon;
          }
        },
      );
    } else {
      return LoveIcon().greyIcon;
    }
  }

  _loveIconPressed() async {
    final sb = context.read<SignInBloc>();
    if (sb.guestUser == false) {
      context
          .read<UserBloc>()
          .handleLoveIconClick(context, widget.d.timestamp, sb.uid);
    } else {
      await showGuestUserInfo(context);
    }
  }
}
