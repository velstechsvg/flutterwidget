library countrycodepicker;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:yottachat/resources/app_images.dart';

import '../../resources/app_colors.dart';
import '../../resources/app_dimen.dart';
import '../custom_search_field.dart';
import '../handy_text.dart';
import '../show_done_view.dart';
import 'country.dart';
import 'function.dart';

const TextStyle _defaultItemTextStyle = const TextStyle(fontSize: AppDimen.textSize_16);
const TextStyle _defaultSearchInputStyle = const TextStyle(fontSize: AppDimen.textSize_16);
const String _kDefaultSearchHintText = 'Search country name, code';
const String countryCodePackageName = 'country_calling_code_picker';

class CountryPickerWidget extends StatefulWidget {
  /// This callback will be called on selection of a [Country].
  final ValueChanged<Country>? onSelected;

  /// [itemTextStyle] can be used to change the TextStyle of the Text in ListItem. Default is [_defaultItemTextStyle]
  final TextStyle itemTextStyle;

  /// [searchInputStyle] can be used to change the TextStyle of the Text in SearchBox. Default is [searchInputStyle]
  final TextStyle searchInputStyle;

  /// [searchInputDecoration] can be used to change the decoration for SearchBox.
  final InputDecoration? searchInputDecoration;

  /// Flag icon size (width). Default set to 32.
  final double flagIconSize;

  ///Can be set to `true` for showing the List Separator. Default set to `false`
  final bool showSeparator;

  ///Can be set to `true` for opening the keyboard automatically. Default set to `false`
  final bool focusSearchBox;

  ///This will change the hint of the search box. Alternatively [searchInputDecoration] can be used to change decoration fully.
  final String searchHintText;

  final String selectedCountry ;

  final bool isRTL ;

   const CountryPickerWidget({
    Key? key,
    this.onSelected,
    this.itemTextStyle = _defaultItemTextStyle,
    this.searchInputStyle = _defaultSearchInputStyle,
    this.searchInputDecoration,
    this.selectedCountry = "",
    this.searchHintText = _kDefaultSearchHintText,
    this.flagIconSize = 32,
    this.showSeparator = false,
    this.isRTL = false,
    this.focusSearchBox = false,
  }) : super(key: key);

  @override
  _CountryPickerWidgetState createState() => _CountryPickerWidgetState();
}

class _CountryPickerWidgetState extends State<CountryPickerWidget> {
  List<Country> _list = [];
  List<Country> _filteredList = [];
  TextEditingController _controller = new TextEditingController();
  ScrollController _scrollController = new ScrollController();
  bool _isLoading = false;
  Country? _currentCountry;

  void _onSearch(text) {
    if (text == null || text.isEmpty) {
      setState(() {
        _filteredList.clear();
        _filteredList.addAll(_list);
      });
    } else {
      setState(() {
        _filteredList = _list
            .where((element) =>
        element.name
            .toLowerCase()
            .contains(text.toString().toLowerCase()) ||
            element.callingCode
                .toLowerCase()
                .contains(text.toString().toLowerCase()) ||
            element.countryCode
                .toLowerCase()
                .startsWith(text.toString().toLowerCase()))
            .map((e) => e)
            .toList();
      });
    }
  }

  @override
  void initState() {
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });
    loadList();
    super.initState();
  }

  void loadList() async {
    setState(() {
      _isLoading = true;
    });
    _list = await getCountries(context);
    try {

      _currentCountry =
          _list.firstWhere((element) => element.flag == widget.selectedCountry);
      final country = _currentCountry;
      if (country != null) {
        _list.removeWhere(
                (element) => element.name == country.name);
        _list.insert(0, country);
      }
    } catch (e) {} finally {
      setState(() {
        _filteredList = _list.map((e) => e).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 16,
        ),

        Padding(
          padding: const EdgeInsetsDirectional.only(start:24.0),
          child: CustomText(text:"${"select_your_country".tr}",
              size: AppDimen.textSize_24,
              fontWeight: FontWeight.bold),
        ),

        SizedBox(
          height: 16,
        ),

        CustomSearchField(
          controller: _controller ,
          onChanged: _onSearch,
          searchHintText: widget.searchHintText,
          searchInputStyle: widget.searchInputStyle,
          focusSearchBox: widget.focusSearchBox,
          isRTL : widget.isRTL,
          suffixIcon: Visibility(
            visible: _controller.text.isNotEmpty,
            child: InkWell(
              child: Container(
                width: 25,
                  height: 25,
                  margin: EdgeInsetsDirectional.only(end:12.0,start:5.0),
                  child: SvgPicture.asset(clearSearchSvg, fit: BoxFit.scaleDown)
              ),
              onTap: (){
                Future.delayed(Duration.zero, () async {
                  setState(() {
                    _controller.clear();
                    _filteredList.clear();
                    _filteredList.addAll(_list);

                  });
                });
              },

            ),
          ),



        ),

        SizedBox(
          height: 16,
        ),
        _isLoading
            ? const Center(child: CircularProgressIndicator(
          color: AppColors.white,
          strokeWidth: 2.0,
        ))
            : _filteredList.isEmpty ?
        showEmptyView(emptyText: "no_country".tr, emptyImage: emptyCountrySvg, context: context)
        : Expanded(
          child: ListView.separated(
            padding: EdgeInsets.only(top: 16),
            controller: _scrollController,
            itemCount: _filteredList.length,
            separatorBuilder: (_, index) =>
            widget.showSeparator ? SizedBox(
              height: 16,
                child: showDivider()) : const SizedBox.shrink(),
            itemBuilder: (_, index) {
              return InkWell(
                onTap: () {
                  widget.onSelected?.call(_filteredList[index]);
                },
                child: Container(
                  margin: const EdgeInsets.only(left: 26, right: 26),
                  padding: const EdgeInsets.only(bottom: 15, top: 15,),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          width: 1.0,
                        color: AppColors.textfieldBorderColor
                      ),
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      Image.asset(
                        _filteredList[index].flag,
                        package: countryCodePackageName,
                        width: widget.flagIconSize,
                      ),
                 const   SizedBox(width: 4,),
                    Container(
                      width: 50,
                      child: CustomText(
                        text:'${_filteredList[index].callingCode}',
                        textAlign: TextAlign.start,
                      ),
                    ),
                   const SizedBox(width: 20,),
                      Expanded(
                          child: CustomText(
                            text: '${_filteredList[index].name}',
                          )),

                      if(widget.selectedCountry == _filteredList[index].flag)
                        Padding(
                          padding:  EdgeInsetsDirectional.only(end:10.0,start:5.0),
                          child: SvgPicture.asset(selectedCountrySvg),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  getCode(String str) {
   return str.padRight(5,"w");
  }
}
