import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:noor/core/colors.dart';

class LanguageSelectCard extends StatelessWidget{
  final String title;
  final String subtitle;
  final String lang;
  final VoidCallback press;

  const LanguageSelectCard({super.key, required this.title, required this.subtitle, required this.press, required this.lang});

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(color: cream,border: Border.all(color: secondColor,width: 2),borderRadius: BorderRadius.circular(25)),
      child: ListTile(
        onTap: press,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: CountryFlag.fromLanguageCode(lang),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 17,
        ),
      ),
    );
  }

}