import 'package:flutter/material.dart';
import 'package:kiddo_tracker/model/subscription.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  List<SubscriptionPackage> _packages = [];
  bool _loading = true;
  String? _selectedPackageId;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _fetchPackages();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _fetchPackages() async {
    // Simulate network fetch with delay
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _packages = [
        SubscriptionPackage(
          plainid: 1,
          plan_name: 'Basic Plan',
          plan_details: 'Access to basic features',
          validity: 22,
          price: 9.99,
          status: 1,
        ),
        SubscriptionPackage(
          plainid: 2,
          plan_name: 'Premium Plan',
          plan_details: 'Access to premium features',
          validity: 30,
          price: 19.99,
          status: 1,
        ),
        SubscriptionPackage(
          plainid: 3,
          plan_name: 'Pro Plan',
          plan_details: 'Access to pro features',
          validity: 45,
          price: 29.99,
          status: 1,
        ),
      ];
      _loading = false;
    });
  }

  void _selectPackage(String id) {
    setState(() {
      _selectedPackageId = id;
    });
    // Open Razorpay payment
    _openRazorpayPayment(id);
  }

  void _openRazorpayPayment(String packageId) {
    final pkg = _packages.firstWhere((p) => p.plainid.toString() == packageId);
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Replace with your Razorpay key
      'amount': (pkg.price * 100).toInt(), // Amount in paise
      'name': 'Kiddo Tracker',
      'description': pkg.plan_name,
      'prefill': {
        'contact': '8888888888',
        'email': 'test@razorpay.com'
      }
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful: ${response.paymentId}')),
    );
    // Handle success, e.g., update subscription status
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscription Packages')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _packages.length,
              itemBuilder: (context, index) {
                final pkg = _packages[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pkg.plan_name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(pkg.plan_details),
                        SizedBox(height: 8),
                        Text('Price: \$${pkg.price.toStringAsFixed(2)}'),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () =>
                              _selectPackage(pkg.plainid.toString()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedPackageId == pkg.plainid
                                ? Colors.green
                                : null,
                          ),
                          child: Text(
                            _selectedPackageId == pkg.plainid
                                ? 'Selected'
                                : 'Select & Pay',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
