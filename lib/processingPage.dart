import 'package:flutter/material.dart';
import 'colors.dart';

class UnderProcessingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.theme1['CardColor'],
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text('Under Process'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            Container(child: const Text(
              'League president has been notified about your interest. you will get league access once approved',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
            ),margin: const EdgeInsets.only(left: 20,right: 20),),
            const SizedBox(height: 40,),

            Container(child: Image.asset('images/processing.png')),
            const SizedBox(height: 40,),
            FlatButton(
              child: const Text(
                'Go Back',
                style: TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 18),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
