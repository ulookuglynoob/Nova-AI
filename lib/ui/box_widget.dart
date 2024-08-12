import 'package:flutter/material.dart';
import 'package:nova/models/recognition.dart';

class BoxWidget extends StatelessWidget {
  final Recognition result;

  const BoxWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.primaries[
        (result.label.length + result.label.codeUnitAt(0) + result.id) %
            Colors.primaries.length];

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      // Flip the coordinates
      left: screenWidth - result.renderLocation.right,
      top: screenHeight - result.renderLocation.bottom,
      width: result.renderLocation.width,
      height: result.renderLocation.height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: const BorderRadius.all(Radius.circular(2)),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: FittedBox(
            child: Container(
              color: color,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(result.label),
                  Text(" ${result.score.toStringAsFixed(2)}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
