# cocomong_step3

> 음식물을 추가하는 것을 구현합니다.   
> 결과물은 아래 이미지와 같습니다.   
> ![Screenshot_16422934911](https://user-images.githubusercontent.com/63987139/149642768-b4ef501f-d091-49e0-b9d8-2d17e9526392.png)   
> 만약 Cocomong step2를 완료하지 못하였다면 아래 링크를 참고하세요!   
> - Link: [cocomong step2](https://github.com/HeyLip/Cocomong_step2)     



시작하기에 앞서 일단 다음과 같은 코드를 먼저 구현해야합니다. 어떤 Firebase에 data를 읽어올건지 결정하는 코드입니다.   
<pre>
<code>
late CollectionReference database;

  @override
  void initState() {
    super.initState();
    database =
        FirebaseFirestore.instance.collection('user').doc(widget.user!.uid).collection('Product');
  }
</code>
</pre>

## 1. Product Setting 구현   
Product Setting을 구현하기에 앞서 다음 변수들을 선언해주어야 합니다.

<pre>
<code>
  final _productnameController = TextEditingController(); // 음식물 이름을 저장하는 변수
  final _descriptionController = TextEditingController(); // 음식물의 정보(?)를 저장하는 변수
  PickedFile? _image; //image picker를 통해 선택한 이미지를 저장하는 변수
</code>
</pre>  

변수도 선언해 주었으므로 이제 아래의 코드를 작성하여 주면 됩니다.

<pre>
<code>
  Container productSetting() {
    return Container(
      height: 178,
      margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
      decoration: BoxDecoration(
          color: Color(0xFF8EB680), borderRadius: BorderRadius.circular(15.0)),
      child: Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Color(0xFFB2DEB8)),
                child: _image == null
                    ? IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 40,
                  ),
                  onPressed: () async {
                    var image = await ImagePicker.platform
                        .pickImage(source: ImageSource.gallery);
                    setState(() {
                      _image = image!;
                    });
                  },
                )
                    : ClipOval(
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  var image = await ImagePicker.platform
                      .pickImage(source: ImageSource.gallery);
                  setState(() {
                    _image = image!;
                  });
                },
                child: const Text(
                  "사진 추가",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          SizedBox(
            width: 180,
            child: Column(
              children: <Widget>[
                TextField(
                  controller: _productnameController,
                  decoration: const InputDecoration(
                      filled: false,
                      labelText: 'Product Name',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 12.0,
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                      filled: false,
                      labelText: 'Description',
                      labelStyle: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
</code>
</pre>

구현 결과물!   
![Screenshot_1642293491 product](https://user-images.githubusercontent.com/63987139/149643093-5c7c9816-5100-4e4d-a4c1-ab4abc3c8fa5.png)      



## 2. Date Setting 구현
Date Setting을 구현하기에 앞서 다음 변수들을 선언해주어야 합니다.   

<pre>
<code>
  DateTime _selectedDate = DateTime.now(); //선택한 날짜를 저장하는 변수!
  static List<String> days = ['월', '화', '수', '목', '금', '토', '일']; //이것을 선언한 이유는 day가 숫자로 표현이 되기 때문에 선언해준 것이다.   
</code>
</pre>

변수도 선언해주었으니 아래의 코드를 구현해주면 됩니다.   
<pre>
<code>
  Container dateSetting() {
    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
      padding: const EdgeInsets.fromLTRB(15.0, 20.0, 15.0, 10.0),
      decoration: BoxDecoration(
          color: const Color(0xFF8EB680), borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        children: <Widget>[
          const SizedBox(
            height: 35,
          ),
          Text(
            '설정된 날짜 : ${_selectedDate.year}년 ${_selectedDate.month}월 ${_selectedDate.day}일 ${days[_selectedDate.weekday - 1]}요일',
            style: const TextStyle(
                color: Color(0xFF3C3844), fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: 300,
            height: 70,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xFFB2DEB8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.calendar_today,
                      size: 30,
                      color: Color(0xFF3C3844),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      '날짜 설정',
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF3C3844),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                onPressed: () {
                  Future<DateTime?> future = showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );

                  future.then((date) {
                    setState(() {
                      _selectedDate = date!.add(const Duration(hours: 9));
                    });
                  });
                }),
          ),
        ],
      ),
    );
  }
</code>
</pre>

구현결과물!   
![Screenshot_1642293491 date](https://user-images.githubusercontent.com/63987139/149643391-dc16fd17-d5f3-495e-987a-55559fd62590.png)   




## 3. cancelSaveButton 구현

이제 앞서 음식의 이름과 설명, 유통기한 그리고 사진을 설정해주었는데 이것들을 Firebase에 저장하는 버튼을 구현할 것입니다.   

변수를 아래와 같이 선언하여 줍니다.   
<pre>
<code>
  late Reference firebaseStorageRef; //Firebase Storage에 어떤 경로로 이미지를 저장하는지 지정하는 변수!
  late UploadTask uploadTask; //앞서 설정한 경로로 이미지를 Firebase Storage에 저장하는 변수!
  late var downloadUrl; //Firebas Storage에 저장된 이미지의 url을 저장하기 위한 변수!
</code>
</pre>

이제 cancelSaveButton은 아래와 같이 구현합니다.   
<pre>
<code>
  Row cancelSaveButton() {
    return Row(children: [
      Expanded(
        child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "취소",
              style: TextStyle(color: Colors.white),
            )),
      ),
      Expanded(
        child: TextButton(
            onPressed: () async {
              if (_image != null) {
                firebaseStorageRef = firebase_storage.FirebaseStorage.instance
                    .ref()
                    .child(widget.user!.uid)
                    .child('${_productnameController.text}.png');

                uploadTask = firebaseStorageRef.putFile(File(_image!.path),
                    SettableMetadata(contentType: 'image/png'));

                await uploadTask.whenComplete(() => null);

                downloadUrl = await firebaseStorageRef.getDownloadURL();
              } else {
                downloadUrl =
                'https://firebasestorage.googleapis.com/v0/b/cocomong.appspot.com/o/cocomong.png?alt=media&token=139e119b-24ea-400c-b7b6-6874963a672a';
              }



              database.add({
                'productName': _productnameController.text,
                'description': _descriptionController.text,
                'expirationDate': _selectedDate,
                'photoUrl': downloadUrl,
              });

              Navigator.pop(context);
            },
            child: const Text(
              "저장",
              style: TextStyle(color: Colors.white),
            )),
      ),
    ]);
  }
</code>
</pre>

구현결과물!   
![Screenshot_1642293491 하단](https://user-images.githubusercontent.com/63987139/149643533-76d0d43b-66f9-4d17-9428-0b75456fc8b4.png)


## 4. Build 구현!   
이제 앞서 선언한 함수들을 이용하여 build를 아래 코드와 같이 구현합니다.   

<pre>
<code>
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  children: <Widget>[
                    productSetting(),
                    dateSetting(),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFF5B836A),
                child: cancelSaveButton(),
              )
            ],
          )),
      resizeToAvoidBottomInset: false,
    );
  }
</code>
</pre>

