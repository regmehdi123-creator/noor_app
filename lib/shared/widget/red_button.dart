import 'package:flutter/material.dart';

class RedButton extends StatelessWidget{
  final String title;
  final VoidCallback press;
  const RedButton({super.key, required this.title, required this.press});
  @override
  Widget build(BuildContext context) {
    return InkWell(
    onTap: press
    ,child: Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 7,vertical: 3),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(25)
      ),
      child:  Text(textAlign: TextAlign.center,title,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20),),
    ));
  }

}