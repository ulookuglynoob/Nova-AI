import 'package:flutter/material.dart';
import 'package:nova/models/screen_params.dart';
import 'package:nova/ui/detector_widget.dart';

/// [HomeView] stacks [DetectorWidget]
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenParams.screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      key: GlobalKey(),
      backgroundColor: Colors.white,
      body: const DetectorWidget(),
    );
  }
}
