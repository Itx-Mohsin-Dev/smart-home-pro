import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home_pro/core/constants/colors.dart';
import 'package:smart_home_pro/core/constants/text_styles.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
                    'Welcome Back',
                    style: AppTextStyles.h2(context).copyWith(
                      fontSize: 26, // Reduced from default
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Center(
                  child: Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: AppColors.mediumGray,
                      fontSize: 14, // Reduced
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      icon: const Icon(Icons.visibility_outlined, size: 20),
                      onPressed: () {},
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Remember Me & Forgot Password - Fixed overflow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Transform.scale(
                              scale: 0.85,
                              child: Checkbox(
                                value: false,
                                onChanged: (value) {},
                                fillColor: MaterialStateProperty.all(AppColors.primaryBlue),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                'Remember me',
                                style: AppTextStyles.bodySmall(context).copyWith(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            'Forgot Password?',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16), // Reduced
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppColors.borderGray),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced
                        child: Text(
                          'Or continue with',
                          style: AppTextStyles.caption(context).copyWith(fontSize: 12),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: AppColors.borderGray),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Social Login Buttons - Fixed overflow
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(Icons.g_mobiledata, 'Google'),
                      const SizedBox(width: 12), // Reduced
                      _buildSocialButton(Icons.apple, 'Apple'),
                      const SizedBox(width: 12), // Reduced
                      _buildSocialButton(Icons.facebook, 'FB'), // Shortened
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Sign Up Link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go('/register');
                    },
                    child: RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: AppTextStyles.bodySmall(context).copyWith(fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: AppTextStyles.bodySmall(context).copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
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

  Widget _buildSocialButton(IconData icon, String label) {
    return SizedBox(
      width: 90, // Reduced from 100
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10), // Reduced
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10), // Reduced
          border: Border.all(color: AppColors.borderGray),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.darkGray, size: 20), // Smaller
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11, // Reduced from 12
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}