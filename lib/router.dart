import 'package:flutter/material.dart';
import 'package:ungfriend/widget/authen.dart';
import 'package:ungfriend/widget/detail_post.dart';
import 'package:ungfriend/widget/my_service.dart';
import 'package:ungfriend/widget/register.dart';

final Map<String, WidgetBuilder> routes = {
  '/authen': (BuildContext context) => Authen(),
  '/register': (BuildContext context) => Register(),
  '/myService': (BuildContext context) => MyService(),
  '/detailPost': (BuildContext context) => DetailPost(),
};
