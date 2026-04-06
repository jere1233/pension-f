// lib/features/calculator/presentation/screens/calculator_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // ── Inputs ──
  double currentAge = 30;
  double retirementAge = 60;
  double currentSavings = 100000;
  double monthlyContribution = 5000;
  double annualReturn = 8;
  double inflationRate = 5;
  double monthlyExpenses = 30000;

  // ── Computed ──
  double projectedSavings = 0;
  double realValue = 0;
  double monthlyIncome = 0;
  double replacementRatio = 0;
  double shortfall = 0;
  int yearsToRetirement = 0;

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  void _calculate() {
    final years = (retirementAge - currentAge).clamp(0, 100).toInt();
    final months = years * 12;
    final monthlyRate = annualReturn / 100 / 12;

    final fvCurrentSavings = currentSavings * pow(1 + annualReturn / 100, years);

    final fvContributions = monthlyRate > 0
        ? monthlyContribution *
            ((pow(1 + monthlyRate, months) - 1) / monthlyRate)
        : monthlyContribution * months;

    final projected = fvCurrentSavings + fvContributions;
    final real = projected / pow(1 + inflationRate / 100, years);
    final income = (projected * 0.04) / 12;
    final ratio = monthlyExpenses > 0 ? (income / monthlyExpenses) * 100 : 0;
    final requiredNest = monthlyExpenses * 12 * 25;
    final gap = (requiredNest - projected).clamp(0.0, double.infinity) as double;

    setState(() {
      projectedSavings = projected;
      realValue = real;
      monthlyIncome = income;
      replacementRatio = ratio.toDouble();
      shortfall = gap;
      yearsToRetirement = years;
    });
  }

  String _formatCurrency(double amount) {
    return 'KES ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            expandedHeight: 110.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20.w, bottom: 14.h),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6.r),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Icons.calculate_rounded,
                        color: Colors.white, size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Retirement Calculator',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800)),
                      Text('Project your savings & plan your future',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 9.sp)),
                    ],
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.75),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Inputs Card ──
                  _SectionCard(
                    title: 'Your Details',
                    child: Column(
                      children: [
                        _InputField(
                          label: 'Current Age',
                          value: currentAge,
                          min: 18,
                          max: 70,
                          step: 1,
                          suffix: 'yrs',
                          onChanged: (v) {
                            currentAge = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Retirement Age',
                          value: retirementAge,
                          min: 50,
                          max: 80,
                          step: 1,
                          suffix: 'yrs',
                          onChanged: (v) {
                            retirementAge = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Current Savings',
                          value: currentSavings,
                          min: 0,
                          max: 10000000,
                          step: 1000,
                          prefix: 'KES',
                          onChanged: (v) {
                            currentSavings = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Monthly Contribution',
                          value: monthlyContribution,
                          min: 0,
                          max: 500000,
                          step: 500,
                          prefix: 'KES',
                          onChanged: (v) {
                            monthlyContribution = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Expected Annual Return',
                          value: annualReturn,
                          min: 1,
                          max: 20,
                          step: 0.5,
                          suffix: '%',
                          onChanged: (v) {
                            annualReturn = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Expected Inflation Rate',
                          value: inflationRate,
                          min: 1,
                          max: 15,
                          step: 0.5,
                          suffix: '%',
                          onChanged: (v) {
                            inflationRate = v;
                            _calculate();
                          },
                        ),
                        SizedBox(height: 14.h),
                        _InputField(
                          label: 'Monthly Expenses (Today)',
                          value: monthlyExpenses,
                          min: 0,
                          max: 500000,
                          step: 1000,
                          prefix: 'KES',
                          onChanged: (v) {
                            monthlyExpenses = v;
                            _calculate();
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── 4 Stat Cards ──
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Projected Savings',
                            value: _formatCurrency(projectedSavings),
                            subtitle: 'At age ${retirementAge.toInt()}',
                            icon: Icons.trending_up_rounded,
                            gradientColors: const [
                              Color(0xFFF97316),
                              Color(0xFF9333EA),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            title: 'Real Value',
                            value: _formatCurrency(realValue),
                            subtitle: "Today's purchasing power",
                            icon: Icons.attach_money_rounded,
                            gradientColors: const [
                              Color(0xFFF97316),
                              Color(0xFF6366F1),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: 'Monthly Income',
                            value: _formatCurrency(monthlyIncome),
                            subtitle: '4% withdrawal rule',
                            icon: Icons.savings_rounded,
                            gradientColors: const [
                              Color(0xFFF97316),
                              Color(0xFFEC4899),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _StatCard(
                            title: 'Years to Retire',
                            value: '$yearsToRetirement yrs',
                            subtitle: 'Retiring at age ${retirementAge.toInt()}',
                            icon: Icons.schedule_rounded,
                            gradientColors: const [
                              Color(0xFFF97316),
                              Color(0xFFF43F5E),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Retirement Outlook ──
                  _SectionCard(
                    title: 'Retirement Outlook',
                    child: Column(
                      children: [
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _OutlookTile(
                                  label: 'Income Replacement Ratio',
                                  value:
                                      '${replacementRatio.toStringAsFixed(1)}%',
                                  subtitle: 'Target: ≥80%',
                                  valueColor: replacementRatio >= 80
                                      ? const Color(0xFF16A34A)
                                      : replacementRatio >= 50
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFDC2626),
                                  progressValue: replacementRatio.clamp(0, 100),
                                  progressColor: replacementRatio >= 80
                                      ? const Color(0xFF16A34A)
                                      : replacementRatio >= 50
                                          ? const Color(0xFFF97316)
                                          : const Color(0xFFDC2626),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _OutlookTile(
                                  label: 'Savings Shortfall',
                                  value: shortfall == 0
                                      ? 'On Track! ✓'
                                      : _formatCurrency(shortfall),
                                  subtitle: shortfall == 0
                                      ? 'Exceeds target nest egg'
                                      : 'Need 25× annual expenses',
                                  valueColor: shortfall == 0
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: _OutlookTile(
                                  label: 'Monthly Income at Retirement',
                                  value: _formatCurrency(monthlyIncome),
                                  subtitle:
                                      'vs KES ${monthlyExpenses.toStringAsFixed(0)} current',
                                  valueColor: const Color(0xFF2563EB),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _OutlookTile(
                                  label: 'Inflation-Adjusted Nest Egg',
                                  value: _formatCurrency(realValue),
                                  subtitle:
                                      'At ${inflationRate.toStringAsFixed(1)}% over $yearsToRetirement yrs',
                                  valueColor: const Color(0xFF7C3AED),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // ── Insights ──
                  _SectionCard(
                    title: '💡 Insights',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (replacementRatio >= 80 && shortfall == 0)
                          _InsightRow(
                            color: const Color(0xFF16A34A),
                            text:
                                'Great work! You\'re on track for a comfortable retirement with an income replacement ratio of ${replacementRatio.toStringAsFixed(1)}%.',
                          )
                        else ...[
                          if (replacementRatio < 80)
                            _InsightRow(
                              color: const Color(0xFFF97316),
                              text:
                                  'Your income replacement ratio is ${replacementRatio.toStringAsFixed(1)}%, below the recommended 80%. Consider increasing your monthly contribution or adjusting your retirement age.',
                            ),
                          if (shortfall > 0) ...[
                            SizedBox(height: 10.h),
                            _InsightRow(
                              color: const Color(0xFFDC2626),
                              text:
                                  'You have a projected shortfall of ${_formatCurrency(shortfall)}. Saving more each month or starting earlier can close this gap.',
                            ),
                          ],
                        ],
                        SizedBox(height: 10.h),
                        _InsightRow(
                          color: const Color(0xFF2563EB),
                          text:
                              'At ${annualReturn.toStringAsFixed(1)}% annual return, your money doubles approximately every ${(72 / annualReturn).toStringAsFixed(1)} years (Rule of 72).',
                        ),
                        SizedBox(height: 10.h),
                        _InsightRow(
                          color: const Color(0xFF7C3AED),
                          text:
                              'Delaying retirement by just 2 years to age ${(retirementAge + 2).toInt()} could significantly boost your nest egg through compound growth.',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────── Sub-Widgets ───────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827))),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String? prefix;
  final String? suffix;
  final ValueChanged<double> onChanged;

  const _InputField({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.prefix,
    this.suffix,
  });

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  late TextEditingController _controller;
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.value;
    _controller = TextEditingController(text: widget.value.toStringAsFixed(
      widget.step < 1 ? 1 : 0,
    ));
  }

  @override
  void didUpdateWidget(_InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _sliderValue = widget.value;
      _controller.text = widget.value.toStringAsFixed(widget.step < 1 ? 1 : 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final v = double.tryParse(text);
    if (v != null) {
      final clamped = v.clamp(widget.min, widget.max);
      setState(() => _sliderValue = clamped);
      widget.onChanged(clamped);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6B7280))),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                Text(widget.prefix!,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600)),
                SizedBox(width: 6.w),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onTextChanged,
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827)),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (widget.suffix != null)
                Text(widget.suffix!,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withOpacity(0.15),
          ),
          child: Slider(
            value: _sliderValue.clamp(widget.min, widget.max),
            min: widget.min,
            max: widget.max,
            divisions: ((widget.max - widget.min) / widget.step).round(),
            onChanged: (v) {
              final rounded = (v / widget.step).round() * widget.step;
              setState(() {
                _sliderValue = rounded;
                _controller.text = rounded.toStringAsFixed(widget.step < 1 ? 1 : 0);
              });
              widget.onChanged(rounded);
            },
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.9)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 14.sp, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(value,
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white)),
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.white.withOpacity(0.75)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _OutlookTile extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final Color valueColor;
  final double? progressValue;
  final Color? progressColor;

  const _OutlookTile({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.valueColor,
    this.progressValue,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
          SizedBox(height: 6.h),
          Text(value,
              style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: valueColor)),
          SizedBox(height: 4.h),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 9.sp, color: const Color(0xFF9CA3AF))),
          if (progressValue != null) ...[
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progressValue! / 100,
                minHeight: 5,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor:
                    AlwaysStoppedAnimation<Color>(progressColor!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final Color color;
  final String text;
  const _InsightRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          margin: EdgeInsets.only(top: 4.h, right: 8.w),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF4B5563),
                  height: 1.5)),
        ),
      ],
    );
  }
}