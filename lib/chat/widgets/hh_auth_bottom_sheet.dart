import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scan_job/repositories/hh_auth_repository.dart';
import 'package:scan_job/tools/hh_tool.dart';

enum _AuthStep { phone, otp, captcha }

class HhAuthBottomSheet extends StatefulWidget {
  const HhAuthBottomSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const HhAuthBottomSheet(),
    );
  }

  @override
  State<HhAuthBottomSheet> createState() => _HhAuthBottomSheetState();
}

class _HhAuthBottomSheetState extends State<HhAuthBottomSheet> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _captchaController = TextEditingController();
  final _authRepository = HhAuthRepository();

  _AuthStep _currentStep = _AuthStep.phone;
  bool _isLoading = false;
  String? _sessionId;
  String? _captchaBase64;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _handlePhoneSubmit() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.loginPhone(_phoneController.text.trim());
      await _processAuthResult(result);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleOtpSubmit() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.submitCode(_sessionId!, _otpController.text.trim());
      await _processAuthResult(result);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCaptchaSubmit() async {
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.submitCaptcha(_sessionId!, _captchaController.text.trim());
      await _processAuthResult(result);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processAuthResult(Map<String, dynamic> result) async {
    if (result['success'] == true) {
      final tokens = result['tokens'] as Map<String, dynamic>;
      final accountId = await HhTool.instance.authService.saveAccountFromTokens(tokens);
      if (mounted) Navigator.of(context).pop(accountId);
      return;
    }

    _sessionId = result['session_id'] as String?;
    final status = result['status'] as String?;

    if (status == 'waiting_captcha') {
      setState(() {
        _currentStep = _AuthStep.captcha;
        _captchaBase64 = result['captcha_image'] as String?;
      });
    } else if (status == 'waiting_otp' || status == 'waiting_otp_with_password_option') {
      setState(() => _currentStep = _AuthStep.otp);
    } else {
      _showError('Unknown server state: $status');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            _buildStepContent(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    String title;
    switch (_currentStep) {
      case _AuthStep.phone: title = 'HH Login'; break;
      case _AuthStep.otp: title = 'Enter SMS Code'; break;
      case _AuthStep.captcha: title = 'Security Check'; break;
    }
    return Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case _AuthStep.phone:
        return _buildPhoneStep();
      case _AuthStep.otp:
        return _buildOtpStep();
      case _AuthStep.captcha:
        return _buildCaptchaStep();
    }
  }

  Widget _buildPhoneStep() {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone (7999...)', border: OutlineInputBorder()),
          keyboardType: TextInputType.phone,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handlePhoneSubmit, child: const Text('Get Code'))),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      children: [
        TextField(
          controller: _otpController,
          decoration: const InputDecoration(labelText: 'SMS Code', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handleOtpSubmit, child: const Text('Confirm'))),
        TextButton(onPressed: () => setState(() => _currentStep = _AuthStep.phone), child: const Text('Back')),
      ],
    );
  }

  Widget _buildCaptchaStep() {
    return Column(
      children: [
        if (_captchaBase64 != null) Image.memory(base64Decode(_captchaBase64!)),
        const SizedBox(height: 16),
        TextField(
          controller: _captchaController,
          decoration: const InputDecoration(labelText: 'Text from image', border: OutlineInputBorder()),
          autofocus: true,
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _handleCaptchaSubmit, child: const Text('Verify'))),
      ],
    );
  }
}
