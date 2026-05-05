import 'package:flutter/material.dart';

import '../../widgets/app_alert_dialog.dart';
import '../../widgets/brand_app_bar_title.dart';

class MemberEditPage extends StatefulWidget {
  const MemberEditPage({super.key});

  @override
  State<MemberEditPage> createState() => _MemberEditPageState();
}

class _MemberEditPageState extends State<MemberEditPage> {
  final _nameController = TextEditingController(text: '홍길동');
  final _emailController = TextEditingController(text: 'customer@test.com');
  final _phoneController = TextEditingController(text: '010-1111-2222');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 14,
        title: const BrandAppBarTitle(),
      ),
      body: Container(
        color: const Color(0xFFF7F7F4),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _PageHeader(),
                        const SizedBox(height: 16),
                        _EditForm(
                          nameController: _nameController,
                          emailController: _emailController,
                          phoneController: _phoneController,
                          onVerifyEmail: () => showAppAlertDialog(
                            context,
                            message:
                                '이메일 인증은 선택 사항입니다. 실제 인증 메일 발송은 백엔드 연결 후 적용할 예정입니다.',
                          ),
                          onSave: _save,
                        ),
                      ],
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

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      await showAppAlertDialog(context, message: '이름을 입력해주세요.');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      await showAppAlertDialog(context, message: '이메일을 입력해주세요.');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      await showAppAlertDialog(context, message: '휴대폰번호를 입력해주세요.');
      return;
    }

    await showAppAlertDialog(context, message: '회원 정보가 저장되었습니다.');
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFF0F0EE)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Text(
          '회원 정보 수정',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _EditForm extends StatelessWidget {
  const _EditForm({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.onVerifyEmail,
    required this.onSave,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final VoidCallback onVerifyEmail;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE0E3DE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _FieldLabel('이름'),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '이름을 입력해주세요',
              ),
            ),
            const SizedBox(height: 18),
            const _FieldLabel('이메일'),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 520;
                final emailField = TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '이메일을 입력해주세요',
                  ),
                );

                final verifyButton = OutlinedButton(
                  onPressed: onVerifyEmail,
                  child: const Text('인증하기'),
                );

                if (isNarrow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      emailField,
                      const SizedBox(height: 8),
                      verifyButton,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: emailField),
                    const SizedBox(width: 8),
                    SizedBox(width: 104, child: verifyButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '이메일 인증은 선택 사항입니다. 인증하지 않아도 정보 저장은 가능합니다.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF657166),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            const _FieldLabel('휴대폰번호'),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '휴대폰번호를 입력해주세요',
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(onPressed: onSave, child: const Text('저장하기')),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}
