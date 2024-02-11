import 'dart:math' as math;
import 'package:compass_app/neu_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;
  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.grey.shade800,
        body: Builder(
          builder: (context) {
            if (_hasPermissions) {
              return _buildCompass();
            } else {
              return _buildPermissionSheet();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return NeuCircle(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Adjust padding as needed
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: Image.asset(
                'assets/compass6.webp',
                fit: BoxFit.cover, // Ensure image covers the circle
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: ElevatedButton(
        child: const Text('Request Permissions'),
        onPressed: () {
          Permission.locationWhenInUse.request().then((ignored) {
            _fetchPermissionStatus();
          });
        },
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}