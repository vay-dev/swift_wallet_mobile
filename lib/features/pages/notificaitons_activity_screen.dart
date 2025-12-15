import 'package:flutter/material.dart';

class NotificaitonsActivityScreen extends StatefulWidget {
  const NotificaitonsActivityScreen({super.key});

  @override
  State<NotificaitonsActivityScreen> createState() =>
      _NotificaitonsActivityScreenState();
}

class _NotificaitonsActivityScreenState
    extends State<NotificaitonsActivityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              /* Handle settings tap */
            },
          ),
        ],
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                'assets/images/appbar_bg.jpeg',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.0),
            width: double.infinity,
            height: 120.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25.0),
                topRight: Radius.circular(25.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
