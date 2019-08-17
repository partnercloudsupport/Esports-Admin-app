import 'package:flutter/material.dart';
import 'colors.dart';

class RepeatRotations extends StatefulWidget{
  final IconData icon;
  final Duration duration;

  RepeatRotations(this.icon,this.duration);
@override
  State<StatefulWidget> createState() {
    return RepeatRotationsState();
  }
}

class RepeatRotationsState extends State<RepeatRotations> with SingleTickerProviderStateMixin{
  AnimationController animationController;
  Widget child;

  @override
  void initState() {
    this.animationController = AnimationController(vsync: this,duration: widget.duration);
    this.animationController.repeat();
    this.child = Icon(widget.icon);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: animationController,child: this.child,);
  }
}

class FadeInFadeOutIcons extends StatefulWidget{
  final IconData icon;
  final IconData icon2;
  final Duration duration;

  FadeInFadeOutIcons(this.icon,this.icon2,this.duration);
  @override
  State<StatefulWidget> createState() {
    return FadeInFadeOutIconsState();
  }
}

class FadeInFadeOutIconsState extends State<FadeInFadeOutIcons> with SingleTickerProviderStateMixin{
  AnimationController animationController;
  Widget child;
  Animation<double> animation;
  int index = 0;


  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    this.animationController = AnimationController(vsync: this,duration: widget.duration);
//    this.animationController.repeat();
    this.animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animation.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        if (index == 0){
          this.child = Icon(widget.icon,color: Themes.theme1["CardColor"],);
          index = 1;
        } else{
          this.child = Icon(widget.icon2,color: Themes.theme1["TextPlaceholderColor"],);
          index = 0;
        }
        animationController.reverse();
      });

    } else if (status == AnimationStatus.dismissed) {
      setState(() {
        if (index == 0){
          this.child = Icon(widget.icon,color: Themes.theme1["CardColor"]);
          index = 1;
        } else{
          this.child = Icon(widget.icon2,color: Themes.theme1["TextPlaceholderColor"]);
          index = 0;
        }
        animationController.forward();
      });

    }
  });
    animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(child: FadeTransition(opacity: animation,child: this.child,),);
  }
}

