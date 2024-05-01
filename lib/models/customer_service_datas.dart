class CustomerServiceDatas {
  final int idDatas;
  final String nim;
  final String title;
  final String description;
  final int? rating;
  final String? imageUrl;
  final String? divisionDepartment;
  final String? priority;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CustomerServiceDatas({
    required this.idDatas,
    required this.nim,
    required this.title,
    required this.description,
    this.rating,
    this.imageUrl,
    this.divisionDepartment,
    this.priority,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CustomerServiceDatas.fromJson(Map<String, dynamic> json) {
    return CustomerServiceDatas(
      idDatas: json['id_customer_service'] as int,
      nim: json['nim'] as String,
      title: json['title_issues'] as String,
      description: json['description_issues'] as String,
      rating: json['rating'] as int,
      imageUrl: json['image_url'] as String?,
      divisionDepartment: json['division_department_name'] as String?,
      priority: json['priority_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] == null
         ? null
          : DateTime.parse(json['deleted_at'] as String),
    );
  }
}