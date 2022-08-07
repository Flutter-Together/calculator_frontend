import 'dart:convert';

import 'package:calculator_frontend/widgets/LargeText.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CapitalGainsTaxPage extends StatefulWidget {
  const CapitalGainsTaxPage({Key? key}) : super(key: key);

  @override
  State<CapitalGainsTaxPage> createState() => _CapitalGainsTaxPageState();
}

class _CapitalGainsTaxPageState extends State<CapitalGainsTaxPage> {

  final mainColor = 0xff80cfd5;

  bool _isSearchedAddress = false; //flase 이면 주소 검색을 아직 안한 상태, 1이면 검색을 한 상태

  String sampleAddress = '서울특별시 서초구 반포대로 4(서초동)';
  Color _color = Colors.black38;
  final backgroundColor = 0xfffafafa;

  final TextEditingController _transferDateTC = TextEditingController();
  final TextEditingController _findingAddressTC = TextEditingController();

  final List<String> _typeOfTransfer = ["주택", "조합원 입주권", "분양권(2021년 이전 취득)", "분양권(2022년 이후 취득)"];
  String? _dropDownMenuForTypeOfTransfer;
  final List<String> _typeOfAcquisition = ["주택", "재건축전 주택", "주거용 오피스텔", "조합원 입주권", "분양권(2021년 이전 취득)", "분양권(2022년 이후 취득)"];
  String? _dropDownMenuForTypeOfAcquisition;
  final List<String> _reasonOfAquistition = ["매매", "증여", "상속", "자가신축"];
  String? _dropDownMenuForReasonOfAquistition;

  late int _stage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _stage = 1;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body:  Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 1200,
            ),
            child: ListView(
              children: <Widget>[
                largeTitle(),
                firstDivider(),
                Row(
                  children: [
                    _smallTitle('주소'),
                    Expanded(
                      child: GestureDetector(
                        onTap: ()async{
                          var a = await _findingAddressDialog(_findingAddressTC);

                          setState(() {
                            sampleAddress = a!;
                            _color = Colors.black;
                            _stage = 2;
                          });
                        },
                        child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color:  Colors.black,
                                ),
                                borderRadius: const BorderRadius.all(Radius.circular(10))
                            ),
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:  [
                                Text(
                                  sampleAddress,
                                  style:  TextStyle(fontSize: 17,color: _color),
                                ),
                              ],
                            )
                        ),
                      )
                    )
                  ],
                ),
                Row(
                  children: [
                    _smallTitle('양도시 종류'),
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child:GestureDetector(
                            child:  LayoutBuilder(
                              builder: (BuildContext context, BoxConstraints constraints){
                                return DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    items: ((){
                                      if(_stage >= 2){
                                        return _typeOfTransfer;
                                      }else {
                                        return [];
                                      }})().map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          //color: Colors.white,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    value: _dropDownMenuForTypeOfTransfer,
                                    onChanged: (value) {
                                      setState(() {
                                        _dropDownMenuForTypeOfTransfer = value as String;
                                        _stage = 3;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down,
                                    ),
                                    iconSize: 30,
                                    buttonHeight: 50,
                                    buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                    buttonDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(),
                                      color: ((){
                                        if(_stage >= 2){
                                          return Color(backgroundColor);
                                        }
                                        else {return Colors.black12;
                                        }})(),
                                    ),
                                    buttonElevation: 2,
                                    itemHeight: 40,
                                    itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                    dropdownMaxHeight: 200,
                                    dropdownWidth: constraints.maxWidth,
                                    dropdownPadding: null,
                                    dropdownDecoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      // color: Colors.redAccent,
                                    ),
                                    dropdownElevation: 8,
                                    scrollbarRadius: const Radius.circular(40),
                                    scrollbarThickness: 6,
                                    scrollbarAlwaysShow: true,
                                    offset: const Offset(0, 0),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    _smallTitle('양도예정일'),
                    _expectedTransferDate(_transferDateTC, '20220725',((){
                      if(_stage >=3 ){return true;} else {return false;}})())
                  ],
                ),
                Row(
                  children: [
                    _smallTitle('취득 원인'),
                    Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                          child: LayoutBuilder(
                            builder: (BuildContext context, BoxConstraints constraints){
                              return DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  isExpanded: true,
                                  items:((){
                                    if(_stage >= 4){
                                      return _reasonOfAquistition;
                                    }else {
                                      return [];
                                    }})().map((item) => DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(
                                      item,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        //color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )).toList(),
                                  value: _dropDownMenuForReasonOfAquistition,
                                  onChanged: (value) {
                                    setState(() {
                                      _dropDownMenuForReasonOfAquistition = value as String;
                                      _stage = 5;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                  ),
                                  iconSize: 30,
                                  buttonHeight: 50,
                                  buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                  buttonDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(),
                                    color: ((){
                                      if(_stage >= 4){
                                        return Color(backgroundColor);
                                      }
                                      else {return Colors.black12;
                                      }})(),
                                  ),
                                  buttonElevation: 2,
                                  itemHeight: 40,
                                  itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                  dropdownMaxHeight: 200,
                                  dropdownWidth: constraints.maxWidth,
                                  dropdownPadding: null,
                                  dropdownDecoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    // color: Colors.redAccent,
                                  ),
                                  dropdownElevation: 8,
                                  scrollbarRadius: const Radius.circular(40),
                                  scrollbarThickness: 6,
                                  scrollbarAlwaysShow: true,
                                  offset: const Offset(0, 0),
                                ),
                              );
                            },
                          ),
                        )
                    ),
                  ],
                ),
                Row(
                  children: [
                    _smallTitle('취득시 종류'),
                    Expanded(child: Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints){
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              items: ((){
                                if(_stage >= 5){
                                  return _typeOfAcquisition;
                                }else {
                                  return [];
                                }})()
                                  .map((item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    //color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )).toList(),
                              value: _dropDownMenuForTypeOfAcquisition,
                              onChanged: (value) {
                                setState(() {
                                  _dropDownMenuForTypeOfAcquisition = value as String;
                                  _stage = 6;
                                });
                              },
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                              ),
                              iconSize: 30,
                              buttonHeight: 50,
                              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                              buttonDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(),
                                color:((){
                                  if(_stage >= 5){
                                    return Color(backgroundColor);
                                  }
                                  else {return Colors.black12;
                                  }})(),
                              ),
                              buttonElevation: 2,
                              itemHeight: 40,
                              itemPadding: const EdgeInsets.only(left: 14, right: 14),
                              dropdownMaxHeight: 200,
                              dropdownWidth: constraints.maxWidth,
                              dropdownPadding: null,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                // color: Colors.redAccent,
                              ),
                              dropdownElevation: 8,
                              scrollbarRadius: const Radius.circular(40),
                              scrollbarThickness: 6,
                              scrollbarAlwaysShow: true,
                              offset: const Offset(0, 0),
                            ),
                          );
                        },
                      ),
                    ))
                  ],
                ),
                Container(
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 50, 0, 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.redAccent),
                    onPressed: () {
                      if (_checkFormIsCompleted()) {
                        setState(() {});
                      } else {
                        setState(() {});
                      }
                    },
                    child: const Text(
                      '계산하기',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                )
              ],
            ),
        ),
      ),
    );
  }

  Widget _customDropdown(List<String> listofItems, String selected){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              items: listofItems
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 17,
                    //color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              value: selected,
              onChanged: (value) {
                setState(() {
                  selected = value as String;
                });
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
              ),
              iconSize: 30,
              buttonHeight: 50,
              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(),
                color: Colors.white,
              ),
              buttonElevation: 2,
              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,
              dropdownWidth: constraints.maxWidth,
              dropdownPadding: null,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                // color: Colors.redAccent,
              ),
              dropdownElevation: 8,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              offset: const Offset(0, 0),
            ),
          );
        },
      ),
    );
  }

  bool _checkFormIsCompleted() {

    return true;
  }
  Future<String> _findingAddressDialog(TextEditingController tc)async{
    setState((){
      _isSearchedAddress = false;
    });
    var res = await showDialog(
        context: context,
        builder: (BuildContext context){
          return StatefulBuilder(
              builder: (context, setState){
                return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                    title: Text('주소검색'),
                    content:Container(
                      width: 600,
                      constraints: const BoxConstraints(
                        minHeight: 500,
                        maxHeight: 800,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.maxFinite,
                            margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: TextField(
                                controller: tc,
                                autofocus: true,
                                onSubmitted: (value){
                                  setState((){
                                    _isSearchedAddress = true;
                                  });
                                },
                                cursorColor: Colors.black,
                                textInputAction: TextInputAction.search,
                                style: const TextStyle(fontSize: 17),
                                decoration: InputDecoration(
                                    hintText: '반포대로',
                                    focusedBorder: _outlineInputBorder(),
                                    enabledBorder: _outlineInputBorder(),
                                    border: _outlineInputBorder(),
                                    suffixIcon: Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 10, 10),
                                      child: IconButton(
                                        icon: const Icon(Icons.search, size: 40),
                                        color: Colors.black,
                                        onPressed: () {
                                          setState((){
                                            _isSearchedAddress = true;
                                          });
                                        },
                                      ),
                                    )
                                )
                            ),
                          ),
                          _isSearchedAddress? _addressList(tc.text)
                              : const Center(child: Text('검색어를 입력해주세요'),)
                        ],
                      ),
                    )
                );
              }
          );
        }
    );

    return res;
  }



  Widget _addressList(String keyword){

    return Expanded(child: FutureBuilder(
        future: fetchAddress(keyword),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(mainColor)),
              ),
            );
          }else if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }
          List res = snapshot.data as List;
          return ListView.builder(
            itemCount: res.length,
            shrinkWrap: true,
            itemBuilder: (context, index){
              return _selectAddressBox(res[index][0],res[index][1],index);
            },
          );
        }
    ));
  }

  Widget _selectAddressBox(String newAddress, String oldAddress, int index){
    Color backgrouundColor;
    if(index.isEven){
      backgrouundColor = Colors.white;
    }else {backgrouundColor = Colors.black26;}

    return GestureDetector(
      onTap: (){Navigator.pop(context, newAddress);},
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        decoration: BoxDecoration(
          color: backgrouundColor
        ),
        child: Column(
          children: [
            Text(newAddress),
            Text(oldAddress)
          ],
        ),
      ),
    );
  }


  Future<List> fetchAddress(String keyword) async{
    String baseURL = "https://wu26xy8cqj.execute-api.ap-northeast-2.amazonaws.com/default/juso_api?keyword=";

    final response = await http.get(Uri.parse(baseURL + keyword));

    if(response.statusCode == 200){

      List res = List.from(jsonDecode(utf8.decode(response.bodyBytes)));

      return res;
    }
    else {
      throw Exception("Fail to fetch address data");
    }
  }



  Widget _textField1(TextEditingController tc, String labelText) {
    return Expanded(
        child: Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: TextField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        controller: tc,
        cursorColor: Colors.black,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 17),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.black),
          focusedBorder: _outlineInputBorder(),
          enabledBorder: _outlineInputBorder(),
          border: _outlineInputBorder(),
        ),
      ),
    ));
  }

  Widget _expectedTransferDate(TextEditingController tc, String hintText,bool able) {
    return Expanded(
        child: Container(
          margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: TextField(
            onChanged: (text){
              if(tc.text.length == 8){
                setState(() {
                  _stage = 4;
                });
              }else {
                setState(() {
                  _stage = 3;
                });
              }
            },
            enabled: able,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            controller: tc,
            cursorColor: Colors.black,
            textInputAction: TextInputAction.search,
            style: const TextStyle(fontSize: 17),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38),
              focusedBorder: _outlineInputBorder(),
              enabledBorder: _outlineInputBorder(),
              border: _outlineInputBorder(),
            ),
          ),
        ));
  }

  OutlineInputBorder _outlineInputBorder() {
    return const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
        borderRadius: BorderRadius.all(Radius.circular(10)));
  }

  Widget _optionText(String txt) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Text(
        txt,
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  Widget _smallTitle(String txt) {
    return Container(
      width: 120,
      margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Text(
        txt,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget largeTitle(){
    return const Padding(
      padding:  EdgeInsets.only(left: 10, top: 40, bottom: 20),
      child: LargeText(
        text: '양도소득세 통합 계산',
        size: 25,
      )
    );
  }

  Widget firstDivider(){
    return Row(children: <Widget>[
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 10, right: 15),
            child: const Divider(
              color: Colors.red,
              height: 20,
            )),
      ),
      const Text(
        "2022년 7월 세법개정(안) 반영",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Container(
            margin: const EdgeInsets.only(left: 15, right: 10),
            child: const Divider(
              color: Colors.red,
              height: 20,
            )),
      ),
    ]);

  }
}

class customDropDown extends StatefulWidget {

  final List items;
  final String selectedItem;
  final bool able;

  customDropDown({Key? key, required this.items, required this.selectedItem, required this.able}) : super(key: key);

  final _customDropDownState _state = _customDropDownState();

  @override
  State<customDropDown> createState() => _state;

  void returnSelected(){
    print( _state._selected);
  }
}

class _customDropDownState extends State<customDropDown> {

  late String _selected;

  @override
  void initState() {
    // TODO: implement initState

    _selected = widget.selectedItem;
    super.initState();
  }

  final backgroundColor = 0xfffafafa;

  @override
  Widget build(BuildContext context) {
    return  Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints){
          return DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              items: widget.items
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 17,
                    //color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )).toList(),
              value: _selected,
              onChanged: (value) {
                setState(() {
                  _selected = value as String;
                });
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
              ),
              iconSize: 30,
              buttonHeight: 50,
              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
              buttonDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(),
                color: Color(backgroundColor),
              ),
              buttonElevation: 2,
              itemHeight: 40,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,
              dropdownWidth: constraints.maxWidth,
              dropdownPadding: null,
              dropdownDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                // color: Colors.redAccent,
              ),
              dropdownElevation: 8,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              offset: const Offset(0, 0),
            ),
          );
        },
      ),
    );
  }
}