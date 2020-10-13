import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:flutter_compass/flutter_compass.dart';
import "package:geolocator/geolocator.dart";

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HelloWorld(),
    );
  }
}

class HelloWorld extends StatefulWidget {
  @override
  _HelloWorldState createState() => _HelloWorldState();
}

class _HelloWorldState extends State<HelloWorld>{
  static const north = 0;
  double _compas = 0;
  double _radians = 0;
  Position _position;
  String _acc = "";
  bool _flag_show = false;

  double _x = 0;
  double _z = 0;

  double avglat = 0;
  double avglon = 0;
  int avgcnt = 0;

//  ArCoreController arCoreController;
  StreamSubscription<Position> positionStream;

  void initState(){
    super.initState();

    // 方角の取得開始
//    FlutterCompass.events.listen(_onCompassData);

    //_getLocation(context);
    positionStream = getPositionStream(desiredAccuracy: LocationAccuracy.best).listen(_onGetPosition);
  }

  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello World'),),
        //body: ArCoreView(onArCoreViewCreated: _onArCoreViewCreated,),
        body: new Stack(
          children: <Widget>[
//            ArCoreView(onArCoreViewCreated: _onArCoreViewCreated,),
            new Center(
              child: new Container(
                child: new Text(_acc,
                style: new TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                )
                )
              )
            )

          ],
        )
        
        

      )
    );
  }
/*
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Hello World'),),
        //body: ArCoreView(onArCoreViewCreated: _onArCoreViewCreated,),
        body: FutureBuilder<GeolocationStatus>(
          future: Geolocator().checkGeolocationPermissionStatus(),
          builder: (BuildContext context, AsyncSnapshot<GeolocationStatus> snapshot){
            if(!snapshot.hasData){
              return const Center(child: CircularProgressIndicator());
            }
            return ArCoreView(onArCoreViewCreated: _onArCoreViewCreated,);
          }
        )
      ),
    );
  }*/

/**
 * ar core
  void _onArCoreViewCreated(ArCoreController controller){
    arCoreController = controller;

    _addSphere(arCoreController);
    //_add3DObj(arCoreController);


    //_addCylindre(arCoreController);
    //_addCube(arCoreController);
  }
 */

/**
 * ar core
  void _addSphere(ArCoreController controller){
    final material = ArCoreMaterial(
      color: Color.fromARGB(200, 66, 134, 244),);
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 1.0,);
    final node = ArCoreNode(
      shape: sphere,
      name: "sphere",
      //position: vector.Vector3(0,0,-1.6),
      //position: vector.Vector3(cos(_radians),0,sin(_radians)),
      position: vector.Vector3(0,-5,-5),
    );

    controller.addArCoreNode(node);
  }
  */

/**
 * ar core
  void _addARObject(ArCoreController controller, double x, double z){
    controller.removeNode(nodeName: "treasurebox01");
    controller.init();
    final material = ArCoreMaterial(
      color: Color.fromARGB(255, 66, 184, 244),);
    final sphere = ArCoreSphere(
      materials: [material],
      radius: 1.0,);
    final node = ArCoreNode(
      shape: sphere,
      name: "treasurebox01",
      //position: vector.Vector3(0,0,-1.6),
      //position: vector.Vector3(cos(_radians),0,sin(_radians)),
      position: vector.Vector3(x,-1,z),
    );

    controller.addArCoreNode(node);
  }
*/

/**
 * ar core
  void _removeARObject(ArCoreController controller){
    controller.removeNode(nodeName: "treasurebox01");
  }
*/

  /// 方角取得時の処理
  void _onCompassData(double c){
    debugPrint("On Compass: " + c.toString());
    _compas = c;
    //_radians = -1 * pi * ((x - north) / 180);
  }
  

  void _onGetPosition(Position position){
    print("Location " + avgcnt.toString());
    double acc = position.accuracy;
    if( position.accuracy < 25 ){
      double lat0 = position.latitude;
      double lon0 = position.longitude;
      //double lat1 = 33.565220;
      //double lon1 = 133.561518;
      //double lat1 = 33.5654042;
      //double lon1 = 133.5614302;
      double lat1 = 33.565270;
      double lon1 = 133.561719;
      lat0 = 33.565257;
      lon0 = 133.561714;

      debugPrint("Current Position  lat: " + position.latitude.toString() + "   lon: " + position.longitude.toString() + "   acc: " + position.accuracy.toString());

      double dist = distanceBetween(lat0, lon0, lat1, lon1);
      double bear = bearingBetween(lat0, lon0, lat1, lon1);
      double bear360 = (bear<0?360+bear:bear);
      double rotation = 0;
      //double rotation = toRadians(bear) - _radians;
      rotation = bear360 - _compas;
      if( rotation < 0 ) rotation = 360 + rotation;
      rotation = 360 + 90 - rotation;
      if( rotation >= 360 ) rotation = rotation - 360;
      debugPrint("Target Position  dist: " + dist.toString() + "  rot: " + rotation.toString());

      double zz = (-1 * dist * sin(toRadians(rotation)));
      double xx = ( dist * cos(toRadians(rotation)));
      debugPrint("Target Position x: " + _x.toString() + "  z: " + _z.toString());


      setState((){
        _acc = "acc: " + position.accuracy.toString() + "\ndist: " + dist.toString() + "\nrota: " + rotation.toString();
        _acc += "\nbear: " + bear.toString() + "\ncompas: " + _compas.toString();
        _acc += "\nx: " + xx.toString() + "\nz: " + zz.toString();
      });


      /*
      setState(() {
          _z = (-1 * dist * cos(rotation));
          _x = ( dist * sin(rotation));
      });*/
      //_addARObject(arCoreController);
      if( position.accuracy < 25 && dist <= 90 &&  !_flag_show ){
        //_flag_show = true;
/**
 * ar core
        _addARObject(arCoreController, xx, zz);
        */
      } else if( dist > 10 && _flag_show ){
        //_flag_show = false;
        //_removeARObject(arCoreController);
      }
    }
  }

  @override
  void dispose(){
/**
 * ar core
    arCoreController.dispose();
    */
    super.dispose();
  }

  double toRadians(degree){
    return degree * ( pi / 180 );
  }

  double toDegree(radians){
    return radians * 180 / pi;
  }

}
