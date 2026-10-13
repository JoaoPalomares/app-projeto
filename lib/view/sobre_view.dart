import 'package:flutter/material.dart';

class SobreView extends StatefulWidget {
  const new({super.key});

  @override
  State<SobreView> createState() => _SobreViewState();
}

class _SobreViewState extends State<SobreView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
      ),
    );
  }
}