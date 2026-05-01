import 'package:flutter/material.dart';

import '../../../app/router.dart';
import '../../view_models/auth_view_model.dart';
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
        child: AuthCard(
          title: '회원가입',
          description: '예약과 배송 안내를 받을 계정을 만듭니다.',
          children: [
            AuthTextField(
              label: '이메일',
              initialValue: _viewModel.email,
              onChanged: _viewModel.updateEmail,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: '비밀번호',
              initialValue: _viewModel.password,
              onChanged: _viewModel.updatePassword,
              obscureText: true,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: '이름',
              initialValue: _viewModel.name,
              onChanged: _viewModel.updateName,
            ),
            const SizedBox(height: 16),
            AuthTextField(
              label: '전화번호',
              initialValue: _viewModel.phone,
              onChanged: _viewModel.updatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, AppRoutes.login),
                  child: const Text('로그인'),
                ),
                const SizedBox(width: 10),
                FilledButton(
                  onPressed: _viewModel.canSignup
                      ? () =>
                            Navigator.pushNamed(context, AppRoutes.verifyEmail)
                      : null,
                  child: const Text('가입하고 인증'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
