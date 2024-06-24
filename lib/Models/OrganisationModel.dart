class OrganisationModel {
  List<Organizations>? organizations;

  OrganisationModel({this.organizations});

  OrganisationModel.fromJson(Map<String, dynamic> json) {
    if (json['organizations'] != null) {
      organizations = <Organizations>[];
      json['organizations'].forEach((v) {
        organizations!.add(new Organizations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.organizations != null) {
      data['organizations'] =
          this.organizations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Organizations {
  String? id;
  String? name;
  String? abbreviatedName;
  String? symbolUrl;

  Organizations({this.id, this.name, this.abbreviatedName, this.symbolUrl});

  Organizations.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    abbreviatedName = json['abbreviated_name'];
    symbolUrl = json['symbol_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['abbreviated_name'] = this.abbreviatedName;
    data['symbol_url'] = this.symbolUrl;
    return data;
  }
}