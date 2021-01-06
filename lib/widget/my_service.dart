import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ungfriend/models/postmodel.dart';
import 'package:ungfriend/utility/dialog.dart';

class MyService extends StatefulWidget {
  @override
  _MyServiceState createState() => _MyServiceState();
}

class _MyServiceState extends State<MyService> {
  String post, namePost, uidPost;
  List<PostModel> postModels = List();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    aboutNoti();
    readAllPost();
  }

  Future<Null> aboutNoti() async {
    await Firebase.initializeApp().then((value) async {
      FirebaseMessaging messaging = FirebaseMessaging();

      String token = await messaging.getToken();
      print('token ====>> $token');

      await messaging.configure(
        onMessage: (message) {
          print(
              'onMessage คือ ข้อความตอนเปิดแอพคาอยู่ ==>>> ${message.toString()}');
          Map<String, dynamic> map = message['notification'];
          print('map ==>>> ${map.toString()}');
          String body = map['body'];
          String title = map['title'];
          print('title = $title, message = $body');
        },
        onResume: (message) {
          print('onResume pause app อยู่ ==>>> ${message.toString()}');
        },
        onLaunch: (message) {
          print('onLunch');
          normalDialog(context, 'onLunch Work ==>>> ${message.toString()}');
        },
      );
    });
  }

  Future<Null> readAllPost() async {
    if (postModels.length != 0) {
      postModels.clear();
    }

    await Firebase.initializeApp().then((value) async {
      await FirebaseAuth.instance.authStateChanges().listen((event) async {
        uidPost = event.uid;
        namePost = event.displayName;
        String email = event.email;
        print('namePost = $namePost, uidPost = $uidPost, email = $email');

        await FirebaseFirestore.instance
            .collection('post')
            .snapshots()
            .listen((event) {
          for (var item in event.docs) {
            PostModel model = PostModel.fromMap(item.data());
            setState(() {
              postModels.add(model);
            });
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Service'),
        actions: [buildISignOut()],
      ),
      body: Stack(
        children: [
          buildListPost(),
          buildPostAll(),
        ],
      ),
    );
  }

  Widget buildListPost() {
    return postModels.length == 0
        ? Text('No Post')
        : ListView.builder(
            itemCount: postModels.length,
            itemBuilder: (context, index) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(postModels[index].post),
                    Text(postModels[index].namepost),
                  ],
                ),
              ),
            ),
          );
  }

  Column buildPostAll() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 250,
                child: TextField(
                  onChanged: (value) => post = value.trim(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (post?.isEmpty ?? true) {
                    normalDialog(context, 'Post not Empty');
                  } else {
                    insertPost();
                  }
                },
                child: Text('Post All'),
              )
            ],
          ),
        ),
      ],
    );
  }

  IconButton buildISignOut() => IconButton(
        icon: Icon(Icons.exit_to_app),
        onPressed: () async {
          await Firebase.initializeApp().then((value) async {
            await FirebaseAuth.instance.signOut().then(
                  (value) => Navigator.pushNamedAndRemoveUntil(
                      context, '/authen', (route) => false),
                );
          });
        },
      );

  Future<Null> insertPost() async {
    await Firebase.initializeApp().then((value) async {
      PostModel model =
          PostModel(namepost: namePost, post: post, uidpost: uidPost);
      Map<String, dynamic> data = model.toMap();
      await FirebaseFirestore.instance
          .collection('post')
          .doc()
          .set(data)
          .then((value) => readAllPost());
    });
  }
}
