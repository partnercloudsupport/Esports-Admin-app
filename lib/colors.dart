
import 'package:flutter/material.dart';

class Themes{
  static var theme1 = Map<String,Color>();
  Themes(){
    Themes.theme1['CardColor'] = const Color(0xFF333333);
    Themes.theme1['PrimaryColor'] = const Color(0xFF5A5454);
    Themes.theme1['TableColor'] = const Color.fromRGBO(28, 32, 66, 1);
    Themes.theme1['FirstGradientColor'] = const Color(0xFF3A3897);
    Themes.theme1['SecondGradientColor'] = const Color(0xFFA3A1FF);
    Themes.theme1['TextColor'] = Colors.white;
    Themes.theme1['SubTextColor'] = const Color.fromRGBO(151, 155, 182, 1);
    Themes.theme1['HighLightColor'] = const Color(0xFF263160);
    Themes.theme1['TextFieldFillColor'] = const Color(0xFF808080);
    Themes.theme1['TextPlaceholderColor'] = const Color(0xFF7D8191);
    Themes.theme1['NewsBoardColor'] = const Color(0xFF1C2340);

  }
}