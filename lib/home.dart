import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'add.dart';




class HomePage extends StatefulWidget {
  final User? user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CollectionReference database;

  @override
  void initState() {
    super.initState();
    database = FirebaseFirestore.instance
        .collection('user')
        .doc(widget.user!.uid)
        .collection('Product');
  }

  /*Future<int> countDocuments() async {
    QuerySnapshot _myDoc =
    await database.get();
    List<DocumentSnapshot> _myDocCount = _myDoc.docs;
    return _myDocCount.length;
  }*/

  // void dialog(
  //     String photoURL, String title, DateTime date, String description) {
  //   showDialog(
  //       context: context,
  //       barrierDismissible: true,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10.0)),
  //           title: Row(
  //             children: <Widget>[
  //               SizedBox(
  //                 width: 70,
  //                 height: 70,
  //                 child: ClipOval(
  //                   child: Image.network(photoURL, fit: BoxFit.fill),
  //                 ),
  //               ),
  //               SizedBox(
  //                 width: 194,
  //                 child: Column(
  //                   children: <Widget>[
  //                     Text(
  //                       title,
  //                       style: const TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(
  //                       height: 5,
  //                     ),
  //                     Text(
  //                       '${DateFormat('yyyy').format(date)}.${date.month}.${date.day} 까지',
  //                       style: const TextStyle(
  //                           fontWeight: FontWeight.bold, fontSize: 14),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: <Widget>[
  //               Text(
  //                 description,
  //               ),
  //             ],
  //           ),
  //           actions: <Widget>[
  //             SizedBox(
  //               width: 80,
  //               height: 50,
  //               child: ElevatedButton(
  //                 style: ElevatedButton.styleFrom(
  //                     primary: const Color(0xFF5B836A),
  //                     shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(15.0),
  //                     )
  //                 ),
  //                 child: const Text("확인"),
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //               ),
  //             ),
  //           ],
  //         );
  //       });
  // }

  List<InkWell> _buildListCards(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    final ThemeData theme = Theme.of(context);

    return snapshot.data!.docs.map((DocumentSnapshot document) {
      DateTime _dateTime =
      DateTime.parse(document['expirationDate'].toDate().toString());
      return InkWell(
        onTap: () {
          // dialog(document['photoUrl'], document['productName'], _dateTime,
          //     document['description']);
        },
        child: Container(
            margin: const EdgeInsets.only(bottom: 25),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFB2DEB8),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: ClipOval(
                    child:
                    Image.network(document['photoUrl'], fit: BoxFit.fill),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 174,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        document['productName'],
                        style: theme.textTheme.headline6,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${DateFormat('yyyy').format(_dateTime)}.${_dateTime.month}.${_dateTime.day}',
                        style: theme.textTheme.subtitle2,
                      ),
                    ],
                  ),
                ),
                IconButton(
                    icon: const Icon(
                      Icons.delete,
                    ),
                    iconSize: 30,
                    color: Colors.white,
                    onPressed: () async {
                      database.doc(document.id).delete();
                      FirebaseStorage.instance
                          .refFromURL(document['photoUrl'])
                          .delete();
                    }),
              ],
            )),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('나의 냉장고'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: () async {
            // int count = await countDocuments();

          },
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: database.orderBy('expirationDate', descending: false).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const Center(
                      child: Text('Loading...'),
                    );
                  default:
                    return ListView(
                        padding: const EdgeInsets.all(16.0),
                        children:
                        _buildListCards(context, snapshot) // Changed code
                    );
                }
              },
            ),
          ),
        ],
      ),


      floatingActionButton: SizedBox(
        width: 350,
        height: 70,
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xFF5B836A),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute<void>(builder: (BuildContext context) {
                  return AddProduct(
                    user: widget.user,
                  );
                }));
          },
          label: const Text(
            '새 음식 추가',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          icon: const Icon(
            Icons.add,
            size: 28,
            color: Colors.white,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
