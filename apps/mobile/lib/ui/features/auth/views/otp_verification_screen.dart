import 'package:flutter/material.dart';
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../view_models/auth_view_model.dart';

/// شاشة إدخال رمز التحقق (OTP Verification Screen)
class OtpVerificationScreen extends StatefulWidget {
  final AuthViewModel viewModel;
  final VoidCallback? onVerificationSuccess;

  const OtpVerificationScreen({
    super.key,
    required this.viewModel,
    this.onVerificationSuccess,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getEnteredCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // إذا تم إدخال رقم، ننتقل للحقل التالي
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        // إذا اكتملت الـ 6 أرقام، نتحقق تلقائياً
        _handleVerify();
      }
    } else {
      // عند الحذف (Backspace)
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _handleVerify() async {
    final code = _getEnteredCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رمز التحقق المكون من 6 أرقام')),
      );
      return;
    }

    final success = await widget.viewModel.verifyOtp(code);
    if (success && mounted) {
      widget.onVerificationSuccess?.call();
      Navigator.of(context).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryGreenDark,
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('أهلاً بك يا ${widget.viewModel.user?.fullName ?? "مستخدم قطفة"}، تم تسجيل الدخول بنجاح!'),
            ],
          ),
        ),
      );
    }
  }

  void _useQuickCode(String code) {
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    setState(() {});
    _handleVerify();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.lightScaffold,
            appBar: AppBar(
              backgroundColor: AppColors.primaryGreenDark,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text(
                'رمز التحقق',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            body: TextScalerBoundary(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: AppSpacing.p20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.s16),

                      // الأيقونة والترويسة
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryGreen.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.mark_email_read_rounded,
                            color: AppColors.primaryGreenDark,
                            size: 32,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      Text(
                        'أدخل رمز التحقق (OTP)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreenDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        'تم إرسال رمز الأمان المكون من 6 أرقام إلى الرقم:\n${vm.phoneNumber}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s28),

                      // 6 مربعات إدخال الرمز
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return SizedBox(
                              width: 46,
                              height: 56,
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                maxLength: 1,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryGreenDark,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: AppSpacing.radius12,
                                    borderSide: const BorderSide(color: AppColors.lightBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppSpacing.radius12,
                                    borderSide: const BorderSide(color: AppColors.lightBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppSpacing.radius12,
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryGreen,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) => _onDigitChanged(index, val),
                              ),
                            );
                          }),
                        ),
                      ),

                      // رسالة الخطأ
                      if (vm.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.s16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: AppSpacing.radius12,
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                              const SizedBox(width: AppSpacing.s8),
                              Expanded(
                                child: Text(
                                  vm.errorMessage!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: AppSpacing.s24),

                      // خيار تجربة سريع في بيئة التطوير
                      if (vm.demoOtp != null)
                        InkWell(
                          onTap: () => _useQuickCode(vm.demoOtp!),
                          borderRadius: AppSpacing.radius12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: AppSpacing.radius12,
                              border: Border.all(color: const Color(0xFF86EFAC)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flash_on_rounded, color: Color(0xFF15803D), size: 18),
                                const SizedBox(width: AppSpacing.s6),
                                Text(
                                  'تعبئة تلقائية للرمز التجريبي: [${vm.demoOtp}]',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: AppSpacing.s20),

                      // زر تأكيد الرمز
                      QatfaPrimaryButton(
                        label: 'تأكيد ودخول',
                        isLoading: vm.isLoading,
                        leadingIcon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
                        onPressed: _handleVerify,
                      ),

                      const SizedBox(height: AppSpacing.s20),

                      // إعادة الإرسال مع عداد الثواني
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (vm.resendCountdown > 0)
                            Text(
                              'إعادة إرسال الرمز بعد 00:${vm.resendCountdown.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.lightTextSecondary,
                              ),
                            )
                          else
                            TextButton.icon(
                              onPressed: vm.canResend ? () => vm.resendOtp() : null,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text(
                                'إعادة إرسال رمز جديد',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
