import 'package:flutter/material.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'Week';
  List<String> periods = ['Day', 'Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLightBlue,
      body: Column(
        children: [
          // App Bar
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Statistics',
                          style: AppTextStyles.h2(context).copyWith(
                            fontSize: 22,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_outlined, size: 22),
                          onPressed: () {},
                          color: AppColors.darkGray,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppColors.primaryBlue,
                      unselectedLabelColor: AppColors.mediumGray,
                      indicatorColor: AppColors.primaryBlue,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      unselectedLabelStyle: const TextStyle(fontSize: 13),
                      tabs: const [
                        Tab(text: 'Energy'),
                        Tab(text: 'Cost'),
                        Tab(text: 'Devices'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                child: Column(
                  children: [
                    // Period Selector
                    _buildPeriodSelector(),
                    
                    const SizedBox(height: 14),
                    
                    // Summary Cards
                    _buildSummaryCards(),
                    
                    const SizedBox(height: 14),
                    
                    // Charts Area (Based on Tab)
                    SizedBox(
                      height: 360,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildEnergyChart(),
                          _buildCostChart(),
                          _buildDevicesChart(),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 14),
                    
                    // Savings Tips
                    _buildSavingsTips(),
                    
                    const SizedBox(height: 14),
                    
                    // Device Comparison
                    _buildDeviceComparison(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: periods.map((period) {
            bool isSelected = _selectedPeriod == period;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.mediumGray,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Usage',
            value: '124.5 kWh',
            change: '+12%',
            isPositive: false,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Cost',
            value: '₹1,845',
            change: '-8%',
            isPositive: true,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Savings',
            value: '₹2,450',
            change: '+20%',
            isPositive: true,
            color: AppColors.accentPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: color,
                  size: 16,
                ),
              ),
              Text(
                change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.primaryGreen : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.mediumGray,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Energy Consumption',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock Chart
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderGray),
                left: BorderSide(color: AppColors.borderGray),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildChartBar('Mon', 80, AppColors.primaryBlue),
                _buildChartBar('Tue', 65, AppColors.primaryBlue),
                _buildChartBar('Wed', 90, AppColors.primaryBlue),
                _buildChartBar('Thu', 45, AppColors.primaryBlue),
                _buildChartBar('Fri', 75, AppColors.primaryBlue),
                _buildChartBar('Sat', 95, AppColors.primaryBlue),
                _buildChartBar('Sun', 60, AppColors.primaryBlue),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Peak Hours - Fixed overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Peak Hours (6 PM - 10 PM)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '42% of total',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Cost Analysis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Pie Chart Mock
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.borderGray, width: 8),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '₹1,845',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    Text(
                      'Total Cost',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cost Breakdown - Fixed overflow
          Column(
            children: [
              _buildCostItem('Air Conditioner', '₹620', 33, AppColors.primaryBlue),
              const SizedBox(height: 8),
              _buildCostItem('Lighting', '₹380', 21, AppColors.accentAmber),
              const SizedBox(height: 8),
              _buildCostItem('Water Motor', '₹450', 24, AppColors.primaryGreen),
              const SizedBox(height: 8),
              _buildCostItem('Others', '₹395', 22, AppColors.accentPurple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Device-wise Consumption',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          // Device Bars
          Column(
            children: [
              _buildDeviceBar('Air Conditioner', 35, AppColors.primaryBlue, Icons.ac_unit),
              const SizedBox(height: 12),
              _buildDeviceBar('Living Room Lights', 21, AppColors.accentAmber, Icons.lightbulb),
              const SizedBox(height: 12),
              _buildDeviceBar('Water Motor', 24, AppColors.primaryGreen, Icons.water_damage),
              const SizedBox(height: 12),
              _buildDeviceBar('Curtains', 8, AppColors.accentPurple, Icons.curtains),
              const SizedBox(height: 12),
              _buildDeviceBar('Others', 12, AppColors.mediumGray, Icons.devices),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingsTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings Tips',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '₹450/month',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Column(
            children: [
              _buildTipItem(
                'Reduce AC usage during peak hours (6-10 PM)',
                Icons.ac_unit,
                AppColors.primaryBlue,
              ),
              const SizedBox(height: 10),
              _buildTipItem(
                'Use LED bulbs in living room',
                Icons.lightbulb,
                AppColors.accentAmber,
              ),
              const SizedBox(height: 10),
              _buildTipItem(
                'Schedule water motor to avoid peak hours',
                Icons.water_damage,
                AppColors.primaryGreen,
              ),
              const SizedBox(height: 10),
              _buildTipItem(
                'Enable auto-curtains to reduce AC load',
                Icons.curtains,
                AppColors.accentPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceComparison() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Comparison with Similar Homes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'You',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.primaryGreen],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '124.5\nkWh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Average',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mediumGray,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '156.8\nkWh',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'You save 21% more than average!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widgets
  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildCostItem(String item, String cost, int percent, Color color) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            item,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          cost,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceBar(String device, int percent, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                device,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkGray,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderGray,
                  borderRadius: BorderRadius.circular(2.5),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            tip,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkGray,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}