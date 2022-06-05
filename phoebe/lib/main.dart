import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phoebe_app/blocs/ads_bloc.dart';
import 'package:provider/provider.dart';

import './blocs/bookmark_bloc.dart';
import './blocs/data_bloc.dart';
import './blocs/internet_bloc.dart';
import './blocs/sign_in_bloc.dart';
import './blocs/userdata_bloc.dart';
import './pages/home.dart';
import './pages/sign_in_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<DataBloc>(
            create: (context) => DataBloc(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<UserBloc>(
            create: (context) => UserBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<AdsBloc>(
            create: (context) => AdsBloc(),
          ),
        ],
        child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Poppins',
              appBarTheme: AppBarTheme(
                color: Colors.white,
                elevation: 0,
                iconTheme: IconThemeData(
                  color: Colors.black,
                ),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                toolbarTextStyle: TextTheme(
                        headline6: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600))
                    .bodyText2,
                titleTextStyle: TextTheme(
                        headline6: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600))
                    .headline6,
              ),
              textTheme: TextTheme(
                  headline6: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
              )),
            ),
            home: MyApp1()));
  }
}

class MyApp1 extends StatelessWidget {
  const MyApp1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return sb.isSignedIn == false && sb.guestUser == false
        ? SignInPage()
        : HomePage();
  }
}
