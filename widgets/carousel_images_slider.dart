import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:yottachat/constant.dart';
import 'package:yottachat/resources/app_colors.dart';

import 'package:yottachat/widgets/smooth_page_indicator/slide_effect.dart';
import 'flutter_spinkit/three_bounce.dart';
import 'smooth_page_indicator/smooth_page_indicator.dart';



double circularRadius = 15.0;
class CarouselImagesWithIndicator extends StatefulWidget{
  final List<dynamic>? sliderData;
  final int? selectedIndex;
  final String? prefixURL;

  CarouselImagesWithIndicator({Key? key, @required this.sliderData, this.selectedIndex,this.prefixURL}): super(key: key);

  @override
  State<StatefulWidget> createState() {
   return  _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselImagesWithIndicator> {
 // final HomeController controller = Get.find();
  late PageController pagecontroller;
  int _currentSliderIndex=0;

  @override
  void initState() {
    _currentSliderIndex = widget.selectedIndex!;
    pagecontroller = PageController();
    Future.delayed(Duration(milliseconds: 5)).then((value){
      pagecontroller.jumpToPage(_currentSliderIndex);
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(children: [
        Container(
          height: 8.0*MediaQuery.of(context).size.height/10,
          child: PageView(
            pageSnapping: true,
            controller: pagecontroller,
            children: widget.sliderData!.map((data) {
              return bannerUI(data);
            }).toList(),
            onPageChanged: (index){
              setState(() {
                _currentSliderIndex = index;
              });
            },
          ),
        ),
        SizedBox(height: 20,),
        AnimatedSmoothIndicator(
          activeIndex: _currentSliderIndex,
          count:  widget.sliderData!.length,
          effect:  ScrollingDotsEffect(
              activeDotColor: AppColors.primaryColor,
              dotColor: AppColors.sliderDotColor,
              dotWidth: 7.0,
              dotHeight: 7.0
          ),
        ),
        SizedBox(height: 20,),
      ]),
    );
  }

  Widget bannerUI(dynamic data){
    String _imgUrl;
    if(data is String)
      _imgUrl = data;
    else
      _imgUrl = "";

    if(widget.prefixURL!=null)
      _imgUrl = widget.prefixURL!+_imgUrl;

    return  _imgUrl!=null && _imgUrl.isNotEmpty?
    CachedNetworkImage(
      imageUrl: _imgUrl,
      imageBuilder: (context, imageProvider) => InteractiveViewer(
        panAxis: PanAxis.aligned, panEnabled: false,
        maxScale: 10.0,
        minScale: 0.1,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(circularRadius),
            image: DecorationImage(
                image: imageProvider),
          ),
        ),
      ),
      placeholder: (context, url) => SpinKitThreeBounce(
        color: AppColors.primaryColor,
        size: 22.0,
      ),
    ): const SizedBox.shrink();
  }




}

