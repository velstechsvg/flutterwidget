import 'package:flutter/material.dart';



double circularRadius = 15.0;
class CarouselWithIndicator extends StatefulWidget{

  CarouselWithIndicator({Key? key}): super(key: key);

  @override
  State<StatefulWidget> createState() {
   return  _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
 // final HomeController controller = Get.find();
  late PageController pagecontroller;
  int _currentSliderIndex=0;
  double _imageSize = 105.0;
  @override
  void initState() {
    pagecontroller = PageController();
    Future.delayed(Duration(milliseconds: 5)).then((value){
      pagecontroller.jumpToPage(_currentSliderIndex);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(children: [

      SizedBox(height: 15,),

      SizedBox(height: 20,),
    ]);
  }



}

