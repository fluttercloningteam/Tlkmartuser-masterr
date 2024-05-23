import 'dart:convert';

class MasterTabClassModel {
    bool? error;
    String? message;
    List<MasterModel>? date;

    MasterTabClassModel({
        this.error,
        this.message,
        this.date,
    });

    factory MasterTabClassModel.fromRawJson(String str) => MasterTabClassModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MasterTabClassModel.fromJson(Map<String, dynamic> json) => MasterTabClassModel(
        error: json["error"],
        message: json["message"],
        date: json["date"] == null ? [] : List<MasterModel>.from(json["date"]!.map((x) => MasterModel.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "error": error,
        "message": message,
        "date": date == null ? [] : List<dynamic>.from(date!.map((x) => x.toJson())),
    };
}

class MasterModel {
    String? id;
    String? name;
    String? image;

    MasterModel({
        this.id,
        this.name,
        this.image,
    });

    factory MasterModel.fromRawJson(String str) => MasterModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory MasterModel.fromJson(Map<String, dynamic> json) => MasterModel(
        id: json["id"],
        name: json["name"],
        image: json["image"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
    };
}
