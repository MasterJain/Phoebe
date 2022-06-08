import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phoebe_admin/blocs/admin_bloc.dart';
import 'package:phoebe_admin/utils/dialog.dart';
import 'package:phoebe_admin/utils/empty.dart';
import 'package:phoebe_admin/utils/styles.dart';
import 'package:phoebe_admin/utils/toast.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController? controller;
  DocumentSnapshot? _lastVisible;
  late bool _isLoading;
  List<DocumentSnapshot> _snap = [];
  List _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final String collectionName = 'categories';
  bool? _hasData;

  @override
  void initState() {
    controller = new ScrollController()..addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null)
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
    else
      data = await firestore
          .collection(collectionName)
          .orderBy('timestamp', descending: true)
          .startAfter([_lastVisible!['timestamp']])
          .limit(10)
          .get();

    if (data.docs.length > 0) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasData = true;
          _data.addAll(data.docs);
        });
      }
    } else {
      if (_lastVisible == null) {
        setState(() {
          _isLoading = false;
          _hasData = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
        });
        openToast(context, 'No more content available');
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller!.position.pixels == controller!.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  refreshData() async {
    setState(() {
      _data.clear();
      _snap.clear();
      _lastVisible = null;
    });
    await _getData();
  }

  handleDelete(context, timestamp1) {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              Text('Delete?',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w900)),
              SizedBox(
                height: 10,
              ),
              Text('Want to delete this category from the database?',
                  style: TextStyle(
                      color: Colors.grey[900],
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  TextButton(
                    style: buttonStyle(Colors.redAccent),
                    child: Text(
                      'Yes',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      if (ab.userType == 'tester') {
                        Navigator.pop(context);
                        openDialog(context, 'You are a Tester',
                            'Only admin can delete contents');
                      } else {
                        await ab
                            .deleteCategory(timestamp1)
                            .then((value) => ab.getCategories())
                            .then(
                                (value) => ab.decreaseCount('categories_count'))
                            .then((value) =>
                                openToast(context, 'Deleted Successfully'));
                        refreshData();
                        Navigator.pop(context);
                      }
                    },
                  ),
                  SizedBox(width: 10),
                  TextButton(
                    style: buttonStyle(Colors.deepPurpleAccent),
                    child: Text(
                      'No',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[200],
      floatingActionButton: _floatingActionButton(),
      body: Container(
        margin: EdgeInsets.only(left: 30, right: 30, top: 30),
        padding: EdgeInsets.only(
          left: w * 0.05,
          right: w * 0.20,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey[300]!, blurRadius: 10, offset: Offset(3, 3))
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: _hasData == false
                  ? emptyPage(Icons.content_paste,
                      'No categories found.\nUpload categories first!')
                  : RefreshIndicator(
                      child: ListView.separated(
                        padding: EdgeInsets.only(top: 30, bottom: 20),
                        controller: controller,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _data.length + 1,
                        separatorBuilder: (BuildContext context, int index) =>
                            SizedBox(
                          height: 10,
                        ),
                        itemBuilder: (_, int index) {
                          if (index < _data.length) {
                            return dataList(_data[index]);
                          }
                          return Center(
                            child: new Opacity(
                              opacity: _isLoading ? 1.0 : 0.0,
                              child: new SizedBox(
                                  width: 32.0,
                                  height: 32.0,
                                  child: new CircularProgressIndicator()),
                            ),
                          );
                        },
                      ),
                      onRefresh: () async {
                        await refreshData();
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget dataList(d) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          height: 150,
          width: MediaQuery.of(context).size.width * 0.80,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                  image: NetworkImage(d['thumbnail']), fit: BoxFit.cover)),
          child: Text(
            d['name'].toUpperCase(),
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        Positioned(
          top: 50,
          right: 25,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  handleDelete(context, d['timestamp']);
                }),
          ),
        )
      ],
    );
  }

  Widget _floatingActionButton() {
    return FloatingActionButton.extended(
      label: Text('Add Category'),
      icon: Icon(Icons.add),
      backgroundColor: Colors.deepPurpleAccent,
      onPressed: () {
        openUploadDialog();
      },
    );
  }

  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var thumbnailCtrl = TextEditingController();
  String? timestamp;

  Future getDate() async {
    DateTime now = DateTime.now();
    String _timestamp = DateFormat('yyyyMMddHHmmss').format(now);
    setState(() {
      timestamp = _timestamp;
    });
  }

  Future saveToDatabase() async {
    final DocumentReference ref =
        firestore.collection('categories').doc(timestamp);
    await ref.set({
      'name': nameCtrl.text,
      'thumbnail': thumbnailCtrl.text,
      'timestamp': timestamp,
    });
  }

  clearTextfields() {
    nameCtrl.clear();
    thumbnailCtrl.clear();
  }

  openUploadDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: EdgeInsets.all(100),
            children: <Widget>[
              Text(
                'Add Category to Database',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              SizedBox(
                height: 50,
              ),
              Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: inputDecoration(
                            'Enter Category Name', 'Category Name', nameCtrl),
                        controller: nameCtrl,
                        validator: (value) {
                          if (value!.isEmpty) return 'Category Name is empty';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        decoration: inputDecoration('Enter Thumbnail Url',
                            'Thumbnail Url', thumbnailCtrl),
                        controller: thumbnailCtrl,
                        validator: (value) {
                          if (value!.isEmpty) return 'Url is empty';
                          return null;
                        },
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Center(
                          child: Row(
                        children: <Widget>[
                          TextButton(
                            style: buttonStyle(Colors.deepPurpleAccent),
                            child: Text(
                              'Add',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () async {
                              handleUpload();
                            },
                          ),
                          SizedBox(width: 10),
                          TextButton(
                            style: buttonStyle(Colors.redAccent),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ))
                    ],
                  ))
            ],
          );
        });
  }

  handleUpload() async {
    final AdminBloc ab = Provider.of<AdminBloc>(context, listen: false);
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (ab.userType == 'tester') {
        Navigator.pop(context);
        openDialog(
            context, 'You are a Tester', 'Only admin can upload categories');
      } else {
        await getDate()
            .then((value) => saveToDatabase())
            .then((value) => ab.increaseCount('categories_count'))
            .then((value) => ab.getCategories());
        openToast(context, 'Added successfully');
        refreshData();
        clearTextfields();
        Navigator.pop(context);
      }
    }
  }
}
