import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;


class AddProduct extends StatefulWidget {
  final User? user;
  const AddProduct({Key? key, required this.user}) : super(key: key);

  @override
  _AddProductState createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _productnameController = TextEditingController();
  final _descriptionController = TextEditingController();
  PickedFile? _image;
  late Reference firebaseStorageRef;
  late UploadTask uploadTask;
  late var downloadUrl;
  // late var alarm;
  DateTime _selectedDate = DateTime.now();
  static List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
  late CollectionReference database;

  @override
  void initState() {
    super.initState();
    database =
        FirebaseFirestore.instance.collection('user').doc(widget.user!.uid).collection('Product');
  }

  Container productSetting() {
    return Container(
      height: 178,
      margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
      decoration: BoxDecoration(
          color: Color(0xFF8EB680), borderRadius: BorderRadius.circular(15.0)),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFB2DEB8)),
                child: _image == null
                    ? IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 40,
                  ),
                  onPressed: () async {
                    var image = await ImagePicker.platform
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      _image = image!;
                    });
                  },
                )
                    : ClipOval(
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var image = await ImagePicker.platform
                      .pickImage(source: ImageSource.gallery);
                  setState(() {
                    _image = image!;
                  });
                },
                child: const Text(
                  "사진 추가",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 180,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _productnameController,
                  decoration: const InputDecoration(
                      filled: false,
                      labelText: 'Product Name',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      filled: false,
                      labelText: 'Description',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Container dateSetting() {
    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
      decoration: BoxDecoration(
          color: const Color(0xFF8EB680), borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 35,
          ),
          Text(
            '설정된 날짜 : ${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 ${days[_selectedDate.weekday - 1]}요일',
            style: const TextStyle(
                color: Color(0xFF3C3844), fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 300,
            height: 70,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFB2DEB8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: Color(0xFF3C3844),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '날짜 설정',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF3C3844),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onPressed: () {
                  Future<DateTime?> future = showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  future.then((date) {
                    setState(() {
                      _selectedDate = date!.add(const Duration(hours: 9));
                    });
                  });
                }),
          ),
        ],
      ),
    );
  }

  Row cancelSaveButton() {
    return Row(children: [
      Expanded(
        child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "취소",
              style: TextStyle(color: Colors.white),
            )),
      ),
      Expanded(
        child: TextButton(
            onPressed: () async {
              if (_image != null) {
                firebaseStorageRef = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child(widget.user!.uid)
                    .child('${_productnameController.text}.png');

                uploadTask = firebaseStorageRef.putFile(File(_image!.path),
                    SettableMetadata(contentType: 'image/png'));

                await uploadTask.whenComplete(() => null);

                downloadUrl = await firebaseStorageRef.getDownloadURL();
              } else {
                downloadUrl =
                'https://firebasestorage.googleapis.com/v0/b/cocomong.appspot.com/o/cocomong.png?alt=media&token=139e119b-24ea-400c-b7b6-6874963a672a';
              }



              database.add({
                'productName': _productnameController.text,
                'description': _descriptionController.text,
                'expirationDate': _selectedDate,
                'photoUrl': downloadUrl,
              });

              Navigator.pop(context);
            },
            child: const Text(
              "저장",
              style: TextStyle(color: Colors.white),
            )),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    productSetting(),
                    dateSetting(),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF5B836A),
                child: cancelSaveButton(),
              )
            ],
          )),
      resizeToAvoidBottomInset: false,
    );
  }
}