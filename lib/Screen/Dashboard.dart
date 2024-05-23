import 'dart:async';
import 'dart:convert';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:tlkmartuser/Helper/Color.dart';
import 'package:tlkmartuser/Helper/Constant.dart';
import 'package:tlkmartuser/Helper/PushNotificationService.dart';
import 'package:tlkmartuser/Helper/Session.dart';
import 'package:tlkmartuser/Helper/String.dart';
import 'package:tlkmartuser/Model/Section_Model.dart';
import 'package:tlkmartuser/Provider/UserProvider.dart';
import 'package:tlkmartuser/Screen/Favorite.dart';
import 'package:tlkmartuser/Screen/Login.dart';
import 'package:tlkmartuser/Screen/MyProfile.dart';
import 'package:tlkmartuser/Screen/Product_Detail.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'All_Category.dart';
import 'Cart.dart';
import 'HomePage.dart';
import 'NotificationLIst.dart';
import 'Sale.dart';
import 'Search.dart';

class Dashboard extends StatefulWidget {
  final int? selBottomIndex;
  const Dashboard({Key? key, this.selBottomIndex}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Dashboard> with TickerProviderStateMixin {
  //int _selBottom = 0;
  late TabController _tabController;
  bool _isNetworkAvail = true;
  final _pageController = PageController(initialPage: 0);

  final List<Widget> bottomBarPages = [
    HomePage(),
    AllCategory(),
    Sale(),
    Cart(
      fromBottom: true,
    ),
    MyProfile(),
  ];
  int selectedIndex = 0;
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    super.initState();
    initDynamicLinks();
    _tabController = TabController(
      length: 5,
      vsync: this,
    );

    if (widget.selBottomIndex != null) {
      selectedIndex = widget.selBottomIndex ?? 0;
      _tabController.animateTo(widget.selBottomIndex ?? 3);
    }

    final pushNotificationService = PushNotificationService(
        context: context, tabController: _tabController);
    pushNotificationService.initialise();

    _tabController.addListener(
          () {
        Future.delayed(Duration(seconds: 0)).then(
              (value) {
            if (_tabController.index == 3) {
              if (CUR_USERID == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Login(),
                  ),
                );
                _tabController.animateTo(0);
              }
            }
          },
        );

        setState(
              () {
            selectedIndex = _tabController.index;
          },
        );
      },
    );
  }

  void initDynamicLinks() async {
    /* FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        if (deepLink.queryParameters.length > 0) {
          int index = int.parse(deepLink.queryParameters['index']!);

          int secPos = int.parse(deepLink.queryParameters['secPos']!);

          String? id = deepLink.queryParameters['id'];

          String? list = deepLink.queryParameters['list'];

          getProduct(id!, index, secPos, list == "true" ? true : false);
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;
    if (deepLink != null) {
      if (deepLink.queryParameters.length > 0) {
        int index = int.parse(deepLink.queryParameters['index']!);

        int secPos = int.parse(deepLink.queryParameters['secPos']!);

        String? id = deepLink.queryParameters['id'];

        // String list = deepLink.queryParameters['list'];

        getProduct(id!, index, secPos, true);
      }
    }*/
  }

  Future<void> getProduct(String id, int index, int secPos, bool list) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          ID: id,
        };

        // if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID;
        Response response =
        await post(getProductApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<Product> items = [];

          items =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ProductDetail(
                index: list ? int.parse(id) : index,
                model: list
                    ? items[0]
                    : sectionList[secPos].productList![index],
                secPos: secPos,
                list: list,
              )));
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg, context);
        }
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      {
        if (mounted)
          setState(() {
            _isNetworkAvail = false;
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Confirm Exit"),
                content: Text("Are you sure you want to exit?"),
                actions: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary),
                    child: Text("YES"),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary),
                    child: Text("NO"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });
        // if (_tabController.index != 0) {
        //   _tabController.animateTo(0);
        //   return false;
        // }
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.lightWhite,
        appBar: selectedIndex == 0 ? null : _getAppBar(),
        body: bottomBarPages[selectedIndex],
        // body: PageView(
        //   controller: _pageController,
        //   physics: const NeverScrollableScrollPhysics(),
        //   children: List.generate(
        //       bottomBarPages.length, (index) => bottomBarPages[index]),
        // ),
        extendBody: true,
        //fragments[_selBottom],
        bottomNavigationBar: _getBottomBar(),
      ),
    );
  }

  AppBar _getAppBar() {
    String? title;
    if (selectedIndex == 1)
      title = getTranslated(context, 'CATEGORY');
    // centerTitle: selectedIndex == 0 || selectedIndex == 1 ? true : false,
    else if (selectedIndex == 2)
      // title = getTranslated(context, 'OFFER');
      title = getTranslated(context, 'OFFER');
    else if (selectedIndex == 3)
      title = getTranslated(context, 'MYBAG');
    else if (selectedIndex == 4) title = getTranslated(context, 'PROFILE');

    return AppBar(
      centerTitle: selectedIndex == 0 ? true : false,
      title: selectedIndex == 0
          ? Image.asset(
        'assets/images/titleicon.png',
        //height: 40,
        //   width: 200,
        height: 65,
        // width: 45,
      )
          : Text(
        title!,
        style: TextStyle(
            color: colors.whiteTemp, fontWeight: FontWeight.normal),
      ),

      leading: selectedIndex == 0
          ? InkWell(
        child: Center(
            child: SvgPicture.asset(
              imagePath + "search.svg",
              height: 20,
              color: colors.whiteTemp,
            )),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Search(),
              ));
        },
      )
          : null,
      // iconTheme: new IconThemeData(color: colors.primary),
      // centerTitle:_curSelected == 0? false:true,
      actions: <Widget>[
        selectedIndex == 0
            ? Container()
            : IconButton(
            icon: SvgPicture.asset(
              imagePath + "search.svg",
              height: 20,
              color: colors.whiteTemp,
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Search(),
                  ));
            }),
        IconButton(
          icon: SvgPicture.asset(
            imagePath + "desel_notification.svg",
            color: colors.whiteTemp,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationList(),
                ))
                : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          },
        ),
        IconButton(
          padding: EdgeInsets.all(0),
          icon: SvgPicture.asset(
            imagePath + "desel_fav.svg",
            color: colors.whiteTemp,
          ),
          onPressed: () {
            CUR_USERID != null
                ? Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Favorite(),
                ))
                : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Login(),
                ));
          },
        ),
      ],
      backgroundColor: colors.primary,
    );
  }

  Widget _getBottomBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).colorScheme.black26, blurRadius: 10)
        ],
      ),
      child: CurvedNavigationBar(
        color: Colors.white,
        backgroundColor: Colors.transparent,
        items: [
          CurvedNavigationBarItem(
            child: selectedIndex == 0
                ? SvgPicture.asset(
              imagePath + "1Home.svg",
              color: colors.primary,
            )
                : SvgPicture.asset(
              imagePath + "1Home.svg",
              color: colors.primary,
            ),
            label: getTranslated(context, 'HOME_LBL'),
          ),
          CurvedNavigationBarItem(
            child: selectedIndex == 1
                ? SvgPicture.asset(
              imagePath + "2Category.svg",
              color: colors.primary,
            )
                : SvgPicture.asset(
              imagePath + "2Category.svg",
              color: colors.primary,
            ),
            label: getTranslated(context, 'category'),
          ),
          CurvedNavigationBarItem(
            child: selectedIndex == 2
                ? SvgPicture.asset(
              imagePath + "3Discount.svg",
              color: colors.primary,
            )
                : SvgPicture.asset(
              imagePath + "3Discount.svg",
              color: colors.primary,
            ),
            label:'Offer',
          ),
          CurvedNavigationBarItem(
            child: Selector<UserProvider, String>(
              builder: (context, data, child) {
                return Stack(
                  children: [
                    Center(
                      child: selectedIndex == 3
                          ? SvgPicture.asset(
                        imagePath + "4Buy.svg",
                        color: colors.primary,
                      )
                          : SvgPicture.asset(
                        imagePath + "4Buy.svg",
                        color: colors.primary,
                      ),
                    ),
                    (data != null && data.isNotEmpty && data != "0")
                        ? new Positioned.directional(
                      bottom: selectedIndex == 3 ? 6 : 20,
                      textDirection: Directionality.of(context),
                      end: 0,
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary),
                        child: new Center(
                          child: Padding(
                            padding: EdgeInsets.all(3),
                            child: new Text(
                              data,
                              style: TextStyle(
                                  fontSize: 7,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .white),
                            ),
                          ),
                        ),
                      ),
                    )
                        : Container()
                  ],
                );
              },
              selector: (_, homeProvider) => homeProvider.curCartCount,
            ),
            label: getTranslated(context, 'CART'),
          ),
          CurvedNavigationBarItem(
            child: selectedIndex == 4
                ? SvgPicture.asset(
              imagePath + "2 User.svg",
              color: colors.primary,
            )
                : SvgPicture.asset(
              imagePath + "2 User.svg",
              color: colors.primary,
            ),
            label: getTranslated(context, 'PROFILE'),
          ),
        ],
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          // Handle button tap
        },
      ),
    );
    // return Material(
    //     color: Theme.of(context).colorScheme.white,
    //     child: Container(
    //       decoration: BoxDecoration(
    //         color: Theme.of(context).colorScheme.white,
    //         boxShadow: [
    //           BoxShadow(
    //               color: Theme.of(context).colorScheme.black26, blurRadius: 10)
    //         ],
    //       ),
    //       child: TabBar(
    //         onTap: (_) {
    //           if (_tabController.index == 3) {
    //             if (CUR_USERID == null) {
    //               Navigator.push(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (context) => Login(),
    //                 ),
    //               );
    //               _tabController.animateTo(0);
    //             }
    //           }
    //         },
    //         controller: _tabController,
    //         tabs: [
    //           Tab(
    //             icon: _selBottom == 0
    //                 ? SvgPicture.asset(
    //                     imagePath + "sel_home.svg",
    //                     color: colors.primary,
    //                   )
    //                 : SvgPicture.asset(
    //                     imagePath + "desel_home.svg",
    //                     color: colors.primary,
    //                   ),
    //             text:
    //                 _selBottom == 0 ? getTranslated(context, 'HOME_LBL') : null,
    //           ),
    //           Tab(
    //             icon: _selBottom == 1
    //                 ? SvgPicture.asset(
    //                     imagePath + "category01.svg",
    //                     color: colors.primary,
    //                   )
    //                 : SvgPicture.asset(
    //                     imagePath + "category.svg",
    //                     color: colors.primary,
    //                   ),
    //             text:
    //                 _selBottom == 1 ? getTranslated(context, 'category') : null,
    //           ),
    //           Tab(
    //             icon: _selBottom == 2
    //                 ? SvgPicture.asset(
    //                     imagePath + "exp.svg",
    //                     color: colors.primary,
    //                   )
    //                 : SvgPicture.asset(
    //                     imagePath + "exp2.svg",
    //                     color: colors.primary,
    //                   ),
    //             // text: _selBottom == 2 ? getTranslated(context, 'SALE') : null,
    //             text:
    //                 _selBottom == 2 ? getTranslated(context, 'EXPLORE') : null,
    //           ),
    //           Tab(
    //             icon: Selector<UserProvider, String>(
    //               builder: (context, data, child) {
    //                 return Stack(
    //                   children: [
    //                     Center(
    //                       child: _selBottom == 3
    //                           ? SvgPicture.asset(
    //                               imagePath + "cart01.svg",
    //                               color: colors.primary,
    //                             )
    //                           : SvgPicture.asset(
    //                               imagePath + "cart.svg",
    //                               color: colors.primary,
    //                             ),
    //                     ),
    //                     (data != null && data.isNotEmpty && data != "0")
    //                         ? new Positioned.directional(
    //                             bottom: _selBottom == 3 ? 6 : 20,
    //                             textDirection: Directionality.of(context),
    //                             end: 0,
    //                             child: Container(
    //                               decoration: BoxDecoration(
    //                                   shape: BoxShape.circle,
    //                                   color: colors.primary),
    //                               child: new Center(
    //                                 child: Padding(
    //                                   padding: EdgeInsets.all(3),
    //                                   child: new Text(
    //                                     data,
    //                                     style: TextStyle(
    //                                         fontSize: 7,
    //                                         fontWeight: FontWeight.bold,
    //                                         color: Theme.of(context)
    //                                             .colorScheme
    //                                             .white),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           )
    //                         : Container()
    //                   ],
    //                 );
    //               },
    //               selector: (_, homeProvider) => homeProvider.curCartCount,
    //             ),
    //             text: _selBottom == 3 ? getTranslated(context, 'CART') : null,
    //           ),
    //           Tab(
    //             icon: _selBottom == 4
    //                 ? SvgPicture.asset(
    //                     imagePath + "profile01.svg",
    //                     color: colors.primary,
    //                   )
    //                 : SvgPicture.asset(
    //                     imagePath + "profile.svg",
    //                     color: colors.primary,
    //                   ),
    //             text:
    //                 _selBottom == 4 ? getTranslated(context, 'ACCOUNT') : null,
    //           ),
    //         ],
    //         indicator: UnderlineTabIndicator(
    //           borderSide: BorderSide(color: colors.primary, width: 5.0),
    //           insets: EdgeInsets.fromLTRB(50.0, 0.0, 50.0, 70.0),
    //         ),
    //         labelColor: colors.primary,
    //         labelStyle: TextStyle(fontSize: 8, fontWeight: FontWeight.w600),
    //       ),
    //     ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
