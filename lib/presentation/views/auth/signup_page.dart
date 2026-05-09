import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late final AuthViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await _viewModel.requestEmailVerification();
    if (!mounted) {
      return;
    }

    if (!success) {
      showAppAlertDialog(
        context,
        message: _viewModel.errorMessage ?? '회원가입 정보를 확인해주세요.',
      );
      return;
    }

    showAppAlertDialog(
      context,
      message: '인증 메일을 보냈습니다. 이메일 인증을 완료하면 회원가입이 진행됩니다.',
      onConfirm: () => Navigator.pushReplacementNamed(
        context,
        AppRoutes.verifyEmail,
        arguments: _viewModel.signupDraft,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 14,
        title: const AuthBrandTitle(),
      ),
      body: AuthSplitLayout(
        imageUrl:
            'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80',
        label: '처음 방문하셨나요?',
        title: '고객 계정 생성',
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return AuthCard(
              title: '회원가입',
              description: '예약과 배송 안내를 받을 계정을 만듭니다.',
              children: [
                AuthTextField(
                  label: '이메일',
                  initialValue: _viewModel.email,
                  onChanged: _viewModel.updateEmail,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 7),
                _ValidationLine(
                  valid: _viewModel.isEmailValid,
                  text: _viewModel.emailValidationText,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: '비밀번호',
                  initialValue: _viewModel.password,
                  onChanged: _viewModel.updatePassword,
                  obscureText: true,
                ),
                const SizedBox(height: 7),
                _ValidationLine(
                  valid: _viewModel.isPasswordValid,
                  text: _viewModel.passwordValidationText,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: '이름',
                  initialValue: _viewModel.name,
                  onChanged: _viewModel.updateName,
                ),
                const SizedBox(height: 7),
                _ValidationLine(
                  valid: _viewModel.isNameValid,
                  text: _viewModel.nameValidationText,
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  label: '전화번호',
                  initialValue: _viewModel.phone,
                  onChanged: _viewModel.updatePhone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 7),
                _ValidationLine(
                  valid: _viewModel.isPhoneValid,
                  text: _viewModel.phoneValidationText,
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _viewModel.isSubmitting
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            ),
                      child: const Text('로그인'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      onPressed: _viewModel.canSignup ? _submit : null,
                      child: Text(_viewModel.isSubmitting ? '가입 중' : '가입하기'),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ValidationLine extends StatelessWidget {
  const _ValidationLine({required this.valid, required this.text});

  final bool valid;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = valid ? const Color(0xFF22764D) : const Color(0xFFB84626);
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle_outline : Icons.error_outline,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
