import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../view_models/auth_view_model.dart';
import 'login_page.dart';

class EmailVerifyPage extends StatefulWidget {
  const EmailVerifyPage({super.key});

  @override
  State<EmailVerifyPage> createState() => _EmailVerifyPageState();
}

class _EmailVerifyPageState extends State<EmailVerifyPage> {
  late final EmailVerifyViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = EmailVerifyViewModel();
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
      body: AuthSplitLayout(
        imageUrl:
            'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?auto=format&fit=crop&w=1200&q=80',
        label: '이메일 확인',
        title: '이메일 인증',
        child: AuthCard(
          title: '인증 코드 입력',
          description: '메일로 받은 6자리 인증 코드를 입력하세요.',
          children: [
            Row(
              children: [
                for (final digit in _viewModel.codeDigits) ...[
                  Expanded(child: _CodeBox(digit: digit)),
                  if (digit != _viewModel.codeDigits.last)
                    const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(child: Text('만료까지')),
                Text(
                  '04:58',
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
                  onPressed: _viewModel.resendCode,
                  child: const Text('재발송'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _viewModel.canVerify
                      ? () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        )
                      : null,
                  child: const Text('인증 완료'),
                ),
              ],
            ),
          ],
        ),
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
