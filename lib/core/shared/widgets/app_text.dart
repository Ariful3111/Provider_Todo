// lib/core/shared/widgets/app_text.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider_todo/core/constant/app_colors.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  });

  // Named constructors for common styles
  const AppText.heading(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  }) : fontSize = 24,
       color = AppColors.primaryColor,
       fontWeight = FontWeight.bold;

  const AppText.completeText(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : fontSize = 14,
       color = AppColors.textPrimary,
       decoration = TextDecoration.underline,
       fontWeight = FontWeight.normal;

  const AppText.label(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  }) : fontSize = 12,
       color = AppColors.textSecondary,
       fontWeight = FontWeight.w500;
  const AppText.whiteText(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
  }) : fontSize = 16,
       color = AppColors.whiteColor,
       fontWeight = FontWeight.w500;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: GoogleFonts.rubik(
        fontSize: fontSize ?? 14,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: color ?? AppColors.black,
        decoration: decoration,
      ),
    );
  }
}
