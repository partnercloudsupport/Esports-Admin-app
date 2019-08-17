
import 'package:flutter/material.dart';

class Themes{
  static var theme1 = Map<String,Color>();
  Themes(){
    Themes.theme1["PrimaryColor"] = Color(0xFF222255);
    Themes.theme1["CardColor"] = Color(0xFF151935);
    Themes.theme1["TableColor"] = Color.fromRGBO(28, 32, 66, 1);
    Themes.theme1["FirstGradientColor"] = Color.fromRGBO(255, 113, 97, 1);
    Themes.theme1["SecondGradientColor"] = Color.fromRGBO(255, 0, 124, 1);
    Themes.theme1["TextColor"] = Colors.white;
    Themes.theme1["SubTextColor"] = Color.fromRGBO(151, 155, 182, 1);
    Themes.theme1["HighLightColor"] = Color(0xFF263160);
    Themes.theme1["TextFieldFillColor"] = Color(0xFF263160);
    Themes.theme1["TextPlaceholderColor"] = Color(0xFF7D8191);
    Themes.theme1["NewsBoardColor"] = Color(0xFF1C2340);

  }
}