import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //바텀시트 배경색 흰색->투명하게 바꿔서 border radius 보이도록 설정
        canvasColor: Colors.transparent,
      ),
      home: Scaffold(
        appBar: AppBar(
          title:Text('To-Do List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),),
          backgroundColor: Color(0xff4D95EE),
        ),
        body: MyHomePage()
      )
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToDoList();
  }
}

class ToDoList extends StatefulWidget {
  const ToDoList({Key? key}) : super(key: key);

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  //투두리스트 담을 리스트 선언
  List<dynamic> myList=[];

  //정렬 방법 선언
  String? sortMethod='latest';

  //text form field 사용에 필요
  final _formKey = GlobalKey<FormState>();

  //local 저장소 사용을 위해 선언
  late SharedPreferences _prefs;

  //초기값 설정
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    //_prefs 초기화
    _prefs =  await SharedPreferences.getInstance();
    _getSortMethod();
    _getList();
  }

  void _getSortMethod() async{
    //기존에 설정된 정렬 방법을 가져오고, 만약 없으면 최신순으로 설정
    sortMethod = _prefs.getString('sortMethod');
    print(sortMethod);
      if(sortMethod==null){
        _prefs.setString('sortMethod','latest');
      }
  }


  void _getList() async{
    //기존에 저장되어 있던 투두리스트를 가져와서 myList에 담기
    final String? rawData = _prefs.getString('toDoList');
      if(rawData != null){
        myList.clear();
        setState(() {
          myList=jsonDecode(rawData);
        });
      }
  }

  void _setItems() async{
    //현재 저장되어 있는 myList를 저장소에 담기
    //원래 이런식의 함수 설정을 좋지 않다. key와 data를 모두 _setItems()의 인수로 받는 구조로 짜야한다.
    final String newData = jsonEncode(myList);
    _prefs.setString('toDoList', newData);
  }

  void _addList(title,detail){
    //새로운 투두리스트를 만들 때 사용한다.
    setState(() {
      myList.insert(0,
        {'title':title,
          'detail':detail,
          'currentState':'To Do',
          'createdAt':DateTime.now().toString()
        },
      );
      //myList에 추가하고 _setItems()를 호출해 로컬 저장소에 등록한다.
      _setItems();
    });
  }

  //add_circle_outline 클릭시 새로운 리스트 추가
  void _pressAddCircle(){
    //우측 상단 add 아이콘 눌렀을 때 투두리스트를 등록할 수 있는 모달을 띄워주는 함수
    String title="";
    String detail="";
    showDialog(
        context: context,
        builder: (_) => Center(
          child: Material(
            color:Colors.transparent,
            child: Container(
              width:double.infinity,
              height: 380,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color:Colors.white),
              child:Form(
                key:_formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title', style:(TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox(height: 8,),
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                      maxLength: 16,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '제목을 입력해주세요.',
                        border: OutlineInputBorder(borderSide: BorderSide( color: Color(0xffE2E2E2)),),
                      ),
                      style: TextStyle(
                          fontSize: 14.0,
                          height: 1,
                          color: Colors.black
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title은 필수 입력항목입니다.';
                        } else if(value.length >16){
                          return 'Title은 16자 이내로 작성해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12,),
                    Text('Detail',style:(TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    SizedBox(height: 8,),
                    SizedBox(
                      height: 140,
                      child:
                      TextFormField(
                        onChanged: (value) {
                          setState(() {
                            detail = value;
                          });
                        },
                        maxLength: 160,
                        textAlignVertical: TextAlignVertical.top,
                        maxLines: null,
                        minLines: null,
                        expands: true,
                        decoration: InputDecoration(
                          hintText: '자세한 내용을 입력해주세요.',
                          border: OutlineInputBorder(borderSide: BorderSide( color: Color(0xffE2E2E2)),),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Detail은 필수 입력항목입니다.';
                          } else if (value.length >160){
                            return 'Detail은 100자 이내로 작성해주세요.';
                          }
                          return null;
                        },
                       style: TextStyle(
                         fontSize: 14.0,
                         height: 1,
                         color: Colors.black,
                       ),
                      ),
                    ),
                    SizedBox(height: 16,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: Size(double.infinity, 56) // put the width and height you want
                      ),
                      onPressed:(){
                        if (_formKey.currentState!.validate()) {
                          _addList(title,detail);
                          Navigator.pop(context);
                        }
                        },
                      child: Text('등록하기'))
                  ],
                ),
              )
            ),
          ),
        )
    );
  }

  //list item 클릭시 자세한 내용 보기
  void _showDetail(thisTitle,thisDetail){
    showDialog(
      context: context,
      builder: (_) => Center(
        child: Container(
            width:double.infinity,
            height: 380,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color:Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(thisTitle, style:(TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  SizedBox(height: 16,),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border:Border.all(width: 1,color:Color(0xffE2E2E2)),
                    ),
                    height: 230,
                    width:double.infinity,
                    child:Text(thisDetail,style: TextStyle(
                      fontSize: 16
                    ),)
                  ),
                  SizedBox(height: 16,),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: Size(double.infinity, 56) // put the width and height you want
                      ),
                      onPressed:(){
                          Navigator.pop(context);
                      },
                      child: Text('확인'))
                ],
            ),
        ),
      )
    );
  }

  // list item 롱프레스시 삭제 얼럿 띄우기
  void _deletingAlert(title,index){
    showDialog(
        context: context,
        builder: (_) => Center(
            child: Container(
              width:double.infinity,
              height: 210,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color:Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('삭제하시겠습니까?', style:(TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  SizedBox(height: 16,),
                  SizedBox(
                    height: 46,
                    child: Text('$title 항목을 투두리스트에서 제거하시겠습니까?', style:(TextStyle(fontSize: 16))))
                  ,
                  SizedBox(height: 32,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          primary: Color(0xffB0B0B0),
                          textStyle: TextStyle(color:Colors.white),
                          minimumSize: Size(160, 56),
                          // put the width and height you want
                        ),
                        onPressed:(){
                          Navigator.pop(context);
                        },
                        child: Text('아니요')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          minimumSize: Size(160, 56) // put the width and height you want
                        ),
                        onPressed:(){
                          setState(() {
                            myList.removeAt(index);
                            _setItems();
                            });
                          Navigator.pop(context);
                        },
                        child: Text('예')
                      )
                    ],
                  )
                ],
              ),
            ),
        )
    );
  }

  void _sortingWithState(){
    //정렬 방식이 상태에 따라 정렬로 설정되어 있을 때 myList를 재배열하는 함수
    myList.sort((m1, m2) {
      var r = m2["currentState"].compareTo(m1["currentState"]);
      if (r != 0) return r;
      return m2["createdAt"].compareTo(m1["createdAt"]);
    });
    sortMethod='toDoFirst';
    _prefs.setString('sortMethod','toDoFirst');
    _setItems();
  }

  void _sortingWithDate(){
    //정렬 방식이 최신순으로 설정되어 있을 때 myList를 재배열하는 함수
    myList.sort((a, b) => (b['createdAt']).compareTo(a['createdAt']));
    sortMethod='latest';
    _prefs.setString('sortMethod','latest');
    _setItems();
  }

  //우측 상단 아이콘을 눌러 정렬 방식 선택할 때 바텀시트 보여주는 함수
  void _showBottomSheet() {
    showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)
              ),
              color: Colors.white,
            ),
            padding:EdgeInsets.all(16),
            height: 230,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Container(
                    padding:EdgeInsets.fromLTRB(16,12,0,12),
                    child: Text('정렬',style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold
                    ),),
                  ),
                  ListTile(
                    //터치 피드백 안보이는건 어떻게 하는지 아직 모르겠음
                    onTap:(){
                      setState(() {
                        _sortingWithDate();
                      });
                      Navigator.pop(context);
                    },
                    title:Text('최신순', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
                   ),
                  ListTile(
                    onTap:(){
                      setState(() {
                        _sortingWithState();
                      });
                      Navigator.pop(context);
                    },
                    title:Text('To do 우선', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
                  )
                ],
              ),
          );
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Column(
        children: [
          //우측 상단 아이콘 두개
          Container(
            height:56,
            width:double.infinity,
            padding:EdgeInsets.fromLTRB(0,0,16,0),
            color:Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: (){
                    _showBottomSheet();
                  },
                  icon: Icon(Icons.sort),
                  iconSize: 32,
                  color:Color(0xff4D95EE),
                ),
                IconButton(
                  onPressed: (){_pressAddCircle();},
                  icon: Icon(Icons.add_circle_outline),
                  iconSize: 32,
                  color:Color(0xff4D95EE),
                )
              ],
            ),
          ),
          Expanded(
            child: myList.isEmpty ?
              Center(
                child: Text('투두리스트를 추가해주세요.',style:TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color:Colors.black
                ))
              ) : ListView(
              padding: EdgeInsets.fromLTRB(16,0,16,16),
              children: myList.asMap().entries.map((entry){
                final item = entry.value;
                final index = entry.key;

                return Column(
                  children: [
                    //inkwell 쓰는 이유, gesturedetector와 다른
                    InkWell(
                      onTap: (){
                        _showDetail(item['title'],item['detail']);
                      },
                      onLongPress: (){
                        setState(() {
                          _deletingAlert(item['title'],index);
                        });
                      },
                      child: Ink(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:item['currentState']=='To Do' ? Color(0xffEEEFF3) : item['currentState']=='In Progress' ? Color(0xff4d95ee) : Color(0xff34c036),
                          borderRadius: BorderRadius.circular(8)
                        ),
                        width: double.infinity,
                        height:90,
                        child: Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: double.infinity,
                                  width:double.infinity,
                                  child:Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item['title'], style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color:item['currentState']=='To Do' ? Color(0xff2d2d2d) : Colors.white )),
                                      Text(item['currentState'], style:TextStyle(fontSize: 14, color:item['currentState']=='To Do' ? Color(0xffb4b5b9) : Colors.white,))
                                    ],
                                  )
                                ),
                              ),
                              SizedBox(
                                height: double.infinity,
                                width:56,
                                child:IconButton(
                                  onPressed: (){
                                    setState(() {
                                      myList[index] = {
                                        ...myList[index],
                                        'currentState':myList[index]['currentState']=='To Do' ? 'In Progress' : myList[index]['currentState']=='In Progress' ? 'Done' : 'To Do'
                                      };
                                      if(sortMethod=='toDoFirst'){
                                        _sortingWithState();
                                      }
                                      _setItems();
                                    });
                                  },
                                  icon:Icon(Icons.check_circle_outline),
                                  color:item['currentState']=='To Do' ? Color(0xffACACAC) : Colors.white,
                                  iconSize: 40,
                                )
                              ),
                            ],
                          ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    )
                  ],
                );}).toList(),

            )
          ),
        ],
      );
  }
}



