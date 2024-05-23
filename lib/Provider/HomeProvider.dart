import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _curSlider = 0;
  int _masterCategory = 1;
  bool _catLoading = true;
  bool _secLoading = true;
  bool _sliderLoading = true;
  bool _offerLoading = true;
  bool _sellerLoading = true;
  bool _masterTabLoading = true;
  bool _productLoading = true;
  bool _brandLoading = true;

  get sellerLoading => _sellerLoading;

  get catLoading => _catLoading;

  get curSlider => _curSlider;

  get secLoading => _secLoading;

  get sliderLoading => _sliderLoading;

  get offerLoading => _offerLoading;

  get masterTabLoading => _masterTabLoading;
  get productLoading => _productLoading;

  get brandLoading => _brandLoading;

  get masterCategory => _masterCategory;

  setCurSlider(int pos) {
    _curSlider = pos;
    notifyListeners();
  }

  setOfferLoading(bool loading) {
    _offerLoading = loading;
    notifyListeners();
  }

  setSliderLoading(bool loading) {
    _sliderLoading = loading;
    notifyListeners();
  }

  setSecLoading(bool loaidng) {
    _secLoading = loaidng;
    notifyListeners();
  }

  setSellerLoading(bool laoding) {
    _sellerLoading = laoding;
    notifyListeners();
  }

  setCatLoading(bool loading) {
    _catLoading = loading;
    notifyListeners();
  }

  setMasterTabLoading(bool loading) {
    _masterTabLoading = loading;
    notifyListeners();
  }

  setProductLoading(bool loading) {
    _productLoading = loading;
    notifyListeners();
  }

  setBrandLoading(bool loading) {
    _brandLoading = loading;
    notifyListeners();
  }

  setMasterCategory(int index) {
    _masterCategory = index;
  }
}
