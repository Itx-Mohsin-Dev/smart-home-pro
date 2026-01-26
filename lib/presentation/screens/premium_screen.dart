import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';
import 'package:smart_home_pro/presentation/screens/statistics_screen.dart';

class PremiumScreen extends StatefulWidget {
  final bool fromStatsPage;

  const PremiumScreen({super.key, this.fromStatsPage = false});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  String _selectedPlan = 'yearly';
  bool _isLoading = false;

  final List<PlanFeature> _features = [
    PlanFeature('Advanced Analytics', 'Charts, trends, predictions'),
    PlanFeature('Unlimited Device History', 'Store unlimited usage data'),
    PlanFeature('Energy Comparison', 'Compare with similar homes'),
    PlanFeature('PDF Reports', 'Export detailed reports'),
    PlanFeature('Priority Support', '24/7 premium support'),
    PlanFeature('No Ads', 'Ad-free experience'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hero Section
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'SmartHome Pro Premium',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Unlock advanced analytics and save more on energy',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'SAVE UP TO 40%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Plan Toggle
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlan = 'monthly';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _selectedPlan == 'monthly'
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Monthly',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedPlan == 'monthly'
                                    ? Colors.white
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPlan = 'yearly';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: _selectedPlan == 'yearly'
                                ? AppColors.primaryBlue
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Text(
                              'Yearly (Save 40%)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedPlan == 'yearly'
                                    ? Colors.white
                                    : AppColors.mediumGray,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Pricing Cards
              Row(
                children: [
                  Expanded(
                    child: _buildPlanCard(
                      title: 'Basic',
                      price: 'Free',
                      period: 'Forever',
                      isSelected: false,
                      isPremium: false,
                      features: const ['Basic Analytics', '3 Devices', '7-day History'],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPlanCard(
                      title: 'Premium',
                      price: _selectedPlan == 'monthly' ? '₹299' : '₹2,999',
                      period: _selectedPlan == 'monthly' ? '/month' : '/year',
                      isSelected: true,
                      isPremium: true,
                      features: const ['Advanced Analytics', 'Unlimited Devices', 'Unlimited History'],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Features List
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Premium Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._features.map((feature) => _buildFeatureItem(feature)).toList(),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Payment Methods
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildPaymentMethod('assets/razorpay.png', 'Razorpay'),
                        _buildPaymentMethod('assets/stripe.png', 'Stripe'),
                        _buildPaymentMethod('assets/paypal.png', 'PayPal'),
                        _buildPaymentMethod('assets/google_pay.png', 'Google Pay'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Subscribe Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _subscribeToPremium,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Subscribe Now',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Terms
              const Text(
                'Cancel anytime. 7-day money-back guarantee.\nBy subscribing, you agree to our Terms of Service.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required String period,
    required bool isSelected,
    required bool isPremium,
    required List<String> features,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.borderGray,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: isPremium
                  ? AppColors.primaryBlue.withOpacity(0.1)
                  : AppColors.borderGray,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isPremium ? AppColors.primaryBlue : AppColors.mediumGray,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            price,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          Text(
            period,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features.map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: isPremium ? AppColors.primaryGreen : AppColors.mediumGray,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.darkGray,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (isPremium && isSelected)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                'RECOMMENDED',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(PlanFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                Text(
                  feature.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String image, String name) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderGray),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.split(' ')[0],
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          name,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  void _subscribeToPremium() {
    setState(() {
      _isLoading = true;
    });

    // Simulate payment process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });

      // Show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Subscription Successful!'),
          content: const Text(
            'You now have access to Premium features including Advanced Analytics.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (widget.fromStatsPage) {
                  // Go back to stats page
                  Navigator.pop(context);
                  // Navigate to stats page (will now show content)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                } else {
                  Navigator.pop(context); // Go back
                }
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    });
  }
}

class PlanFeature {
  final String title;
  final String description;

  PlanFeature(this.title, this.description);
}