class SubscriptionPackage {

  final int planid;
  final String plan_name;
  final String plan_details;
  final int validity;
  final int price;
  final int status;

  SubscriptionPackage({
    required this.planid,
    required this.plan_name,
    required this.plan_details,
    required this.validity,
    required this.price,
    required this.status,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      planid: json['planid'] as int,
      plan_name: json['plan_name'] as String,
      plan_details: json['plan_details'] as String,
      validity: json['validity'] as int,
      price: json['price'] as int,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'planid': planid,
    'plan_name': plan_name,
    'plan_details': plan_details,
    'validity': validity,
    'price': price,
    'status': status,
  };
}
