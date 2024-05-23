import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tlkmartuser/Helper/ApiBaseHelper.dart';
import 'package:tlkmartuser/Helper/AppBtn.dart';
import 'package:tlkmartuser/Helper/Color.dart';
import 'package:tlkmartuser/Helper/Constant.dart';
import 'package:tlkmartuser/Helper/Session.dart';
import 'package:tlkmartuser/Helper/SimBtn.dart';
import 'package:tlkmartuser/Helper/String.dart';
import 'package:tlkmartuser/Helper/widgets.dart';
import 'package:tlkmartuser/Model/Brand_Model.dart';
import 'package:tlkmartuser/Model/Master_Tab_Model.dart';
import 'package:tlkmartuser/Model/Model.dart';
import 'package:tlkmartuser/Model/Section_Model.dart';
import 'package:tlkmartuser/Provider/CartProvider.dart';
import 'package:tlkmartuser/Provider/CategoryProvider.dart';
import 'package:tlkmartuser/Provider/FavoriteProvider.dart';
import 'package:tlkmartuser/Provider/HomeProvider.dart';
import 'package:tlkmartuser/Provider/SettingProvider.dart';
import 'package:tlkmartuser/Screen/Favorite.dart';
import 'package:tlkmartuser/Screen/Search.dart';
import 'package:tlkmartuser/Screen/SellerList.dart';
import 'package:tlkmartuser/Screen/Seller_Details.dart';
import 'package:tlkmartuser/Screen/SubCategory.dart';
import 'package:http/http.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:version/version.dart';
import '../Provider/UserProvider.dart';
import 'Login.dart';
import 'ProductList.dart';
import 'Product_Detail.dart';
import 'SectionList.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

List<SectionModel> sectionList = [];
List<Product> catList = [];
List<Product> popularList = [];
ApiBaseHelper apiBaseHelper = ApiBaseHelper();
List<String> tagList = [];
List<Product> sellerList = [];
int count = 1;
List<Model> homeSliderList = [];
List<MasterModel> masterTabList = [];
List<Widget> pages = [];
List<Product> favList = [];
List<Product> productList = [];
RangeValues? _currentRangeValues;
List<BrandModel> brandList = [];

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, TickerProviderStateMixin {
  bool _isNetworkAvail = true;

  final _controller = PageController();
  late Animation buttonSqueezeanimation;
  late AnimationController buttonController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  List<Model> offerImages = [];
  bool listType = true;
  var filterList;
  int isSelectedTab = 1;
  int isSelectedCategory = 0;
  List<String>? attListId;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  String minPrice = "0", maxPrice = "0";
  List<String>? attsubList;
  List<String> selectedId = [];
  ChoiceChip? tagChip, choiceChip;
  String selId = "";
  bool _isLoading = true;
  String sortBy = 'p.id', orderBy = "DESC";
  bool _isFirstLoad = true;
  List<Product> tempList = [];
  bool isLoadingmore = true;
  ScrollController controller = ScrollController();
  //String? curPin;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _refresh();
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      new CurvedAnimation(
        parent: buttonController,
        curve: new Interval(
          0.0,
          0.150,
        ),
      ),
    );

    WidgetsBinding.instance!.addPostFrameCallback((_) => _animateSlider());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 120),
          child: Selector<HomeProvider, bool>(
            builder: (context, data, child) {
              return data
                  ? masterTabLoading()
                  : Container(
                color: colors.primary,
                width: MediaQuery.of(context).size.width,
                height: 100,
                padding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: masterTabList
                      .map(
                        (masterData) => InkWell(
                        onTap: () {
                          setState(() {
                            isSelectedTab =
                                int.parse(masterData.id ?? '1');
                            context.read<HomeProvider>().setMasterCategory(isSelectedTab);
                          });
                          _refresh();
                        },
                        child: TabBar(
                            iconUrl:
                            '${imageUrl + (masterData.image ?? '')}',
                            isSelected: isSelectedTab ==
                                int.parse(masterData.id ?? '1'),
                            title: masterData.name ?? '')),
                  )
                      .toList(),

                  //  [
                  //   InkWell(
                  //       onTap: () {
                  //         setState(() {
                  //           isSelectedTab = 0;
                  //         });
                  //       },
                  //       child: TabBar(
                  //           iconUrl: 'assets/images/doc.png',
                  //           isSelected: isSelectedTab == 0
                  //           title: 'Tikmart')),
                  //   InkWell(
                  //       onTap: () {
                  //         setState(() {
                  //           isSelectedTab = 1;
                  //         });
                  //       },
                  //       child: TabBar(
                  //           iconUrl: 'assets/images/doc.png',
                  //           isSelected: isSelectedTab == 1,
                  //           title: 'Grocery')),
                  //   InkWell(
                  //       onTap: () {
                  //         setState(() {
                  //           isSelectedTab = 2;
                  //         });
                  //       },
                  //       child: TabBar(
                  //           iconUrl: 'assets/images/doc.png',
                  //           isSelected: isSelectedTab == 2,
                  //           title: 'Fashion')),
                  // ],
                ),
              );
            },
            selector: (_, homeProvider) => homeProvider.masterTabLoading,
          ),
        ),
        body:
        // isSelectedTab == 0
        //     ?
        _isNetworkAvail
            ? RefreshIndicator(
          color: colors.primary,
          key: _refreshIndicatorKey,
          onRefresh: _refresh,
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _search(),
              // _deliverPincode(),
              _slider(),
              _catList(),
              // _slider(),
              _section(),

              _brand(),

              _favDetails(),

              SizedBox(
                height: 20,
              ),
              forYouWidgetWithFilter(),
              SizedBox(
                height: 20,
              ),
              _seller(),
            ],
          ),
        )
            : noInternet(context)
      // : isSelectedTab == 1
      //     ? Container()
      //     : Container(),
    );
  }

  Widget forYouWidgetWithFilter() {
    return Selector<HomeProvider, bool>(
      selector: (_, homeProvider) => homeProvider.productLoading,
      builder: (context, value, child) {
        return value
            ? Container(
            width: double.infinity,
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          color: Colors.amber.shade100,
          // height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "For You",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: colors.blackTemp,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              filterOptions(),
              SizedBox(
                height: 20,
              ),
              productList.length == 0
                  ? getNoItem(context)
                  :
              //  listType
              //     ? ListView.builder(
              //         shrinkWrap: true,
              //         itemCount: productList.length,
              //         physics: NeverScrollableScrollPhysics(),
              //         itemBuilder: (context, index) {
              //           return listTileItem(productList[index]);
              //         },
              //       )
              //     : //Container()

              GridView.count(
                  shrinkWrap: true,
                  padding:
                  EdgeInsetsDirectional.symmetric(horizontal: 20),
                  crossAxisCount: 2,
                  // controller: controller,
                  childAspectRatio: 0.78,
                  physics: NeverScrollableScrollPhysics(),
                  children: List.generate(
                    (offset < total)
                        ? productList.length
                        : productList.length,
                        (index) {
                      return favProductItem(productList[index]);
                    },
                  )),
            ],
          ),
        );
      },
    );
    // return
  }

  Widget _favDetails() {
    return Selector<FavoriteProvider, bool>(
      child: Container(),
      builder: (context, value, child) {
        return value
            ? Container(
            width: double.infinity,
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : favList.isEmpty
            ? Container()
            : Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "WishList",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                            color: colors.blackTemp,
                            fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Favorite(),
                            ),
                          );
                        },
                        child: Text(
                          "View More",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).orientation ==
                    Orientation.portrait
                    ? deviceHeight! * 0.25
                    : deviceHeight!,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: favList.length,
                  itemBuilder: (context, index) {
                    return Container(
                        height: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                            ? deviceHeight! * 0.25
                            : deviceHeight! * 0.5,
                        width: deviceWidth! * 0.45,
                        child: favProductItem(favList[index]));
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      width: 10,
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
      selector: (_, favoriteProvider) => favoriteProvider.isLoading,
    );
  }

  Widget favProductItem(Product product) {
    String? offPer;
    double price = double.parse(product.prVarientList![0].disPrice!);
    if (price == 0) {
      price = double.parse(product.prVarientList![0].price!);
    } else {
      double off = double.parse(product.prVarientList![0].price!) - price;
      offPer = ((off * 100) / double.parse(product.prVarientList![0].price!))
          .toStringAsFixed(2);
    }

    double width = deviceWidth! * 0.5;

    return Card(
      elevation: 1.0,

      margin: EdgeInsetsDirectional.all(5),
      //end: pad ? 5 : 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                /*       child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag:
                        "${sectionList[secPos].productList![index].id}$secPos$index",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(
                              sectionList[secPos].productList![index].image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(width),

                          // errorWidget: (context, url, e) => placeHolder(width),
                          placeholder: placeHolder(width),
                        ),
                      )),*/
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: double.maxFinite,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                              image: CachedNetworkImageProvider(product.image!),
                              fit: BoxFit.fill)),
                    ),
                    // ClipRRect(
                    //   borderRadius: BorderRadius.circular(25),
                    //   child: Hero(
                    //     transitionOnUserGestures: true,
                    //     tag:
                    //         "${sectionList[secPos].productList![index].id}$secPos$index",
                    //     child: FadeInImage(
                    //       fadeInDuration: Duration(milliseconds: 150),
                    //       image: CachedNetworkImageProvider(
                    //           sectionList[secPos].productList![index].image!),
                    //       height: double.maxFinite,
                    //       width: double.maxFinite,
                    //       imageErrorBuilder: (context, error, stackTrace) =>
                    //           erroWidget(double.maxFinite),
                    //       fit: BoxFit.contain,
                    //       placeholder: placeHolder(width),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    " " + CUR_CURRENCY! + " " + price.toString(),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    double.parse(product.prVarientList![0].disPrice!) != 0
                        ? CUR_CURRENCY! + "" + product.prVarientList![0].price!
                        : "",
                    style: Theme.of(context).textTheme.overline!.copyWith(
                        decoration: TextDecoration.lineThrough,
                        letterSpacing: 0,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                product.name!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.black),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              double.parse(product.prVarientList![0].disPrice!) != 0
                  ? Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      "$offPer%",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .overline!
                          .copyWith(
                          color: Colors.orange,
                          letterSpacing: 0,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )
                  : Container(
                height: 5,
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              // transitionDuration: Duration(milliseconds: 150),
              pageBuilder: (_, __, ___) => ProductDetail(
                model: product,
                secPos: 0,
                index: 0,
                list: true,
                //  title: sectionList[secPos].title,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _brand() {
    return Selector<HomeProvider, bool>(
      selector: (_, homeProvider) => homeProvider.brandLoading,
      builder: (context, data, child) {
        return data
            ? Container(
            width: double.infinity,
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : Container(
            decoration: BoxDecoration(color: colors.primary.withOpacity(0.2)
              // gradient: LinearGradient(
              //   begin: Alignment.centerLeft,
              //   end: Alignment.topCenter,
              //   colors: [
              //     Color.fromRGBO(205, 193, 255, 1.0),
              //     Colors.amber.shade100,
              //   ],
              // ),
            ),
            padding:
            const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product With Brand",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: colors.blackTemp,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 40,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: brandList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          setState(() {
                            isSelectedCategory = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: isSelectedCategory == index
                                          ? colors.primary
                                          : Colors.transparent,
                                      width: 4)),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          height: 30,
                          child: Row(
                            children: [
                              CachedNetworkImage(
                                  imageUrl:
                                  "$imageUrl${brandList[index].image ?? ''}"),
                              SizedBox(
                                width: 5,
                              ),
                              Text('${brandList[index].name}')
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 10,
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                brandList[isSelectedCategory].productList == null ||
                    brandList[isSelectedCategory].productList!.length ==
                        0
                    ? Container()
                    : Container(
                  width: MediaQuery.of(context).size.width,
                  height: deviceHeight! * 0.25,
                  child: ListView.separated(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: brandList[isSelectedCategory]
                        .productList!
                        .length,
                    itemBuilder: (context, index) {
                      return Container(
                        height:
                        MediaQuery.of(context).orientation ==
                            Orientation.portrait
                            ? deviceHeight! * 0.25
                            : deviceHeight! * 0.5,
                        width: deviceWidth! * 0.45,
                        child: favProductItem(
                            brandList[isSelectedCategory].productList![index]),
                      );

                      // InkWell(
                      //   onTap: () {
                      //     setState(() {
                      //       isSelectedCategory = index;
                      //     });
                      //   },
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //         border: Border(
                      //             bottom: BorderSide(
                      //                 color:
                      //                     isSelectedCategory == index
                      //                         ? colors.primary
                      //                         : Colors.transparent,
                      //                 width: 4)),
                      //         color: Colors.white,
                      //         borderRadius:
                      //             BorderRadius.circular(10)),
                      //     padding: EdgeInsets.symmetric(
                      //         horizontal: 10, vertical: 5),
                      //     height: 30,
                      //     child: Row(
                      //       children: [
                      //         CachedNetworkImage(
                      //             imageUrl:
                      //                 catList[index].image ?? ''),
                      //         SizedBox(
                      //           width: 5,
                      //         ),
                      //         Text('${catList[index].name}')
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(
                        width: 10,
                      );
                    },
                  ),
                ),
              ],
            ));
      },
    );
  }

  subCatItem(int index, List<Product> subList) {
    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: FadeInImage(
                      image: CachedNetworkImageProvider(subList![index].image!),
                      fadeInDuration: Duration(milliseconds: 150),
                      imageErrorBuilder: (context, error, stackTrace) =>
                          erroWidget(50),
                      placeholder: placeHolder(50),
                    )),
              ),
            ),
            Text(
              subList![index].name! + "\n",
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.caption!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor, fontSize: 16),
            )
          ],
        ),
      ),
      onTap: () {
        if (subList![index].subList == null ||
            subList![index].subList!.length == 0) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProductList(
                  name: subList![index].name,
                  id: subList![index].id,
                  tag: false,
                  fromSeller: false,
                ),
              ));
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SubCategory(
                  subList: subList![index].subList,
                  title: subList![index].name ?? "",
                ),
              ));
        }
      },
    );
  }

  Widget TabBar(
      {required String title,
        required String iconUrl,
        required bool isSelected}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isSelected ? Colors.amber : Colors.white,
      ),
      child: Row(
        children: [
          Container(
            height: 25,
            width: 25,
            child: Image(image: CachedNetworkImageProvider(iconUrl)),
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            title,
            style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor, fontSize: 14),
          )
        ],
      ),
    );
  }

  Future<Null> _refresh() {
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setSecLoading(true);
    context.read<HomeProvider>().setSliderLoading(true);
    context.read<HomeProvider>().setCatLoading(true);
    context.read<HomeProvider>().setProductLoading(true);
    context.read<HomeProvider>().setBrandLoading(true);
    //  context.read<HomeProvider>().setMasterTabLoading(true);

    return callApi();
  }

  Widget _slider() {
    double height = deviceWidth! / 2.1;
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? sliderLoading()
            : Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: height,
                  width: double.infinity,
                  child: PageView.builder(
                    itemCount: homeSliderList.length,
                    scrollDirection: Axis.horizontal,
                    controller: _controller,
                    physics: AlwaysScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        context.read<HomeProvider>().setCurSlider(index);
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return pages[index];
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: map<Widget>(
                homeSliderList,
                    (index, url) {
                  return Container(
                    width: context.read<HomeProvider>().curSlider == index
                        ? 20.0
                        : 10.0,
                    height: 5.0,
                    margin: EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color:
                      context.read<HomeProvider>().curSlider == index
                          ? Theme.of(context).colorScheme.fontColor
                          : Colors.grey.shade400,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      selector: (_, homeProvider) => homeProvider.sliderLoading,
    );
  }

  _search() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey.shade200, borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ListTile(
        dense: true,
        minLeadingWidth: 10,
        leading: Icon(
          CupertinoIcons.search,
          size: 30,
        ),
        title: Text(
          getTranslated(context, 'TITLE1_LBL')!,
          style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Search(),
              ));
        },
      ),
    );
  }

  void _animateSlider() {
    Future.delayed(Duration(seconds: 30)).then(
          (_) {
        if (mounted) {
          int nextPage = _controller.hasClients
              ? _controller.page!.round() + 1
              : _controller.initialPage;

          if (nextPage == homeSliderList.length) {
            nextPage = 0;
          }
          if (_controller.hasClients)
            _controller
                .animateToPage(nextPage,
                duration: Duration(milliseconds: 200), curve: Curves.linear)
                .then((_) => _animateSlider());
        }
      },
    );
  }

  _singleSection(int index) {
    Color back;
    int pos = index % 5;
    if (pos == 0)
      back = Theme.of(context).colorScheme.back1;
    else if (pos == 1)
      back = Theme.of(context).colorScheme.back2;
    else if (pos == 2)
      back = Theme.of(context).colorScheme.back3;
    else if (pos == 3)
      back = Theme.of(context).colorScheme.back4;
    else
      back = Theme.of(context).colorScheme.back5;

    return sectionList[index].productList!.length > 0
        ? Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // _getHeading(sectionList[index].title ?? "", index),
              _getSection(index),
            ],
          ),
        ),
        // offerImages.length > index ? _getOfferImage(index) : Container(),
      ],
    )
        : Container();
  }

  _getHeading(String title, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.centerRight,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Color(0xFFF88112),
                ),
                padding: EdgeInsetsDirectional.only(
                    start: 10, bottom: 3, top: 3, end: 10),
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle2!
                      .copyWith(color: colors.blackTemp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              /*   Positioned(
                  // clipBehavior: Clip.hardEdge,
                  // margin: EdgeInsets.symmetric(horizontal: 20),

                  right: -14,
                  child: SvgPicture.asset("assets/images/eshop.svg"))*/
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(sectionList[index].shortDesc ?? "",
                    style: Theme.of(context).textTheme.subtitle1!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor)),
              ),
              TextButton(
                style: TextButton.styleFrom(
                    minimumSize: Size.zero, // <
                    backgroundColor: (Theme.of(context).colorScheme.white),
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
                child: Text(
                  getTranslated(context, 'SHOP_NOW')!,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  SectionModel model = sectionList[index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SectionList(
                        index: index,
                        section_model: model,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  _getOfferImage(index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: InkWell(
        child: FadeInImage(
          fit: BoxFit.contain,
          fadeInDuration: Duration(milliseconds: 150),
          image: CachedNetworkImageProvider(offerImages[index].image!),
          width: double.maxFinite,
          imageErrorBuilder: (context, error, stackTrace) => erroWidget(50),

          // errorWidget: (context, url, e) => placeHolder(50),
          placeholder: AssetImage(
            "assets/images/sliderph.png",
          ),
        ),
        onTap: () {
          if (offerImages[index].type == "products") {
            Product? item = offerImages[index].list;

            Navigator.push(
              context,
              PageRouteBuilder(
                //transitionDuration: Duration(seconds: 1),
                pageBuilder: (_, __, ___) =>
                    ProductDetail(model: item, secPos: 0, index: 0, list: true
                      //  title: sectionList[secPos].title,
                    ),
              ),
            );
          } else if (offerImages[index].type == "categories") {
            Product item = offerImages[index].list;
            if (item.subList == null || item.subList!.length == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }

  _getSection(int i) {
    var orient = MediaQuery.of(context).orientation;

    return sectionList[i].style == DEFAULT
        ? Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/bg_home.png'),
                fit: BoxFit.fill)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          children: [
            Text(
              sectionList[i].title ?? "",
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: colors.blackTemp,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(
              height: 30,
            ),
            GridView.count(
              // mainAxisSpacing: 12,
              // crossAxisSpacing: 12,
              padding: EdgeInsetsDirectional.only(top: 5),
              crossAxisCount: 2,
              shrinkWrap: true,
              childAspectRatio: 0.8, //0.750,
              //  childAspectRatio: 1.0,
              physics: NeverScrollableScrollPhysics(),
              children:
              //  [
              //   Container(height: 500, width: 1200, color: Colors.red),
              //   Text("hello"),
              //   Container(height: 10, width: 50, color: Colors.green),
              // ]
              List.generate(
                sectionList[i].productList!.length < 4
                    ? sectionList[i].productList!.length
                    : 4,
                    (index) {
                  // return Container(
                  //   width: 600,
                  //   height: 50,
                  //   color: Colors.red,
                  // );

                  return productItem(
                      i, index, index % 2 == 0 ? true : false);
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            sectionList[i].productList!.length > 0
                ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductList(
                            name: sectionList[i].title ?? "",
                            id: sectionList[i].id,
                            tag: false,
                            fromSeller: false,
                          ),
                        ));
                  },
                  child: Text(
                    "SEE MORE",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(
                        color: colors.primary,
                        fontStyle: FontStyle.italic,fontSize: 14,fontWeight:FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Image.asset(
                  'assets/images/Arrow.png',
                  color: colors.primary,
                )
              ],
            )
                : Container()
          ],
        ))
        : sectionList[i].style == STYLE1
        ? sectionList[i].productList!.length > 3
        ? Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    sectionList[i].title ?? "",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium!
                        .copyWith(
                        color: colors.blackTemp,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductList(
                              name: sectionList[i].title ?? "",
                              id: sectionList[i].id,
                              tag: false,
                              fromSeller: false,
                            ),
                          ));
                    },
                    child: Text(
                      "See More",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Flexible(
                  flex: 2,
                  //  fit: FlexFit.loose,
                  child: Container(
                    height: orient == Orientation.portrait
                        ? deviceHeight! * 0.5
                        : deviceHeight!,
                    child: productItem(i, 0, true),
                  ),
                ),
                Flexible(
                  flex: 2,
                  // fit: FlexFit.loose,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: orient == Orientation.portrait
                            ? deviceHeight! * 0.25
                            : deviceHeight! * 0.5,
                        child: productItem(i, 1, false),
                      ),
                      Container(
                        height: orient == Orientation.portrait
                            ? deviceHeight! * 0.25
                            : deviceHeight! * 0.5,
                        child: productItem(i, 2, false),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    )
        : Container()
        : sectionList[i].style == STYLE2
        ?
    // Padding(
    //     padding: const EdgeInsets.all(15.0),
    //     child: Row(

    //       children: [

    //         Flexible(
    //           flex: 2,
    //           fit: FlexFit.loose,
    //           child: Column(
    //             mainAxisSize: MainAxisSize.min,
    //             children: [
    //               Container(
    //                   height: orient == Orientation.portrait
    //                       ? deviceHeight! * 0.2
    //                       : deviceHeight! * 0.5,
    //                   child: productItem(i, 0, true)),
    //               Container(
    //                 height: orient == Orientation.portrait
    //                     ? deviceHeight! * 0.2
    //                     : deviceHeight! * 0.5,
    //                 child: productItem(i, 1, true),
    //               ),
    //             ],
    //           ),
    //         ),
    //         Flexible(
    //           flex: 3,
    //           fit: FlexFit.loose,
    //           child: Container(
    //             height: orient == Orientation.portrait
    //                 ? deviceHeight! * 0.4
    //                 : deviceHeight,
    //             child: productItem(i, 2, false),
    //           ),
    //         ),
    //       ],
    //     ),
    //   )
    sectionList[i].productList == null
        ? Container()
        : Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      color: Colors.blue.shade100,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "New Product",
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(
                        color: colors.blackTemp,
                        fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductList(
                            name: sectionList[i].title ?? "",
                            id: sectionList[i].id,
                            tag: false,
                            fromSeller: false,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "View More",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).orientation ==
                Orientation.portrait
                ? deviceHeight! * 0.25
                : deviceHeight!,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: sectionList[i].productList!.length,
              itemBuilder: (context, index) {
                return Container(
                  height:
                  MediaQuery.of(context).orientation ==
                      Orientation.portrait
                      ? deviceHeight! * 0.25
                      : deviceHeight!,
                  width: deviceWidth! * 0.45,
                  child: productItem(i, index, false),
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  width: 10,
                );
              },
            ),
          )
        ],
      ),
    )
        : sectionList[i].style == STYLE3
        ? Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
              height: orient == Orientation.portrait
                  ? deviceHeight! * 0.3
                  : deviceHeight! * 0.6,
              child: productItem(i, 0, false),
            ),
          ),
          Container(
            height: orient == Orientation.portrait
                ? deviceHeight! * 0.2
                : deviceHeight! * 0.5,
            child: Row(
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 1, true),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 2, true),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.loose,
                  child: productItem(i, 3, false),
                ),
              ],
            ),
          ),
        ],
      ),
    )
        : sectionList[i].style == STYLE4
        ? Container(
      decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.2)),
      padding: const EdgeInsets.all(15.0),
      child: GridView.count(
        // mainAxisSpacing: 12,
        // crossAxisSpacing: 12,
        padding: EdgeInsetsDirectional.only(top: 5),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 0.8, //0.750,
        //  childAspectRatio: 1.0,
        physics: NeverScrollableScrollPhysics(),
        children:
        //  [
        //   Container(height: 500, width: 1200, color: Colors.red),
        //   Text("hello"),
        //   Container(height: 10, width: 50, color: Colors.green),
        // ]
        List.generate(
          sectionList[i].productList!.length < 4
              ? sectionList[i].productList!.length
              : 4,
              (index) {
            // return Container(
            //   width: 600,
            //   height: 50,
            //   color: Colors.red,
            // );

            return productItem(
                i, index, index % 2 == 0 ? true : false);
          },
        ),
      ),
      // Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     Flexible(
      //         flex: 1,
      //         //fit: FlexFit.loose,
      //         child: Container(
      //             height: orient == Orientation.portrait
      //                 ? deviceHeight! * 0.25
      //                 : deviceHeight! * 0.5,
      //             child: productItem(i, 0, false))),
      //     sectionList[i].productList!.length > 2
      //         ? Container(
      //             height: orient == Orientation.portrait
      //                 ? deviceHeight! * 0.2
      //                 : deviceHeight! * 0.5,
      //             child: Row(
      //               children: [
      //                 Flexible(
      //                   flex: 1,
      //                   fit: FlexFit.loose,
      //                   child: productItem(i, 1, true),
      //                 ),
      //                 Flexible(
      //                   flex: 1,
      //                   fit: FlexFit.loose,
      //                   child: productItem(i, 2, false),
      //                 ),
      //               ],
      //             ),
      //           )
      //         : Container(),
      //   ],
      // ),
    )
        : Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.count(
        padding: EdgeInsetsDirectional.only(top: 5),
        crossAxisCount: 2,
        shrinkWrap: true,
        childAspectRatio: 1.2,
        physics: NeverScrollableScrollPhysics(),
        mainAxisSpacing: 0,
        crossAxisSpacing: 0,
        children: List.generate(
          sectionList[i].productList!.length < 6
              ? sectionList[i].productList!.length
              : 6,
              (index) {
            return productItem(
                i, index, index % 2 == 0 ? true : false);
          },
        ),
      ),
    );
  }

  Widget productItem(int secPos, int index, bool pad) {
    if (sectionList[secPos].productList!.length > index) {
      String? offPer;
      double price = double.parse(
          sectionList[secPos].productList![index].prVarientList![0].disPrice!);
      if (price == 0) {
        price = double.parse(
            sectionList[secPos].productList![index].prVarientList![0].price!);
      } else {
        double off = double.parse(sectionList[secPos]
            .productList![index]
            .prVarientList![0]
            .price!) -
            price;
        offPer = ((off * 100) /
            double.parse(sectionList[secPos]
                .productList![index]
                .prVarientList![0]
                .price!))
            .toStringAsFixed(2);
      }

      double width = deviceWidth! * 0.5;

      return Card(
        elevation: 0.0,

        margin: EdgeInsetsDirectional.all(5),
        //end: pad ? 5 : 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  /*       child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5),
                          topRight: Radius.circular(5)),
                      child: Hero(
                        tag:
                        "${sectionList[secPos].productList![index].id}$secPos$index",
                        child: FadeInImage(
                          fadeInDuration: Duration(milliseconds: 150),
                          image: NetworkImage(
                              sectionList[secPos].productList![index].image!),
                          height: double.maxFinite,
                          width: double.maxFinite,
                          fit: extendImg ? BoxFit.fill : BoxFit.contain,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              erroWidget(width),

                          // errorWidget: (context, url, e) => placeHolder(width),
                          placeholder: placeHolder(width),
                        ),
                      )),*/
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                    sectionList[secPos]
                                        .productList![index]
                                        .image!),
                                fit: BoxFit.fill)),
                      ),
                      favImg(secPos, index, pad)
                      // ClipRRect(
                      //   borderRadius: BorderRadius.circular(25),
                      //   child: Hero(
                      //     transitionOnUserGestures: true,
                      //     tag:
                      //         "${sectionList[secPos].productList![index].id}$secPos$index",
                      //     child: FadeInImage(
                      //       fadeInDuration: Duration(milliseconds: 150),
                      //       image: CachedNetworkImageProvider(
                      //           sectionList[secPos].productList![index].image!),
                      //       height: double.maxFinite,
                      //       width: double.maxFinite,
                      //       imageErrorBuilder: (context, error, stackTrace) =>
                      //           erroWidget(double.maxFinite),
                      //       fit: BoxFit.contain,
                      //       placeholder: placeHolder(width),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      " " + CUR_CURRENCY! + " " + price.toString(),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      double.parse(sectionList[secPos]
                          .productList![index]
                          .prVarientList![0]
                          .disPrice!) !=
                          0
                          ? CUR_CURRENCY! +
                          "" +
                          sectionList[secPos]
                              .productList![index]
                              .prVarientList![0]
                              .price!
                          : "",
                      style: Theme.of(context).textTheme.overline!.copyWith(
                          decoration: TextDecoration.lineThrough,
                          letterSpacing: 0,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  sectionList[secPos].productList![index].name!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.black),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                double.parse(sectionList[secPos]
                    .productList![index]
                    .prVarientList![0]
                    .disPrice!) !=
                    0
                    ? Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        "$offPer%",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .overline!
                            .copyWith(
                            color: Colors.orange,
                            letterSpacing: 0,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                )
                    : Container(
                  height: 5,
                ),
              ],
            ),
          ),
          onTap: () {
            Product model = sectionList[secPos].productList![index];
            Navigator.push(
              context,
              PageRouteBuilder(
                // transitionDuration: Duration(milliseconds: 150),
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: model, secPos: secPos, index: index, list: false
                  //  title: sectionList[secPos].title,
                ),
              ),
            );
          },
        ),
      );
    } else
      return Container();
  }

  Widget favImg(int secPos, int index, bool pad) {
    return Positioned.directional(
      textDirection: Directionality.of(context),
      // end: 0,
      // bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: sectionList[secPos].productList![index].isFavLoading!
                  ? Padding(
                padding: const EdgeInsets.all(5.0),
                child: Container(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 0.7,
                    )),
              )
                  : Selector<FavoriteProvider, List<String?>>(
                builder: (context, data, child) {
                  // print("object*****${data[0].id}***${widget.model!.id}");

                  return InkWell(
                      child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Icon(
                            !data.contains(sectionList[secPos]
                                .productList![index]
                                .id)
                                ? Icons.favorite_border
                                : Icons.favorite,
                            size: 15,
                            color: Colors.orange,
                          )),
                      onTap: () {
                        if (CUR_USERID != null) {
                          !data.contains(sectionList[secPos]
                              .productList![index]
                              .id)
                              ? _setFav(index, secPos)
                              : _removeFav(index, secPos);
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Login()),
                          );
                        }
                      });
                },
                selector: (_, provider) => provider.favIdList,
              )),
        ),
      ),
    );
  }

  _section() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
          width: double.infinity,
          child: Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.simmerBase,
            highlightColor: Theme.of(context).colorScheme.simmerHigh,
            child: sectionLoading(),
          ),
        )
            : ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: sectionList.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            print("here");
            return _singleSection(index);
          },
        );
      },
      selector: (_, homeProvider) => homeProvider.secLoading,
    );
  }

  _catList() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
            width: double.infinity,
            decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : Container(
          height: 150,
          padding: const EdgeInsets.only(top: 10, left: 10),
          child: ListView.separated(
            itemCount: catList.length < 10 ? catList.length : 10,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            physics: AlwaysScrollableScrollPhysics(),
            separatorBuilder: (context, index) {
              return SizedBox(
                width: 10,
              );
            },
            itemBuilder: (context, index) {
              // if (index == 0)
              //   return Container();
              // else
              return Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: GestureDetector(
                  onTap: () async {
                    if (catList[index].subList == null ||
                        catList[index].subList!.length == 0) {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductList(
                              name: catList[index].name,
                              id: catList[index].id,
                              tag: false,
                              fromSeller: false,
                            ),
                          ));
                    } else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubCategory(
                            title: catList[index].name!,
                            subList: catList[index].subList,
                          ),
                        ),
                      );
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: DecorationImage(
                                image: NetworkImage(
                                  "${catList[index].image}",
                                ),
                                fit: BoxFit.fill)),
                      ),
                      // CircleAvatar(
                      //   child: FadeInImage(
                      //     fadeInDuration: Duration(milliseconds: 150),
                      //     image: CachedNetworkImageProvider(
                      //       catList[index].image!,
                      //     ),
                      //     height: 50.0,
                      //     width: 50.0,
                      //     fit: BoxFit.contain,
                      //     imageErrorBuilder:
                      //         (context, error, stackTrace) =>
                      //         erroWidget(50),
                      //     placeholder: placeHolder(50),
                      //   ),
                      // ),
                      // Container(
                      //   child: Text(
                      //     catList[index].name!,
                      //     style: Theme.of(context)
                      //         .textTheme
                      //         .caption!
                      //         .copyWith(
                      //             color: Theme.of(context)
                      //                 .colorScheme
                      //                 .fontColor,
                      //             fontWeight: FontWeight.w600,
                      //             fontSize: 10),
                      //     overflow: TextOverflow.ellipsis,
                      //     textAlign: TextAlign.center,
                      //   ),
                      //   width: 50,
                      // ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          catList[index].name!.toUpperCase(),
                          style: Theme.of(context)
                              .textTheme
                              .caption!
                              .copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .fontColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        width: 70,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      selector: (_, homeProvider) => homeProvider.catLoading,
    );
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  Future<Null> callApi() async {
    UserProvider user = Provider.of<UserProvider>(context, listen: false);
    SettingProvider setting =
    Provider.of<SettingProvider>(context, listen: false);

    user.setUserId(setting.userId);

    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      getSetting();
      getSlider();
      getCat();
      getSeller();
      getSection();
      getOfferImages();
      getMasterTabsApi();
      getProduct('0');
      getBrand();
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
    return null;
  }

  Future _getFav() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      if (CUR_USERID != null) {
        Map parameter = {
          USER_ID: CUR_USERID,
          //   MASTER_TAB: isSelectedTab.toString()
        };
        apiBaseHelper.postAPICall(getFavApi, parameter).then((getdata) {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            var data = getdata["data"];

            List<Product> tempList = (data as List)
                .map((data) => new Product.fromJson(data))
                .toList();
            favList.clear();
            favList.addAll(tempList);
            context.read<FavoriteProvider>().setFavlist(tempList);
          } else {
            if (msg != 'No Favourite(s) Product Are Added')
              setSnackbar(msg!, context);
          }

          context.read<FavoriteProvider>().setLoading(false);
        }, onError: (error) {
          setSnackbar(error.toString(), context);
          context.read<FavoriteProvider>().setLoading(false);
        });
      } else {
        context.read<FavoriteProvider>().setLoading(false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  void getOfferImages() {
    Map parameter = Map();

    apiBaseHelper.postAPICall(getOfferImageApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        offerImages.clear();
        offerImages =
            (data as List).map((data) => new Model.fromSlider(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setOfferLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setOfferLoading(false);
    });
  }

  void getSection() {
    // Map parameter = {PRODUCT_LIMIT: "5", PRODUCT_OFFSET: "6"};
    Map parameter = {PRODUCT_LIMIT: "5", MASTER_TAB: isSelectedTab.toString()};

    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    // String curPin = context.read<UserProvider>().curPincode;
    // if (curPin != '') parameter[ZIPCODE] = curPin;

    apiBaseHelper.postAPICall(getSectionApi, parameter).then((getdata) {
      print(getSectionApi);
      print(parameter);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      print("Get Section Data---------: $getdata");
      sectionList.clear();
      if (!error) {
        var data = getdata["data"];
        print("Get Section Data2: $data");
        sectionList = (data as List)
            .map((data) => new SectionModel.fromJson(data))
            .toList();
      } else {
        // if (curPin != '') context.read<UserProvider>().setPincode('');
        setSnackbar(msg!, context);
        print("Get Section Error Msg: $msg");
      }
      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  String? pincode;
  void getSetting() {
    CUR_USERID = context.read<SettingProvider>().userId;
    //print("")
    Map parameter = Map();
    print(CUR_USERID);
    if (CUR_USERID != null) parameter = {USER_ID: CUR_USERID};

    apiBaseHelper.postAPICall(getSettingApi, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];

      print("Get Setting Api${getSettingApi.toString()}");
      print(parameter.toString());

      if (!error) {
        var data = getdata["data"]["system_settings"][0];
        cartBtnList = data["cart_btn_on_list"] == "1" ? true : false;
        refer = data["is_refer_earn_on"] == "1" ? true : false;
        CUR_CURRENCY = data["currency"];
        RETURN_DAYS = data['max_product_return_days'];
        MAX_ITEMS = data["max_items_cart"];
        MIN_AMT = data['min_amount'];
        CUR_DEL_CHR = data['delivery_charge'];
        String? isVerion = data['is_version_system_on'];
        extendImg = data["expand_product_images"] == "1" ? true : false;
        String? del = data["area_wise_delivery_charge"];
        print("============min cart amount =========${data[MIN_CART_AMT]}");
        MIN_ALLOW_CART_AMT = data[MIN_CART_AMT];

        if (del == "0")
          ISFLAT_DEL = true;
        else
          ISFLAT_DEL = false;

        if (CUR_USERID != null) {
          REFER_CODE = getdata['data']['user_data'][0]['referral_code'];

          pincode = getdata["data"]["user_data"][0][PINCODE];

          context
              .read<UserProvider>()
              .setPincode(getdata["data"]["user_data"][0][PINCODE]);

          if (REFER_CODE == null || REFER_CODE == '' || REFER_CODE!.isEmpty)
            generateReferral();

          context.read<UserProvider>().setCartCount(
              getdata["data"]["user_data"][0]["cart_total_items"].toString());
          context
              .read<UserProvider>()
              .setBalance(getdata["data"]["user_data"][0]["balance"]);

          _getFav();
          _getCart("0");
        }

        UserProvider user = Provider.of<UserProvider>(context, listen: false);
        SettingProvider setting =
        Provider.of<SettingProvider>(context, listen: false);
        user.setMobile(setting.mobile);
        user.setName(setting.userName);
        user.setEmail(setting.email);
        user.setProfilePic(setting.profileUrl);

        Map<String, dynamic> tempData = getdata["data"];
        if (tempData.containsKey(TAG))
          tagList = List<String>.from(getdata["data"][TAG]);

        if (isVerion == "1") {
          String? verionAnd = data['current_version'];
          String? verionIOS = data['current_version_ios'];

          PackageInfo packageInfo = await PackageInfo.fromPlatform();

          String version = packageInfo.version;

          final Version currentVersion = Version.parse(version);
          final Version latestVersionAnd = Version.parse(verionAnd.toString());
          final Version latestVersionIos = Version.parse(verionIOS.toString());

          if ((Platform.isAndroid && latestVersionAnd > currentVersion) ||
              (Platform.isIOS && latestVersionIos > currentVersion))
            updateDailog();
        }
      } else {
        setSnackbar(msg!, context);
      }
    }, onError: (error) {
      setSnackbar(error.toString(), context);
    });
  }

  Future<void> _getCart(String save) async {
    _isNetworkAvail = await isNetworkAvailable();
    int masterCategoryId = context.read<HomeProvider>().masterCategory;
    if (_isNetworkAvail) {
      try {
        var parameter = {USER_ID: CUR_USERID, SAVE_LATER: save,MASTER_TAB:masterCategoryId.toString()};

        Response response =
        await post(getCartApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        if (!error) {
          var data = getdata["data"];

          List<SectionModel> cartList = (data as List)
              .map((data) => SectionModel.fromCart(data))
              .toList();
          context.read<CartProvider>().setCartlist(cartList);
        }
      } on TimeoutException catch (_) {}
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  final _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  Future<Null> generateReferral() async {
    String refer = getRandomString(8);

    Map parameter = {
      REFERCODE: refer,
    };

    apiBaseHelper.postAPICall(validateReferalApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        REFER_CODE = refer;

        Map parameter = {
          USER_ID: CUR_USERID,
          REFERCODE: refer,
        };

        apiBaseHelper.postAPICall(getUpdateUserApi, parameter);
      } else {
        if (count < 5) generateReferral();
        count++;
      }

      context.read<HomeProvider>().setSecLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSecLoading(false);
    });
  }

  updateDailog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            title: Text(getTranslated(context, 'UPDATE_APP')!),
            content: Text(
              getTranslated(context, 'UPDATE_AVAIL')!,
              style: Theme.of(this.context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: Theme.of(context).colorScheme.fontColor),
            ),
            actions: <Widget>[
              new TextButton(
                  child: Text(
                    getTranslated(context, 'NO')!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.lightBlack,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  }),
              new TextButton(
                  child: Text(
                    getTranslated(context, 'YES')!,
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.of(context).pop(false);

                    String _url = '';
                    if (Platform.isAndroid) {
                      _url = androidLink + packageName;
                    } else if (Platform.isIOS) {
                      _url = iosLink;
                    }

                    if (await canLaunch(_url)) {
                      await launch(_url);
                    } else {
                      throw 'Could not launch $_url';
                    }
                  })
            ],
          );
        }));
  }

  Widget homeShimmer() {
    return Container(
      width: double.infinity,
      child: Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: SingleChildScrollView(
            child: Column(
              children: [
                catLoading(),
                sliderLoading(),
                sectionLoading(),
              ],
            )),
      ),
    );
  }

  Widget masterTabLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: 80,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget sliderLoading() {
    double width = deviceWidth!;
    double height = width / 2;
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          height: height,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget _buildImagePageItem(Model slider) {
    double height = deviceWidth! / 0.43;

    return GestureDetector(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: FadeInImage(
            fadeInDuration: Duration(milliseconds: 150),
            image: CachedNetworkImageProvider(slider.image!),
            height: height,
            // width: double.maxFinite,
            fit: BoxFit.fill,
            imageErrorBuilder: (context, error, stackTrace) => Image.asset(
              "assets/images/sliderph.png",
              fit: BoxFit.fill,
              height: height,
              color: colors.primary,
            ),
            placeholderErrorBuilder: (context, error, stackTrace) =>
                Image.asset(
                  "assets/images/sliderph.png",
                  fit: BoxFit.fill,
                  height: height,
                  color: colors.primary,
                ),
            placeholder: AssetImage(imagePath + "sliderph.png")),
      ),
      onTap: () async {
        int curSlider = context.read<HomeProvider>().curSlider;

        if (homeSliderList[curSlider].type == "products") {
          Product? item = homeSliderList[curSlider].list;

          Navigator.push(
            context,
            PageRouteBuilder(
                pageBuilder: (_, __, ___) => ProductDetail(
                    model: item, secPos: 0, index: 0, list: true)),
          );
        } else if (homeSliderList[curSlider].type == "categories") {
          Product item = homeSliderList[curSlider].list;
          if (item.subList == null || item.subList!.length == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductList(
                    name: item.name,
                    id: item.id,
                    tag: false,
                    fromSeller: false,
                  ),
                ));
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubCategory(
                    title: item.name!,
                    subList: item.subList,
                  ),
                ));
          }
        }
      },
    );
  }

  Widget deliverLoading() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.simmerBase,
        highlightColor: Theme.of(context).colorScheme.simmerHigh,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ));
  }

  Widget catLoading() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
                    .map((_) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.white,
                    shape: BoxShape.circle,
                  ),
                  width: 50.0,
                  height: 50.0,
                ))
                    .toList()),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          width: double.infinity,
          height: 18.0,
          color: Theme.of(context).colorScheme.white,
        ),
      ],
    );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              context.read<HomeProvider>().setCatLoading(true);
              context.read<HomeProvider>().setSecLoading(true);
              context.read<HomeProvider>().setSliderLoading(true);
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  if (mounted)
                    setState(() {
                      _isNetworkAvail = true;
                    });
                  callApi();
                } else {
                  await buttonController.reverse();
                  if (mounted) setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  _deliverPincode() {
    // String curpin = context.read<UserProvider>().curPincode;
    return GestureDetector(
      child: Container(
        // padding: EdgeInsets.symmetric(vertical: 8),
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.white,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10)),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          dense: true,
          minLeadingWidth: 10,
          leading: Icon(
            Icons.location_pin,
          ),
          title: Selector<UserProvider, String>(
            builder: (context, data, child) {
              return Text(
                data == ''
                    ? getTranslated(context, 'SELOC')!
                    : getTranslated(context, 'DELIVERTO')! + data,
                style:
                TextStyle(color: Theme.of(context).colorScheme.fontColor),
              );
            },
            selector: (_, provider) => provider.curPincode,
          ),
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
      ),
      onTap: _pincodeCheck,
    );
  }

  void _pincodeCheck() {
    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25), topRight: Radius.circular(25))),
        builder: (builder) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9),
                  child: ListView(shrinkWrap: true, children: [
                    Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20, bottom: 40, top: 30),
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: Form(
                              key: _formkey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    textCapitalization: TextCapitalization.words,
                                    validator: (val) => validatePincode(val!,
                                        getTranslated(context, 'PIN_REQUIRED')),
                                    onSaved: (String? value) {
                                      context
                                          .read<UserProvider>()
                                          .setPincode(value!);
                                      pincode = value;
                                    },
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      prefixIcon: Icon(Icons.location_on),
                                      hintText:
                                      getTranslated(context, 'PINCODEHINT_LBL'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin:
                                          EdgeInsetsDirectional.only(start: 20),
                                          width: deviceWidth! * 0.35,
                                          child: OutlinedButton(
                                            onPressed: () {
                                              context
                                                  .read<UserProvider>()
                                                  .setPincode('');

                                              context
                                                  .read<HomeProvider>()
                                                  .setSecLoading(true);
                                              getSection();
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                                getTranslated(context, 'All')!),
                                          ),
                                        ),
                                        Spacer(),
                                        SimBtn(
                                            size: 0.35,
                                            title: getTranslated(context, 'APPLY'),
                                            onBtnSelected: () async {
                                              if (validateAndSave()) {
                                                // validatePin(curPin);
                                                context
                                                    .read<HomeProvider>()
                                                    .setSecLoading(true);
                                                getSection();

                                                context
                                                    .read<HomeProvider>()
                                                    .setSellerLoading(true);
                                                sellerList.clear();
                                                getSlider();
                                                getCat();
                                                getSeller();
                                                Navigator.pop(context);
                                              }
                                            }),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ))
                  ]),
                );
                //});
              });
        });
  }

  bool validateAndSave() {
    final form = _formkey.currentState!;

    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  void getSlider() {
    // Map map = Map();
    var parms = {
      //  'pincode': pincode ?? '',
      MASTER_TAB: isSelectedTab.toString()
    };
    print("(----------------)");
    print("$parms+anjali");

    apiBaseHelper.postAPICall(getSliderApi, parms).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        print(getSliderApi.toString());

        homeSliderList =
            (data as List).map((data) => new Model.fromSlider(data)).toList();

        pages = homeSliderList.map((slider) {
          return _buildImagePageItem(slider);
        }).toList();
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setSliderLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSliderLoading(false);
    });
  }

  void getMasterTabsApi() {
    // Map map = Map();

    // var parms = {'pincode': pincode};

    apiBaseHelper.postAPICall(masterTabsApi, null).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        print(masterTabsApi.toString());

        masterTabList = (data as List)
            .map((data) => new MasterModel.fromJson(data))
            .toList();

        // datas
        //     .map<MasterTabClassModel>((i) => MasterTabClassModel.fromJson(i))
        //     .toList();

        print(masterTabList);
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setMasterTabLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setMasterTabLoading(false);
    });
  }

  void getCat() {
    Map parameter = {
      CAT_FILTER: "true",
      //    'pincode': pincode ?? "",
      MASTER_TAB: isSelectedTab.toString()
    }; //{'pincode': pincode ?? '', MASTER_TAB: isSelectedTab.toString()};
    apiBaseHelper.postAPICall(getCatApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        catList =
            (data as List).map((data) => new Product.fromCat(data)).toList();

        if (getdata.containsKey("popular_categories")) {
          var data = getdata["popular_categories"];
          popularList =
              (data as List).map((data) => new Product.fromCat(data)).toList();

          if (popularList.length > 0) {
            Product pop =
            new Product.popular("Popular", imagePath + "popular.svg");
            catList.insert(0, pop);
            context.read<CategoryProvider>().setSubList(popularList);
          }
        }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setCatLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setCatLoading(false);
    });
  }

  sectionLoading() {
    return Column(
        children: [0, 1, 2, 3, 4]
            .map((_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        width: double.infinity,
                        height: 18.0,
                        color: Theme.of(context).colorScheme.white,
                      ),
                      GridView.count(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        childAspectRatio: 1.0,
                        physics: NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: List.generate(
                          4,
                              (index) {
                            return Container(
                              width: double.infinity,
                              height: double.infinity,
                              color:
                              Theme.of(context).colorScheme.white,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            sliderLoading()
            //offerImages.length > index ? _getOfferImage(index) : Container(),
          ],
        ))
            .toList());
  }

  void getSeller() {
    String pin = context.read<UserProvider>().curPincode;
    Map parameter = {MASTER_TAB: isSelectedTab.toString()};
    if (pin != '') {
      parameter = {
        ZIPCODE: pin ?? '',
      };
      SettingProvider settingsProvider = Provider.of<SettingProvider>(context, listen: false);

      settingsProvider.setPrefrence("ZIPCODE", pin);
    }

    print(parameter.toString());

    apiBaseHelper.postAPICall(getSellerApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        print("Seller Parameter =========> $parameter");
        print("Seller Data=====================> : $getSellerApi ");
        print("Seller Data=====================> : $data ");
        sellerList =
            (data as List).map((data) => new Product.fromSeller(data)).toList();
      } else {
        setSnackbar(msg!, context);
      }
      context.read<HomeProvider>().setSellerLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setSellerLoading(false);
    });
  }

  _seller() {
    return Selector<HomeProvider, bool>(
      builder: (context, data, child) {
        return data
            ? Container(
            width: double.infinity,
            child: Shimmer.fromColors(
                baseColor: Theme.of(context).colorScheme.simmerBase,
                highlightColor: Theme.of(context).colorScheme.simmerHigh,
                child: catLoading()))
            : sellerList.isEmpty
            ? Container()
            : Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sellerList.isNotEmpty
                ? Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      getTranslated(context, 'SHOP_BY_SELLER')!,
                      style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .fontColor,
                          fontWeight: FontWeight.bold)),
                  GestureDetector(
                    child: Text(
                        getTranslated(context, 'VIEW_ALL')!),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SellerList()));
                    },
                  )
                ],
              ),
            )
                : Container(),
            Container(
              height: 150,
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: ListView.builder(
                itemCount: sellerList.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                    const EdgeInsetsDirectional.only(end: 10),
                    child: GestureDetector(
                      onTap: () {
                        print(sellerList[index].open_close_status);
                        if (sellerList[index].open_close_status ==
                            '1') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SellerProfile(
                                    sellerStoreName:
                                    sellerList[index]
                                        .store_name ??
                                        "",
                                    sellerRating:
                                    sellerList[index]
                                        .seller_rating ??
                                        "",
                                    sellerImage: sellerList[index]
                                        .seller_profile ??
                                        "",
                                    sellerName: sellerList[index]
                                        .seller_name ??
                                        "",
                                    sellerID: sellerList[index]
                                        .seller_id,
                                    storeDesc: sellerList[index]
                                        .store_description,
                                  )));
                        } else {
                          showToast("Currently Store is Off");
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.3),
                                borderRadius:
                                BorderRadius.circular(20),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        "${sellerList[index].seller_profile!}"),
                                    fit: BoxFit.fill)),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          // Padding(
                          //   padding: const EdgeInsetsDirectional.only(
                          //       bottom: 5.0),
                          //   child: CircleAvatar(
                          //     radius: 30,
                          //     backgroundImage: NetworkImage(
                          //         "${sellerList[index].seller_profile!}"),
                          //   ),

                          //   // new ClipRRect(
                          //   //   borderRadius: BorderRadius.circular(25.0),
                          //   //   child: new FadeInImage(
                          //   //     fadeInDuration:
                          //   //         Duration(milliseconds: 150),
                          //   //     image: CachedNetworkImageProvider(
                          //   //       sellerList[index].seller_profile!,
                          //   //     ),
                          //   //     height: 50.0,
                          //   //     width: 50.0,
                          //   //     fit: BoxFit.contain,
                          //   //     imageErrorBuilder:
                          //   //         (context, error, stackTrace) =>
                          //   //             erroWidget(50),
                          //   //     placeholder: placeHolder(50),
                          //   //   ),
                          //   // ),
                          // ),
                          Container(
                            child: Text(
                              sellerList[index].seller_name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                            width: 80,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      selector: (_, homeProvider) => homeProvider.sellerLoading,
    );
  }

  _setFav(
      int index,
      int secPos,
      ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? sectionList[secPos].productList![index].isFavLoading = true
                : sectionList[secPos].productList![index].isFavLoading = true;
          });

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: sectionList[secPos].productList![index].id
        };
        Response response =
        await post(setFavoriteApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);

        bool error = getdata["error"];
        String? msg = getdata["message"];
        context.read<FavoriteProvider>().setLoading(true);
        _getFav();
        if (!error) {
          index == -1
              ? sectionList[secPos].productList![index].isFav = "1"
              : sectionList[secPos].productList![index].isFav = "1";

          context
              .read<FavoriteProvider>()
              .addFavItem(sectionList[secPos].productList![index]);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? sectionList[secPos].productList![index].isFavLoading = false
                : sectionList[secPos].productList![index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  _removeFav(
      int index,
      int secPos,
      ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        if (mounted)
          setState(() {
            index == -1
                ? sectionList[secPos].productList![index].isFavLoading = true
                : sectionList[secPos].productList![index].isFavLoading = true;
          });

        var parameter = {
          USER_ID: CUR_USERID,
          PRODUCT_ID: sectionList[secPos].productList![index].id
        };
        Response response =
        await post(removeFavApi, body: parameter, headers: headers)
            .timeout(Duration(seconds: timeOut));

        var getdata = json.decode(response.body);
        bool error = getdata["error"];
        String? msg = getdata["message"];
        context.read<FavoriteProvider>().setLoading(true);
        _getFav();
        if (!error) {
          ;
          index == -1
              ? sectionList[secPos].productList![index].isFav = "0"
              : sectionList[secPos].productList![index].isFav = "0";
          context.read<FavoriteProvider>().removeFavItem(
              sectionList[secPos].productList![index]!.prVarientList![0].id!);
        } else {
          setSnackbar(msg!, context);
        }

        if (mounted)
          setState(() {
            index == -1
                ? sectionList[secPos].productList![index].isFavLoading = false
                : sectionList[secPos].productList![index].isFavLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);
      }
    } else {
      if (mounted)
        setState(() {
          _isNetworkAvail = false;
        });
    }
  }

  filterOptions() {
    return Container(
      color: Theme.of(context).colorScheme.gray,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: filterDialog,
            icon: ImageIcon(
              AssetImage('assets/images/Filter.png'),
              color: colors.blackTemp,
            ),
            label: Text(
              getTranslated(context, 'FILTER')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.black,
          ),
          // InkWell(
          //   child: Icon(
          //     listType ? Icons.grid_view : Icons.list,
          //     color: colors.primary,
          //   ),

          // ),
          TextButton.icon(
            onPressed: categoryDialog,
            //  () {
            //   productList.length != 0
            //       ? setState(() {
            //           listType = !listType;
            //         })
            //       : null;
            // },
            icon: ImageIcon(
              AssetImage('assets/images/Category11.png'),
              color: colors.blackTemp,
            ),
            label: Text(
              'Category',
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.black,
          ),
          TextButton.icon(
            onPressed: sortDialog,
            icon: ImageIcon(
              AssetImage('assets/images/Swap.png'),
              color: colors.blackTemp,
            ),
            label: Text(
              getTranslated(context, 'SORT_BY')!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.fontColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void filterDialog() {
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'FILTER')!,
                        style: Theme.of(context).textTheme.headlineSmall,
                        // style: TextStyle(
                        //   color: Theme.of(context).colorScheme.fontColor,
                        // ),
                      ),
                    ),
                  ),
                  // Padding(
                  //     padding: const EdgeInsetsDirectional.only(top: 30.0),
                  //     child: AppBar(
                  //       title: Text(
                  //         getTranslated(context, 'FILTER')!,
                  //         // style: TextStyle(
                  //         //   color: Theme.of(context).colorScheme.fontColor,
                  //         // ),
                  //       ),
                  //       centerTitle: true,
                  //       elevation: 5,
                  //       backgroundColor: Colors.white,
                  //       // leading: Builder(builder: (BuildContext context) {
                  //       //   return Container(
                  //       //     margin: EdgeInsets.all(10),
                  //       //     child: InkWell(
                  //       //       borderRadius: BorderRadius.circular(4),
                  //       //       onTap: () => Navigator.of(context).pop(),
                  //       //       child: Padding(
                  //       //         padding: const EdgeInsetsDirectional.only(end: 4.0),
                  //       //         child: Icon(Icons.arrow_back_ios_rounded,
                  //       //             color: colors.primary),
                  //       //       ),
                  //       //     ),
                  //       //   );
                  //       // }),
                  //     )),
                  Expanded(
                      child: Container(
                        color: Colors.white,
                        padding:
                        EdgeInsetsDirectional.only(start: 7.0, end: 7.0, top: 7.0),
                        child: filterList != null
                            ? ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            padding: EdgeInsetsDirectional.only(top: 10.0),
                            itemCount: filterList.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Column(
                                  children: [
                                    Container(
                                        width: deviceWidth,
                                        child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              'Price Range',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1!
                                                  .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .lightBlack,
                                                  fontWeight:
                                                  FontWeight.normal),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                            ))),
                                    RangeSlider(
                                      values: _currentRangeValues!,
                                      min: double.parse(minPrice),
                                      max: double.parse(maxPrice),
                                      activeColor: Colors.black,
                                      divisions: 100,
                                      labels: RangeLabels(
                                        _currentRangeValues!.start
                                            .round()
                                            .toString(),
                                        _currentRangeValues!.end.round().toString(),
                                      ),
                                      onChanged: (RangeValues values) {
                                        setState(() {
                                          _currentRangeValues = values;
                                        });
                                      },
                                    ),
                                  ],
                                );
                              }
                              // else {
                              //   index = index - 1;
                              //   attsubList = filterList[index]['attribute_values']
                              //       .split(',');

                              //   attListId = filterList[index]['attribute_values_id']
                              //       .split(',');

                              //   List<Widget?> chips = [];
                              //   List<String> att = filterList[index]
                              //           ['attribute_values']!
                              //       .split(',');

                              //   List<String> attSType =
                              //       filterList[index]['swatche_type'].split(',');

                              //   List<String> attSValue =
                              //       filterList[index]['swatche_value'].split(',');

                              //   for (int i = 0; i < att.length; i++) {
                              //     Widget itemLabel;
                              //     if (attSType[i] == "1") {
                              //       String clr = (attSValue[i].substring(1));

                              //       String color = "0xff" + clr;

                              //       itemLabel = Container(
                              //         width: 25,
                              //         decoration: BoxDecoration(
                              //             shape: BoxShape.circle,
                              //             color: Color(int.parse(color))),
                              //       );
                              //     } else if (attSType[i] == "2") {
                              //       itemLabel = ClipRRect(
                              //           borderRadius: BorderRadius.circular(10.0),
                              //           child: Image.network(attSValue[i],
                              //               width: 80,
                              //               height: 80,
                              //               errorBuilder:
                              //                   (context, error, stackTrace) =>
                              //                       erroWidget(80)));
                              //     } else {
                              //       itemLabel = Padding(
                              //         padding: const EdgeInsets.symmetric(
                              //             horizontal: 8.0),
                              //         child: Text(att[i],
                              //             style: TextStyle(
                              //                 color:
                              //                     selectedId.contains(attListId![i])
                              //                         ? Theme.of(context)
                              //                             .colorScheme
                              //                             .white
                              //                         : Theme.of(context)
                              //                             .colorScheme
                              //                             .fontColor)),
                              //       );
                              //     }

                              //     choiceChip = ChoiceChip(
                              //       selected: selectedId.contains(attListId![i]),
                              //       label: itemLabel,
                              //       labelPadding: EdgeInsets.all(0),
                              //       selectedColor: colors.primary,
                              //       backgroundColor:
                              //           Theme.of(context).colorScheme.white,
                              //       shape: RoundedRectangleBorder(
                              //         borderRadius: BorderRadius.circular(
                              //             attSType[i] == "1" ? 100 : 10),
                              //         side: BorderSide(
                              //             color: selectedId.contains(attListId![i])
                              //                 ? colors.primary
                              //                 : colors.black12,
                              //             width: 1.5),
                              //       ),
                              //       onSelected: (bool selected) {
                              //         attListId = filterList[index]
                              //                 ['attribute_values_id']
                              //             .split(',');

                              //         if (mounted)
                              //           setState(() {
                              //             if (selected == true) {
                              //               selectedId.add(attListId![i]);
                              //             } else {
                              //               selectedId.remove(attListId![i]);
                              //             }
                              //           });
                              //       },
                              //     );

                              //     chips.add(choiceChip);
                              //   }

                              //   return Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       Container(
                              //         width: deviceWidth,
                              //         child: Card(
                              //           elevation: 0,
                              //           child: Padding(
                              //             padding: const EdgeInsets.all(8.0),
                              //             child: new Text(
                              //               filterList[index]['name'],
                              //               style: Theme.of(context)
                              //                   .textTheme
                              //                   .subtitle1!
                              //                   .copyWith(
                              //                       color: Theme.of(context)
                              //                           .colorScheme
                              //                           .fontColor,
                              //                       fontWeight: FontWeight.normal),
                              //               overflow: TextOverflow.ellipsis,
                              //               maxLines: 2,
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //       chips.length > 0
                              //           ? Padding(
                              //               padding: const EdgeInsets.all(8.0),
                              //               child: new Wrap(
                              //                 children:
                              //                     chips.map<Widget>((Widget? chip) {
                              //                   return Padding(
                              //                     padding:
                              //                         const EdgeInsets.all(2.0),
                              //                     child: chip,
                              //                   );
                              //                 }).toList(),
                              //               ),
                              //             )
                              //           : Container()

                              //       /*    (filter == filterList[index]["name"])
                              //       ? ListView.builder(
                              //           shrinkWrap: true,
                              //           physics:
                              //               NeverScrollableScrollPhysics(),
                              //           itemCount: attListId!.length,
                              //           itemBuilder: (context, i) {

                              //             */ /*       return CheckboxListTile(
                              //           dense: true,
                              //           title: Text(attsubList![i],
                              //               style: Theme.of(context)
                              //                   .textTheme
                              //                   .subtitle1!
                              //                   .copyWith(
                              //                       color: Theme.of(context).colorScheme.lightBlack,
                              //                       fontWeight:
                              //                           FontWeight.normal)),
                              //           value: selectedId
                              //               .contains(attListId![i]),
                              //           activeColor: colors.primary,
                              //           controlAffinity:
                              //               ListTileControlAffinity.leading,
                              //           onChanged: (bool? val) {
                              //             if (mounted)
                              //               setState(() {
                              //                 if (val == true) {
                              //                   selectedId.add(attListId![i]);
                              //                 } else {
                              //                   selectedId
                              //                       .remove(attListId![i]);
                              //                 }
                              //               });
                              //           },
                              //         );*/ /*
                              //           })
                              //       : Container()*/
                              //     ],
                              //   );
                              // }
                            })
                            : Container(),
                      )),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    color: Theme.of(context).colorScheme.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                            onTap: () {
                              if (mounted) Navigator.pop(context, 'Product Filter');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  getTranslated(context, 'CANCEL')!,
                                  style: Theme.of(context).textTheme.bodyLarge!,
                                ),
                              ),
                            )),
                        InkWell(
                            onTap: () {
                              if (selectedId != null) {
                                selId = selectedId.join(',');
                              }

                              if (mounted)
                                setState(() {
                                  _isLoading = true;
                                  total = 0;
                                  offset = 0;
                                  productList.clear();
                                });
                              getProduct("0");
                              Navigator.pop(context, 'Product Filter');
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  border: Border.all(color: Colors.black),
                                  borderRadius: BorderRadius.circular(10)),
                              width: MediaQuery.of(context).size.width * 0.4,
                              child: Center(
                                child: Text(
                                  getTranslated(context, 'APPLY')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(color: Colors.white),
                                ),
                              ),
                            )),
                        // SimBtn(
                        //     size: 1,
                        //     title: getTranslated(context, 'CANCEL'),
                        //     onBtnSelected: () {
                        //       if (mounted) Navigator.pop(context, 'Product Filter');
                        //     }),
                        // SimBtn(
                        //     size: 1,
                        //     title: getTranslated(context, 'APPLY'),
                        //     onBtnSelected: () {
                        //       if (selectedId != null) {
                        //         selId = selectedId.join(',');
                        //       }

                        //       if (mounted)
                        //         setState(() {
                        //           _isLoading = true;
                        //           total = 0;
                        //           offset = 0;
                        //           productList.clear();
                        //         });
                        //       getProduct("0");
                        //       Navigator.pop(context, 'Product Filter');
                        //     }),
                      ],
                    ),
                    // Row(children: <Widget>[
                    //   Container(
                    //     margin: EdgeInsetsDirectional.only(start: 20),
                    //     width: deviceWidth! * 0.4,
                    //     child: OutlinedButton(
                    //       onPressed: () {
                    //         if (mounted)
                    //           setState(() {
                    //             selectedId.clear();
                    //           });
                    //       },
                    //       child: Text(getTranslated(context, 'DISCARD')!),
                    //     ),
                    //   ),
                    //   Spacer(),
                    //
                    // ]),
                  ),

                  SizedBox(
                    height: 20,
                  )
                ]),
              );
            });
      },
    );
  }

  void getProduct(String top) async {
    //_currentRangeValues.start.round().toString(),
    // _currentRangeValues.end.round().toString(),
    Map parameter = {
      SORT: sortBy,
      ORDER: orderBy,
      LIMIT: perPage.toString(),
      OFFSET: offset.toString(),
      TOP_RETAED: top,
      MASTER_TAB: isSelectedTab.toString()
    };

    SettingProvider settingsProvider =
    Provider.of<SettingProvider>(context, listen: false);

    String? curPin = await settingsProvider.getPrefrence("ZIPCODE") ?? "";
    //  print(curPin +"ZIPCODEE");
    if (curPin != '') parameter[ZIPCODE] = curPin;
    // if (widget.tag!) parameter[TAG] = widget.name!;
    // if (widget.fromSeller!) {
    //   parameter["seller_id"] = widget.id!;
    // } else {
    //   parameter[CATID] = widget.id ?? '';
    // }
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

    // if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

    if (_currentRangeValues != null &&
        _currentRangeValues!.start.round().toString() != "0") {
      parameter[MINPRICE] = _currentRangeValues!.start.round().toString();
    }

    if (_currentRangeValues != null &&
        _currentRangeValues!.end.round().toString() != "0") {
      parameter[MAXPRICE] = _currentRangeValues!.end.round().toString();
    }

    apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        total = int.parse(getdata["total"]);

        if (_isFirstLoad) {
          filterList = getdata["filters"];

          minPrice = getdata[MINPRICE];
          maxPrice = getdata[MAXPRICE];
          _currentRangeValues =
              RangeValues(double.parse(minPrice), double.parse(maxPrice));
          _isFirstLoad = false;
        }

        if ((offset) < total) {
          tempList.clear();

          var data = getdata["data"];

          print("Product List Data ====================> : ${data[0]}");
          tempList =
              (data as List).map((data) => new Product.fromJson(data)).toList();

          if (getdata.containsKey(TAG)) {
            List<String> tempList = List<String>.from(getdata[TAG]);
            if (tempList != null && tempList.length > 0) tagList = tempList;
          }

          getAvailVarient();

          offset = offset + perPage;
        } else {
          if (msg != "Products Not Found !") setSnackbar(msg!, context);
          isLoadingmore = false;
        }
      } else {
        isLoadingmore = false;
        if (msg != "Products Not Found !") setSnackbar(msg!, context);
      }

      setState(() {
        _isLoading = false;
      });
      context.read<HomeProvider>().setProductLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      setState(() {
        _isLoading = false;
      });
      context.read<HomeProvider>().setProductLoading(false);
    });
  }

  void categoryDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                  top: 19.0, bottom: 16.0),
                              child: Text(
                                getTranslated(context, 'CATEGORY')!,
                                style: Theme.of(context).textTheme.headline6,
                              )),
                        ),
                      ),
                      Container(
                        padding:
                        const EdgeInsets.only(left: 10.0, right: 10, top: 20),
                        height: MediaQuery.of(context).size.height * 0.5,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: GridView.count(
                          // itemCount: catList.length < 10 ? catList.length : 10,
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            crossAxisCount: 3,
                            children: List.generate(
                              catList.length,
                                  (index) {
                                return Card(
                                  elevation: 1,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 5),
                                    child: GestureDetector(
                                      onTap: () async {
                                        Navigator.pop(context, 'Category');
                                      },
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          catList[index].image != null
                                              ? Container(
                                            height: 60,
                                            width: 60,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.all(
                                                    Radius.circular(40)),
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                      "${catList[index].image}",
                                                    ))),
                                          )
                                              : Container(
                                              height: 60,
                                              width: 60,
                                              child: Image.asset(
                                                  "assets/images/homelogo.png")),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            child: Text(
                                              catList[index].name!.toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption!
                                                  .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .fontColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.clip,
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                            ),
                                            //width: 70,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )),
                      )
                    ]),
              );
            });
      },
    );
  }

  void sortDialog() {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.white,
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      builder: (builder) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20))),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                  top: 19.0, bottom: 16.0),
                              child: Text(
                                getTranslated(context, 'SORT_BY')!,
                                style: Theme.of(context).textTheme.headline6,
                              )),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          sortBy = '';
                          orderBy = 'DESC';
                          if (mounted)
                            setState(() {
                              _isLoading = true;
                              total = 0;
                              offset = 0;
                              productList.clear();
                            });
                          getProduct("1");
                          Navigator.pop(context, 'option 1');
                        },
                        child: Container(
                          width: deviceWidth,
                          color: sortBy == ''
                              ? colors.primary
                              : Theme.of(context).colorScheme.white,
                          padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          child: Text(getTranslated(context, 'TOP_RATED')!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: sortBy == ''
                                      ? Theme.of(context).colorScheme.white
                                      : Theme.of(context)
                                      .colorScheme
                                      .fontColor)),
                        ),
                      ),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(getTranslated(context, 'F_NEWEST')!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .subtitle1!
                                      .copyWith(
                                      color: sortBy == 'p.date_added' &&
                                          orderBy == 'DESC'
                                          ? Theme.of(context).colorScheme.white
                                          : Theme.of(context)
                                          .colorScheme
                                          .fontColor))),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 1');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'p.date_added' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: Text(
                                getTranslated(context, 'F_OLDEST')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'p.date_added' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'p.date_added';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 2');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'ASC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_LOW')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'ASC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'ASC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 3');
                          }),
                      InkWell(
                          child: Container(
                              width: deviceWidth,
                              color: sortBy == 'pv.price' && orderBy == 'DESC'
                                  ? colors.primary
                                  : Theme.of(context).colorScheme.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              child: new Text(
                                getTranslated(context, 'F_HIGH')!,
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(
                                    color: sortBy == 'pv.price' &&
                                        orderBy == 'DESC'
                                        ? Theme.of(context).colorScheme.white
                                        : Theme.of(context)
                                        .colorScheme
                                        .fontColor),
                              )),
                          onTap: () {
                            sortBy = 'pv.price';
                            orderBy = 'DESC';
                            if (mounted)
                              setState(() {
                                _isLoading = true;
                                total = 0;
                                offset = 0;
                                productList.clear();
                              });
                            getProduct("0");
                            Navigator.pop(context, 'option 4');
                          }),
                    ]),
              );
            });
      },
    );
  }

  void getAvailVarient() {
    for (int j = 0; j < tempList.length; j++) {
      if (tempList[j].stockType == "2") {
        for (int i = 0; i < tempList[j].prVarientList!.length; i++) {
          if (tempList[j].prVarientList![i].availability == "1") {
            tempList[j].selVarient = i;

            break;
          }
        }
      }
    }
    productList.addAll(tempList);
  }

  // Future<List<Product>> getProductByCategory(String top, String catID) async {
  //   //_currentRangeValues.start.round().toString(),
  //   // _currentRangeValues.end.round().toString(),
  //   Map parameter = {
  //     SORT: 'p.id',
  //     ORDER: "DESC",
  //     LIMIT: perPage.toString(),
  //     OFFSET: offset.toString(),
  //     TOP_RETAED: top,
  //   };
  //   parameter[CATID] = catID;
  //   SettingProvider settingsProvider =
  //       Provider.of<SettingProvider>(context, listen: false);

  //   String? curPin = await settingsProvider.getPrefrence("ZIPCODE") ?? "";
  //   //  print(curPin +"ZIPCODEE");
  //   if (curPin != '') parameter[ZIPCODE] = curPin;
  //   // if (widget.tag!) parameter[TAG] = widget.name!;
  //   // if (widget.fromSeller!) {
  //   //   parameter["seller_id"] = widget.id!;
  //   // } else {
  //   //   parameter[CATID] = widget.id ?? '';
  //   // }
  //   if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;

  //   // if (widget.dis != null) parameter[DISCOUNT] = widget.dis.toString();

  //   apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       total = int.parse(getdata["total"]);

  //       // if (_isFirstLoad) {
  //       //   filterList = getdata["filters"];

  //       //   minPrice = getdata[MINPRICE];
  //       //   maxPrice = getdata[MAXPRICE];
  //       //   _currentRangeValues =
  //       //       RangeValues(double.parse(minPrice), double.parse(maxPrice));
  //       //   _isFirstLoad = false;
  //       // }

  //       // if ((offset) < total) {
  //       //   tempList.clear();

  //       var data = getdata["data"];

  //       List<Product> list =
  //           (data as List).map((data) => new Product.fromJson(data)).toList();

  //       //   print("Product List Data ====================> : $data");
  //       //   tempList =
  //       //

  //       //   if (getdata.containsKey(TAG)) {
  //       //     List<String> tempList = List<String>.from(getdata[TAG]);
  //       //     if (tempList != null && tempList.length > 0) tagList = tempList;
  //       //   }

  //       //   getAvailVarient();

  //       //   offset = offset + perPage;
  //       // } else {
  //       //   if (msg != "Products Not Found !") setSnackbar(msg!, context);
  //       //   isLoadingmore = false;
  //       // }

  //       return list;
  //     } else {
  //       isLoadingmore = false;
  //       if (msg != "Products Not Found !") setSnackbar(msg!, context);
  //     }

  //     setState(() {
  //       _isLoading = false;
  //     });
  //     // context.read<ProductListProvider>().setProductLoading(false);
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     //context.read<ProductListProvider>().setProductLoading(false);
  //   });
  // }

  Widget listTileItem(Product product) {
    Product model = product;

    List att = [], val = [];
    if (model.prVarientList![model.selVarient!].attr_name != null) {
      att = model.prVarientList![model.selVarient!].attr_name!.split(',');
      val = model.prVarientList![model.selVarient!].varient_value!.split(',');
    }

    double price =
    double.parse(model.prVarientList![model.selVarient!].disPrice!);
    if (price == 0) {
      price = double.parse(model.prVarientList![model.selVarient!].price!);
    }

    double off = 0;
    if (model.prVarientList![model.selVarient!].disPrice! != "0") {
      off = (double.parse(model.prVarientList![model.selVarient!].price!) -
          double.parse(model.prVarientList![model.selVarient!].disPrice!))
          .toDouble();
      off = off *
          100 /
          double.parse(model.prVarientList![model.selVarient!].price!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              child: Stack(children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Hero(
                        tag: "ProList${model.id}",
                        child: ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10)),
                            child: Stack(
                              children: [
                                FadeInImage(
                                  image: NetworkImage(model.image!),
                                  height: 125.0,
                                  width: 135.0,
                                  fit: BoxFit.cover,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) =>
                                      erroWidget(125),
                                  placeholder: placeHolder(125),
                                ),
                                Positioned.fill(
                                    child: model.availability == "0"
                                        ? Container(
                                      height: 55,
                                      color: Colors.white70,
                                      // width: double.maxFinite,
                                      padding: EdgeInsets.all(2),
                                      child: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'OUT_OF_STOCK_LBL')!,
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption!
                                              .copyWith(
                                            color: Colors.red,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                        : Container()),
                                (off != 0 || off != 0.0 || off != 0.00)
                                    ? Container(
                                  decoration: BoxDecoration(
                                      color: colors.red,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Text(
                                      off.toStringAsFixed(2) + "%",
                                      style: TextStyle(
                                          color: colors.whiteTemp,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(5),
                                )
                                    : Container()
                                // Container(
                                //   decoration: BoxDecoration(
                                //       color: colors.red,
                                //       borderRadius:
                                //           BorderRadius.circular(10)),
                                //   child: Padding(
                                //     padding: const EdgeInsets.all(5.0),
                                //     child: Text(
                                //       off.toStringAsFixed(2) + "%",
                                //       style: TextStyle(
                                //           color: colors.whiteTemp,
                                //           fontWeight: FontWeight.bold,
                                //           fontSize: 9),
                                //     ),
                                //   ),
                                //   margin: EdgeInsets.all(5),
                                // )
                              ],
                            ))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              model.name!,
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .lightBlack),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            model.prVarientList![model.selVarient!].attr_name !=
                                null &&
                                model.prVarientList![model.selVarient!]
                                    .attr_name!.isNotEmpty
                                ? ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: att.length >= 2 ? 2 : att.length,
                                itemBuilder: (context, index) {
                                  return Row(children: [
                                    Flexible(
                                      child: Text(
                                        att[index].trim() + ":",
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          start: 5.0),
                                      child: Text(
                                        val[index],
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack,
                                            fontWeight:
                                            FontWeight.bold),
                                      ),
                                    )
                                  ]);
                                })
                                : Container(),
                            (model.rating! == "0" || model.rating! == "0.0")
                                ? Container()
                                : Row(
                              children: [
                                RatingBarIndicator(
                                  rating: double.parse(model.rating!),
                                  itemBuilder: (context, index) => Icon(
                                    Icons.star_rate_rounded,
                                    color: Colors.amber,
                                    //color: colors.primary,
                                  ),
                                  unratedColor:
                                  Colors.grey.withOpacity(0.5),
                                  itemCount: 5,
                                  itemSize: 18.0,
                                  direction: Axis.horizontal,
                                ),
                                Text(
                                  " (" + model.noOfRating! + ")",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline,
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Text(
                                    CUR_CURRENCY! +
                                        " " +
                                        price.toString() +
                                        " ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                  double.parse(model
                                      .prVarientList![model.selVarient!]
                                      .disPrice!) !=
                                      0
                                      ? CUR_CURRENCY! +
                                      "" +
                                      model
                                          .prVarientList![model.selVarient!]
                                          .price!
                                      : "",
                                  style: Theme.of(context)
                                      .textTheme
                                      .overline!
                                      .copyWith(
                                      decoration:
                                      TextDecoration.lineThrough,
                                      letterSpacing: 0,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                // model.availability == "0"
                //     ? Text(getTranslated(context, 'OUT_OF_STOCK_LBL')!,
                //         style: Theme.of(context)
                //             .textTheme
                //             .subtitle2!
                //             .copyWith(
                //                 color: Colors.red,
                //                 fontWeight: FontWeight.bold))
                //     : Container(),
              ]),
              onTap: () {
                Product model = product;
                Navigator.push(
                  context,
                  PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ProductDetail(
                        model: model,
                        index: 0,
                        secPos: 0,
                        list: true,
                      )),
                );
              },
            ),
          ),
          Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 5,
              end: 0,
              child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: model.isFavLoading!
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 0.7,
                        )),
                  )
                      : Selector<FavoriteProvider, List<String?>>(
                    builder: (context, data, child) {
                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            !data.contains(model.id)
                                ? Icons.favorite_border
                                : Icons.favorite,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          if (CUR_USERID != null) {
                            !data.contains(model.id)
                                ? _setFav(-1, 0)
                                : _removeFav(-1, 0);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Login()),
                            );
                          }
                        },
                      );
                    },
                    selector: (_, provider) => provider.favIdList,
                  )))
        ],
      ),
    );
  }

  // API CALL Related to Brands and their PRODUCT

  // void getBrand() {
  //   Map parameter = {MASTER_TAB: isSelectedTab.toString()};
  //   apiBaseHelper.postAPICall(getBrandApi, parameter).then((getdata) async {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];

  //       brandList =
  //           (data as List).map((data) => BrandModel.fromJson(data)).toList();

  //       for (var i = 0; i < brandList.length; i++) {
  //         List<Product>? listProduct =
  //             await getProductAsPerBrand(brandName: brandList[i].name ?? '');
  //         brandList[i].productList!.addAll(listProduct ?? []);
  //       }
  //     } else {
  //       setSnackbar(msg!, context);
  //     }

  //     context.read<HomeProvider>().setBrandLoading(false);
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     context.read<HomeProvider>().setBrandLoading(false);
  //   });
  // }

  // Future<List<Product>>? getProductAsPerBrand({required String brandName}) {
  //   Map parameter = {
  //     'brand': brandName,
  //   };

  //   apiBaseHelper.postAPICall(getProductApi, parameter).then((getdata) {
  //     bool error = getdata["error"];
  //     String? msg = getdata["message"];
  //     if (!error) {
  //       var data = getdata["data"];
  //       List<Product> productListBrand =
  //           (data as List).map((data) => new Product.fromJson(data)).toList();
  //       return productListBrand;
  //     } else {
  //       setSnackbar(msg.toString(), context);
  //       return [];
  //     }
  //   }, onError: (error) {
  //     setSnackbar(error.toString(), context);
  //     return [];
  //   });
  // }

  void getBrand() {
    Map<String, String> parameter = {MASTER_TAB: isSelectedTab.toString()};
    apiBaseHelper.postAPICall(getBrandApi, parameter).then((getdata) async {
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];

        brandList =
            (data as List).map((data) => BrandModel.fromJson(data)).toList();

        for (var i = 0; i < brandList.length; i++) {
          List<Product>? listProduct =
          await getProductAsPerBrand(brandName: brandList[i].name ?? '');
          if (listProduct != null) {
            brandList[i].productList!.addAll(listProduct);
          }
        }
      } else {
        setSnackbar(msg!, context);
      }

      context.read<HomeProvider>().setBrandLoading(false);
    }, onError: (error) {
      setSnackbar(error.toString(), context);
      context.read<HomeProvider>().setBrandLoading(false);
    });
  }

  Future<List<Product>?> getProductAsPerBrand(
      {required String brandName}) async {
    Map<String, String> parameter = {
      'brand': brandName,
    };

    try {
      var getdata = await apiBaseHelper.postAPICall(getProductApi, parameter);
      bool error = getdata["error"];
      String? msg = getdata["message"];
      if (!error) {
        var data = getdata["data"];
        List<Product> productListBrand =
        (data as List).map((data) => Product.fromJson(data)).toList();
        return productListBrand;
      } else {
        //setSnackbar(msg.toString(), context);
        return [];
      }
    } catch (error) {
      setSnackbar(error.toString(), context);
      return [];
    }
  }
}
