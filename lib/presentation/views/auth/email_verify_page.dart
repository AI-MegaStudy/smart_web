import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../../demo/customer_coach_tour_manager.dart';
import '../../../demo/customer_demo_target_keys.dart';
import '../../view_models/auth_view_model.dart';
import '../../widgets/app_alert_dialog.dart';
import 'login_page.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({super.key, required this.email, this.signupDraft});

  final String email;
  final SignupVerificationArgs? signupDraft;

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  late final EmailVerifyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmailVerifyViewModel(
      initialEmail: widget.email,
      signupDraft: widget.signupDraft,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      CustomerCoachTourManager.instance.onPageReady(
        CustomerCoachTourStage.verifyEmail,
        context,
      );
    });
    if (widget.signupDraft?.emailAlreadySent != true) {
      _viewModel.sendCode();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
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
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          return AuthSplitLayout(
            imageUrl:
                'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=1200&q=80',
            label: '이메일 확인',
            title: '이메일 인증',
            child: AuthCard(
              title: '인증 코드 입력',
              description: '${_viewModel.email} 메일로 받은 6자리 인증 코드를 입력하세요.',
              children: [
                TextFormField(
                  initialValue: _viewModel.code,
                  onChanged: _viewModel.updateCode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: '인증 코드',
                    hintText: '6자리 숫자 입력',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (
                      var index = 0;
                      index < _viewModel.codeDigits.length;
                      index += 1
                    ) ...[
                      Expanded(
                        child: _CodeBox(digit: _viewModel.codeDigits[index]),
                      ),
                      if (index != _viewModel.codeDigits.length - 1)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
                if (_viewModel.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _viewModel.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFB84626),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Text('인증 메일')),
                    Text(
                      _viewModel.isSending ? '발송 중' : '발송 완료',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.tonal(
                      onPressed: _viewModel.isSending
                          ? null
                          : () => _viewModel.resendCode(),
                      child: Text(_viewModel.isSending ? '발송 중' : '재발송'),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      key: CustomerDemoTargetKeys.verifyEmailPrimaryAction,
                      onPressed: _viewModel.isVerifying
                          ? null
                          : () async {
                              final verified = await _viewModel.verify();
                              if (!context.mounted) {
                                return;
                              }
                              if (!verified) {
                                showAppAlertDialog(
                                  context,
                                  message:
                                      _viewModel.errorMessage ??
                                      '인증 코드를 확인해주세요.',
                                );
                                return;
                              }

                              final signedUp = await _viewModel
                                  .completeSignupAfterVerification();
                              if (!context.mounted) {
                                return;
                              }
                              if (!signedUp) {
                                showAppAlertDialog(
                                  context,
                                  message:
                                      _viewModel.errorMessage ??
                                      '회원가입 처리 중 문제가 발생했습니다.',
                                );
                                return;
                              }

                              showAppAlertDialog(
                                context,
                                message: '이메일 인증과 회원가입이 완료되었습니다. 로그인해주세요.',
                                onConfirm: () => Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.login,
                                ),
                              );
                            },
                      child: Text(_viewModel.isVerifying ? '확인 중' : '인증 완료'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({required this.digit});

  final String digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFE9EBE5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        digit.trim().isEmpty ? '-' : digit,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
