import 'dart:convert';

import 'package:tlkmartuser/Model/Section_Model.dart';

class BrandModel {
  String? id;
  String? name;
  String? image;
  String? slug;
  String? status;
  String? masterCategory;
  List<Product>? productList;

  BrandModel({
    this.id,
    this.name,
    this.image,
    this.slug,
    this.status,
    this.masterCategory,
    this.productList,
  });

  factory BrandModel.fromRawJson(String str) =>
      BrandModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BrandModel.fromJson(Map<String, dynamic> json) => BrandModel(
      id: json["id"],
      name: json["name"],
      image: json["image"],
      slug: json["slug"],
      status: json["status"],
      masterCategory: json["master_category"],
      productList: []);

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "slug": slug,
        "status": status,
        "master_category": masterCategory,
      };
}
