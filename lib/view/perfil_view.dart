import 'package:flutter/material.dart';

class PerfilView extends StatefulWidget {
  const new({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
      ),
    );
  }
}