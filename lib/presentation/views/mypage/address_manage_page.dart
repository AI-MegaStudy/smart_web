import 'package:flutter/material.dart';
import 'package:kpostal_plus/kpostal_plus.dart';

import '../../../app/router.dart';
import '../../../data/repositories/address_repository.dart';
import '../../widgets/brand_app_bar_title.dart';

class AddressManagePage extends StatefulWidget {
  const AddressManagePage({super.key});

  @override
  State<AddressManagePage> createState() => _AddressManagePageState();
}

class _AddressManagePageState extends State<AddressManagePage> {
  final AddressRepository _repository = AddressRepository();
  late Future<List<CustomerAddress>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = _repository.fetchAddresses();
  }

  void _reload() {
    setState(() {
      _addressesFuture = _repository.fetchAddresses();
    });
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
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _PageShell(
                    title: '배송지 관리',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () async {
                            await Navigator.pushNamed(
                              context,
                              AppRoutes.addressAdd,
                            );
                            if (mounted) {
                              _reload();
                            }
                          },
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('배송지 추가하기'),
                        ),
                        const SizedBox(height: 20),
                        FutureBuilder<List<CustomerAddress>>(
                          future: _addressesFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(24),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final addresses = snapshot.data ?? const [];
                            if (addresses.isEmpty) {
                              return const _EmptyAddressPanel();
                            }
                            return Column(
                              children: [
                                for (final address in addresses) ...[
                                  _AddressItem(address: address),
                                  const SizedBox(height: 12),
                                ],
                              ],
                            );
                          },
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
}

class _AddressItem extends StatelessWidget {
  const _AddressItem({required this.address});

  final CustomerAddress address;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (address.label.isNotEmpty) _SmallBadge(label: address.label),
                if (address.isDefault) const _SmallBadge(label: '기본 배송지'),
                if (address.isRecent) const _SmallBadge(label: '최근 사용'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              address.receiverName,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              address.receiverPhone,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF5F6C62)),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () async => Navigator.pushNamed(
                context,
                AppRoutes.addressAdd,
                arguments: address.addressId,
              ),
              child: const Text('수정'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddressPanel extends StatelessWidget {
  const _EmptyAddressPanel();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F4),
        border: Border.all(color: const Color(0xFFE0E3DE)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Padding(
        padding: EdgeInsets.all(22),
        child: Text('저장된 배송지가 없습니다. 배송지를 추가해주세요.'),
      ),
    );
  }
}

class AddressAddPage extends StatefulWidget {
  const AddressAddPage({super.key, this.addressId});

  final int? addressId;

  @override
  State<AddressAddPage> createState() => _AddressAddPageState();
}

class _AddressAddPageState extends State<AddressAddPage> {
  final AddressRepository _repository = AddressRepository();
  bool _setDefault = false;
  bool _isSaving = false;
  String _requestMemo = '배송 요청사항을 선택해주세요';

  late final TextEditingController _nameController;
  late final TextEditingController _addressLabelController;
  late final TextEditingController _phoneController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _addressController;
  late final TextEditingController _detailAddressController;
  late final TextEditingController _customRequestController;

  bool get _isCustomRequest => _requestMemo == '직접 입력';
  bool get _isEdit => widget.addressId != null;

  @override
  void initState() {
    super.initState();
    _setDefault = true;
    _nameController = TextEditingController();
    _addressLabelController = TextEditingController();
    _phoneController = TextEditingController();
    _zipCodeController = TextEditingController();
    _addressController = TextEditingController();
    _detailAddressController = TextEditingController();
    _customRequestController = TextEditingController();
    if (_isEdit) {
      _loadAddress();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressLabelController.dispose();
    _phoneController.dispose();
    _zipCodeController.dispose();
    _addressController.dispose();
    _detailAddressController.dispose();
    _customRequestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEdit ? '배송지 수정' : '배송지 추가';
    final savedMessage = _isEdit ? '배송지가 수정되었습니다.' : '배송지가 저장되었습니다.';

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
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _PageShell(
                    title: title,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _FieldLabel('이름'),
                        _TextInput(
                          controller: _nameController,
                          hintText: '받는 분의 이름을 입력해주세요',
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('배송지 별명 (선택)'),
                        _TextInput(
                          controller: _addressLabelController,
                          hintText: '예: 내집, 부모님댁, 회사',
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('휴대폰번호'),
                        _TextInput(
                          controller: _phoneController,
                          hintText: '휴대폰번호를 입력해주세요',
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('주소'),
                        Row(
                          children: [
                            Expanded(
                              child: _TextInput(
                                controller: _zipCodeController,
                                hintText: '우편번호',
                              ),
                            ),
                            const SizedBox(width: 6),
                            OutlinedButton(
                              onPressed: _searchAddress,
                              child: const Text('주소 찾기'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _TextInput(
                          controller: _addressController,
                          hintText: '주소',
                        ),
                        const SizedBox(height: 8),
                        _TextInput(
                          controller: _detailAddressController,
                          hintText: '상세주소',
                        ),
                        const SizedBox(height: 18),
                        const _FieldLabel('배송 요청사항 (선택)'),
                        DropdownButtonFormField<String>(
                          initialValue: _requestMemo,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: '배송 요청사항을 선택해주세요',
                              child: Text('배송 요청사항을 선택해주세요'),
                            ),
                            DropdownMenuItem(
                              value: '문 앞에 놓아주세요',
                              child: Text('문 앞에 놓아주세요'),
                            ),
                            DropdownMenuItem(
                              value: '배송 전 연락해주세요',
                              child: Text('배송 전 연락해주세요'),
                            ),
                            DropdownMenuItem(
                              value: '부재 시 경비실에 맡겨주세요',
                              child: Text('부재 시 경비실에 맡겨주세요'),
                            ),
                            DropdownMenuItem(
                              value: '직접 입력',
                              child: Text('직접 입력'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _requestMemo = value);
                          },
                        ),
                        if (_isCustomRequest) ...[
                          const SizedBox(height: 8),
                          _TextInput(
                            controller: _customRequestController,
                            hintText: '배송 요청사항을 입력해주세요',
                          ),
                        ],
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _setDefault,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('기본 배송지로 설정'),
                          onChanged: (value) {
                            setState(() => _setDefault = value ?? false);
                          },
                        ),
                        const SizedBox(height: 96),
                        FilledButton(
                          onPressed: _isSaving
                              ? null
                              : () => _saveAddress(savedMessage),
                          child: Text(_isSaving ? '저장 중' : '저장하기'),
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

  Future<void> _searchAddress() async {
    final result = await Navigator.push<Kpostal>(
      context,
      MaterialPageRoute(
        builder: (_) => KpostalPlusView(
          title: '주소 찾기',
          appBarColor: Theme.of(context).colorScheme.primary,
          titleColor: Colors.white,
          loadingColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final selectedAddress = result.userSelectedAddress.isNotEmpty
        ? result.userSelectedAddress
        : result.address;

    setState(() {
      _zipCodeController.text = result.postCode;
      _addressController.text = selectedAddress;
    });
  }

  Future<void> _loadAddress() async {
    try {
      final addresses = await _repository.fetchAddresses();
      if (addresses.isEmpty) {
        return;
      }
      final address = addresses.firstWhere(
        (item) => item.addressId == widget.addressId,
        orElse: () => addresses.first,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _nameController.text = address.receiverName;
        _addressLabelController.text = address.label;
        _phoneController.text = address.receiverPhone;
        _zipCodeController.text = address.zipCode;
        _addressController.text = address.address;
        _detailAddressController.text = address.detailAddress;
        _requestMemo = address.deliveryMemo.isEmpty
            ? '배송 요청사항을 선택해주세요'
            : address.deliveryMemo;
        _setDefault = address.isDefault;
      });
    } catch (_) {
      if (mounted) {
        await _showNotice(context, '배송지 정보를 불러오지 못했습니다.');
      }
    }
  }

  Future<void> _showNotice(BuildContext context, String message) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAddress(String savedMessage) async {
    if (_nameController.text.trim().isEmpty) {
      await _showNotice(context, '이름을 입력해주세요.');
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      await _showNotice(context, '휴대폰번호를 입력해주세요.');
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      await _showNotice(context, '주소를 입력해주세요.');
      return;
    }

    if (_detailAddressController.text.trim().isEmpty) {
      await _showNotice(context, '상세주소를 입력해주세요.');
      return;
    }

    if (_isCustomRequest && _customRequestController.text.trim().isEmpty) {
      await _showNotice(context, '배송 요청사항을 입력해주세요.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final deliveryMemo = _isCustomRequest
          ? _customRequestController.text.trim()
          : _requestMemo == '배송 요청사항을 선택해주세요'
          ? ''
          : _requestMemo;
      await _repository.saveAddress(
        addressId: widget.addressId,
        label: _addressLabelController.text,
        receiverName: _nameController.text,
        receiverPhone: _phoneController.text,
        zipCode: _zipCodeController.text,
        address: _addressController.text,
        detailAddress: _detailAddressController.text,
        deliveryMemo: deliveryMemo,
        isDefault: _setDefault,
      );
    } catch (_) {
      if (mounted) {
        await _showNotice(context, '배송지를 저장하지 못했습니다. 잠시 후 다시 시도해주세요.');
      }
      if (mounted) {
        setState(() => _isSaving = false);
      }
      return;
    }

    if (!mounted) return;
    await _showNotice(context, savedMessage);
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _PageShell extends StatelessWidget {
  const _PageShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: const Color(0xFFF0F0EE),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ),
            Padding(padding: const EdgeInsets.all(16), child: child),
          ],
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({required this.controller, required this.hintText});

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
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

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1ED),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF4B584D),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
