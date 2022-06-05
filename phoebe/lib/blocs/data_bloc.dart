import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:phoebe_app/models/contentmodel.dart';

class DataBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ContentModel> _alldata = [];
  List<ContentModel> get alldata => _alldata;

  List<DocumentSnapshot> _snap = [];

  List _categories = [];
  List get categories => _categories;

  getData() async {
    QuerySnapshot snap = await firestore
        .collection('contents')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .get();
    //  QuerySnapshot snap = await Firestore.instance.collection('contents')
    //  .where("timestamp", isLessThanOrEqualTo: ['timestamp'])
    //  .orderBy('timestamp', descending: true)
    //  .limit(5).getDocuments();
    List x = snap.docs;
    x.shuffle();
    _alldata.clear();
    _snap.clear();
    x.take(5).forEach((f) {
      _snap.add(f);
      //_alldata.add(f);
    });
    _alldata = _snap.map((e) => ContentModel.fromFirestore(e)).toList();
    notifyListeners();
  }

  Future getCategories() async {
    QuerySnapshot snap = await firestore.collection('categories').get();
    var x = snap.docs;

    _categories.clear();

    for (var f in x) {
      _categories.add(f);
    }
    notifyListeners();
  }
}
