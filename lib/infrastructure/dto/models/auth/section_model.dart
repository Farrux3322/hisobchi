
import 'package:equatable/equatable.dart';
class SectionModel  extends Equatable{
  int? id;
  String? name;
  int? status;
  bool? isSelected;

  SectionModel({this.id, this.name, this.status, this.isSelected});

  SectionModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    status = json['status'];
    isSelected = json['is_selected'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['status'] = status;
    data['is_selected'] = isSelected;
    return data;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [id,name,status,isSelected];
}


extension SectionModelCopy on SectionModel {
  SectionModel copyWith({
    int? id,
    String? name,
    int? status,
    bool? isSelected,
  }) {
    return SectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
