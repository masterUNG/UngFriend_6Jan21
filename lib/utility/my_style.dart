import 'package:flutter/material.dart';

class MyStyle {
  InputDecoration inputDecoration(String string, Icon icon) => InputDecoration(
        labelText: string,
        prefixIcon: icon,
      );

  MyStyle();
}
