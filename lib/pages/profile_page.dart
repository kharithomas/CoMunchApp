import 'package:flutter/material.dart';

import '../shared/gradient_mask.dart';
import '../helper/shared_prefs.dart';
import './chat_page.dart';
import '../services/database_service.dart';
import '../widgets/app_drawer.dart';
import './sub/edit_profile_page.dart';
import '../models/user.dart';

class ProfilePage extends StatefulWidget {
  final String profileName;
  final String email;

  ProfilePage({
    this.profileName,
    this.email,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  DatabaseService _databaseService = DatabaseService();
  List<String> _myImages = [
    "https://static01.nyt.com/images/2020/01/22/dining/jo-black-bean-burgers/merlin_167531589_227b9414-ffad-4b44-ae53-67483bd2bae5-articleLarge.jpg",
    "https://www.ketofocus.com/wp-content/uploads/keto-hot-dog-buns-2.jpg",
    "https://natashaskitchen.com/wp-content/uploads/2019/02/Greek-Salad.jpg",
    "https://res.cloudinary.com/jerrick/image/upload/fl_progressive,q_auto,w_1024/h1ztpdytqbip9kf3t7ua.jpg",
    "https://rimage.gnst.jp/livejapan.com/public/article/detail/a/00/00/a0000467/img/basic/a0000467_main.jpg",
    "https://www.olivetomato.com/wp-content/uploads/2019/12/Green-salad-with-feta.jpeg",
  ];
  List<String> _otherImages = [
    "https://www.burger21.com/wp-content/uploads/2020/02/Tex-Mex.jpg",
    "https://c0.wallpaperflare.com/preview/601/540/905/cheers-champagne-people-drink.jpg",
    "https://livelazul.com/wp-content/uploads/2019/08/pexels-photo-2087748-1.jpeg",
    "https://i.pinimg.com/originals/3e/72/6f/3e726f015975ebd9791a2eae433f4d17.jpg",
    "https://gran.luchito.com/wp-content/uploads/2019/07/Mexican_Food_Beginners_Guide_to_Mexican.jpg",
    "https://www.biggerbolderbaking.com/wp-content/uploads/2020/07/Homemade-Hotdog-Buns-Thumbnail-500x375.jpeg",
  ];

  // creates unique chat id
  _getPrivateChatRoomId(String user, String user2) {
    List<String> words = [user, user2];
    words.sort();
    return "${words[0]}\_${words[1]}";
  }

  void _createPrivateChatRoom(String profileName) {
    String chatRoomId = _getPrivateChatRoomId(sharedPrefs.getName, profileName);
    List<String> users = [sharedPrefs.getName, profileName];
    Map<String, dynamic> chatRoomMap = {
      "chatRoomId": chatRoomId,
      "users": users
    };
    _databaseService.createChatRoom(chatRoomId, chatRoomMap);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          chatId: chatRoomId,
          chatName: profileName,
          isGroup: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
            icon: GradientMask(
              Icon(
                Icons.mode_edit,
                size: 24,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 60),
              CircleAvatar(
                backgroundColor: Colors.red,
                child:
                    Icon(Icons.account_circle, size: 70.0, color: Colors.white),
                radius: 50,
              ),
              SizedBox(height: 10),
              Text(
                widget.profileName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Hungry CoMunch user looking for some fun",
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  widget.profileName != sharedPrefs.getName
                      ? FlatButton(
                          child: Icon(
                            Icons.message,
                            color: Colors.white,
                          ),
                          color: Colors.grey,
                          onPressed: () {
                            _createPrivateChatRoom(widget.profileName);
                          },
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                primary: false,
                padding: EdgeInsets.all(5),
                itemCount: 6,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 200 / 200,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Image.network(
                      widget.profileName != sharedPrefs.getName
                          ? _otherImages[index]
                          : _myImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  // Enables persistent data across page views
  bool get wantKeepAlive => true;
}
