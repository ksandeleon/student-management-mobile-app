class DepartmentModel {
  String? deptId;
  final String deptName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DepartmentModel({
    this.deptId,
    required this.deptName,
    this.createdAt,
    this.updatedAt,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      deptId: json['']
    )
  }
}
