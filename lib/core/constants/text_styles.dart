import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AppTextStyles {
  // Heading Styles
  static TextStyle h1(BuildContext context) => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.darkGray,
      );

  static TextStyle h2(BuildContext context) => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.darkGray,
      );

  static TextStyle h3(BuildContext context) => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGray,
      );

  // Body Styles
  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGray,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGray,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.mediumGray,
      );

  // Button Styles
  static TextStyle buttonLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle buttonMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );

  // Caption Styles
  static TextStyle caption(BuildContext context) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.mediumGray,
      );

  static TextStyle overline(BuildContext context) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w300,
        color: AppColors.mediumGray,
        letterSpacing: 1.5,
      );
}