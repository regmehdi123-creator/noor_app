import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';

import '../../core/colors.dart';

class GoldContainer extends StatelessWidget {
  final String title;
  final String dalile;
  final String source;

  const GoldContainer({super.key, required this.title, required this.dalile, required this.source});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cream.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: secondColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: secondColor.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -40,
              right: -40,
              child: Icon(FlutterIslamicIcons.quran, size: 180, color: secondColor.withValues(alpha: 0.05)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: secondColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: secondColor.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: TextStyle(color: secondColor.withValues(alpha: 0.9), fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                   Text(
                    dalile,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                      fontFamily: 'serif',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: secondColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:  Text(
                      source,
                      style: const TextStyle(color: Colors.black87, fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}