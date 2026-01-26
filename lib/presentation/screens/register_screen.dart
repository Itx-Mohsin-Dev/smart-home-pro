import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                IconButton(
                  onPressed: () => context.go('/onboarding'),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.darkGray,
                ),
                
                const SizedBox(height: 20),
                
                // Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Center(
                  child: Text(
                    'Create Account',
                    style: AppTextStyles.h2(context),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Center(
                  child: Text(
                    'Join SmartHome Pro today',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.mediumGray,
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Full Name Field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Email Field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.visibility_outlined),
                      onPressed: () {},
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                // Password Strength Indicator
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    'Password must be at least 8 characters',
                    style: AppTextStyles.caption(context),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password Field
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Terms & Conditions
                Row(
                  children: [
                    Checkbox(
                      value: false,
                      onChanged: (value) {},
                      fillColor: MaterialStateProperty.all(AppColors.primaryBlue),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          text: 'I agree to the ',
                          style: AppTextStyles.bodySmall(context),
                          children: [
                            TextSpan(
                              text: 'Terms of Service',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: AppTextStyles.bodySmall(context).copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create Account',
                      style: AppTextStyles.buttonLarge(context),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign In Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/login');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTextStyles.bodySmall(context),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}