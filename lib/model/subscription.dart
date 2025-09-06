class SubscriptionPackage {

  final int plainid;
  final String plan_name;
  final String plan_details;
  final int validity;
  final double price;
  final int status; 

  SubscriptionPackage({
    required this.plainid,
    required this.plan_name,
    required this.plan_details,
    required this.validity,
    required this.price,
    required this.status,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      plainid: json['plainid'] as int,
      plan_name: json['plan_name'] as String,
      plan_details: json['plan_details'] as String,
      validity: json['validity'] as int,
      price: json['price'] as double,
      status: json['status'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'plainid': plainid,
    'plan_name': plan_name,
    'plan_details': plan_details,
    'validity': validity,
    'price': price,
    'status': status,
  };
}
