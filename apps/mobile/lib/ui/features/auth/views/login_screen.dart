import 'package:flutter/material.dart';
import '../../../../core/responsive/text_scaler_boundary.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/qatfa_primary_button.dart';
import '../view_models/auth_view_model.dart';
import 'otp_verification_screen.dart';

/// شاشة تسجيل الدخول وإنشاء الحساب في منصة قطفة
class LoginScreen extends StatefulWidget {
  final AuthViewModel? viewModel;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({
    super.key,
    this.viewModel,
    this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final AuthViewModel _viewModel;
  late final bool _ownsViewModel;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _operatorLabel = '';

  @override
  void initState() {
    super.initState();
    _ownsViewModel = widget.viewModel == null;
    _viewModel = widget.viewModel ?? AuthViewModel();
    _phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    final text = _phoneController.text.trim();
    final op = AuthViewModel.getYemeniOperator(text);
    if (op != _operatorLabel) {
      setState(() {
        _operatorLabel = op;
      });
    }
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _nameController.dispose();
    _phoneController.dispose();
    if (_ownsViewModel) {
      _viewModel.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    FocusScope.of(context).unfocus();
    final success = await _viewModel.requestOtp(
      phone: _phoneController.text,
      name: _nameController.text,
    );

    if (success && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            viewModel: _viewModel,
            onVerificationSuccess: widget.onLoginSuccess,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
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
              title: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/images/qatfa_logo.png',
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.eco_rounded,
                    color: Color(0xFF4ADE80),
                    size: 26,
                  ),
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
                      const SizedBox(height: AppSpacing.s12),

                      // ترويسة الشاشة
                      Text(
                        'تسجيل الدخول / إنشاء حساب',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryGreenDark,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      Text(
                        'أهلاً بك في منصة قطفة، أدخل اسمك ورقم هاتفك للوصول لكافة العروض والحجوزات.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.lightTextSecondary,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s24),

                      // حقل الاسم الكامل
                      Text(
                        'الاسم الكامل (اختياري للعملاء / مطلوب للمقاوتة)',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      TextField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'مثال: أحمد صالح الحشيشي',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGreen, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.8),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // حقل رقم الهاتف اليمني
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'رقم الهاتف اليمني',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          if (_operatorLabel.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: AppSpacing.radiusFull,
                                border: Border.all(
                                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _operatorLabel,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreenDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.s6),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        decoration: InputDecoration(
                          hintText: '771234567',
                          hintTextDirection: TextDirection.ltr,
                          prefixIcon: Container(
                            margin: const EdgeInsets.only(right: 12, left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreenDark.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '+967',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryGreenDark,
                              ),
                            ),
                          ),
                          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                          suffixIcon: const Icon(Icons.phone_android_rounded, color: AppColors.primaryGreen, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.8),
                          ),
                        ),
                      ),

                      // رسالة الخطأ إن وجدت
                      if (_viewModel.errorMessage != null) ...[
                        const SizedBox(height: AppSpacing.s12),
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
                                  _viewModel.errorMessage!,
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

                      const SizedBox(height: AppSpacing.s20),

                      // تنبيه توجيه رمز الـ OTP للوحة التحكم
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: AppSpacing.radius16,
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: AppColors.primaryGreenDark,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.s10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'سجل رموز التحقق (OTP) في لوحة التحكم',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryGreenDark,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'في بيئة التطوير والاختبار، يتم إرسال وعرض رمز التحقق مباشرة في شاشة "رموز التحقق" بلوحة تحكم المشرف لتسهيل التجربة السريعة.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF166534),
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.s28),

                      // زر إرسال الرمز
                      QatfaPrimaryButton(
                        label: 'إرسال رمز التحقق',
                        isLoading: _viewModel.isLoading,
                        leadingIcon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _handleSendOtp,
                      ),

                      const SizedBox(height: AppSpacing.s16),

                      // شروط الاستخدام
                      Text(
                        'بالاستمرار، أنت توافق على شروط الاستخدام وسياسة حماية البيانات لمنصة قطفة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.lightTextMuted,
                          height: 1.4,
                        ),
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
