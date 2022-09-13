import 'package:flutter/cupertino.dart';
import 'package:untitled/test.dart';
import 'customer_camera.dart';

class Routes{
  Routes._();

  static const String camera = '/camera';

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    camera: (BuildContext context) => const CameraPage(cameras: [],),
  };


}