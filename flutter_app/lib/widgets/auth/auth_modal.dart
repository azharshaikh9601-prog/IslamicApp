import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/storage_service.dart';

class AuthModal extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthModal({super.key, this.onAuthSuccess});

  static void show(BuildContext context, {VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AuthModal(onAuthSuccess: onSuccess),
    );
  }

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In Controllers
  final _loginIdentifierCtrl = TextEditingController();
  final _loginPasswordCtrl = TextEditingController();

  // Sign Up Controllers
  final _registerUsernameCtrl = TextEditingController();
  final _registerEmailCtrl = TextEditingController();
  final _registerPasswordCtrl = TextEditingController();

  // Forgot Password Controllers
  final _forgotIdentifierCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _isForgotPasswordMode = false;
  bool _isOtpSent = false;
  String? _sentOtpCode;
  String? _successMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdentifierCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _registerUsernameCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerPasswordCtrl.dispose();
    _forgotIdentifierCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final identifier = _loginIdentifierCtrl.text.trim();
    final password = _loginPasswordCtrl.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please enter both email/username and password.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final appState = AppStateService();
    final res = await appState.login(
      emailOrUsername: identifier,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Successfully logged in!'),
          backgroundColor: AppColors.darkEmerald,
        ),
      );
    } else {
      setState(() => _errorMessage = res['message'] ?? 'Invalid credentials.');
    }
  }

  Future<void> _handleRegister() async {
    final username = _registerUsernameCtrl.text.trim();
    final email = _registerEmailCtrl.text.trim();
    final password = _registerPasswordCtrl.text.trim();

    if (username.length < 2) {
      setState(() => _errorMessage = 'Username must be at least 2 characters.');
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    if (password.length < 8) {
      setState(() => _errorMessage = 'Password must be a strong password of at least 8 digits/characters.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final appState = AppStateService();
    final res = await appState.register(
      username: username,
      email: email,
      password: password,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Account created successfully!'),
          backgroundColor: AppColors.darkEmerald,
        ),
      );
    } else {
      setState(() => _errorMessage = res['message'] ?? 'Registration failed.');
    }
  }

  void _fillDemoAdmin() {
    setState(() {
      _tabController.index = 0;
      _loginIdentifierCtrl.text = 'admin@hafizhasnainjaani.com';
      _loginPasswordCtrl.text = 'Admin@1234';
      _errorMessage = null;
    });
  }

  void _fillDemoStudent() {
    setState(() {
      _tabController.index = 0;
      _loginIdentifierCtrl.text = 'student@hafizhasnainjaani.com';
      _loginPasswordCtrl.text = 'Student@1234';
      _errorMessage = null;
    });
  }

  Future<void> _handleRequestOtp() async {
    final identifier = _forgotIdentifierCtrl.text.trim();
    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please enter your registered email or username.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final appState = AppStateService();
    final res = await appState.requestPasswordReset(emailOrUsername: identifier);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      setState(() {
        _isOtpSent = true;
        _sentOtpCode = res['resetCode']?.toString();
        if (_sentOtpCode != null && _sentOtpCode!.isNotEmpty) {
          _otpCtrl.text = _sentOtpCode!;
        }
        _successMessage = res['message'] ?? 'OTP code generated successfully!';
      });
    } else {
      setState(() => _errorMessage = res['message'] ?? 'Unable to find user account.');
    }
  }

  Future<void> _handleResetPassword() async {
    final identifier = _forgotIdentifierCtrl.text.trim();
    final code = _otpCtrl.text.trim();
    final newPass = _newPasswordCtrl.text.trim();
    final confirmPass = _confirmPasswordCtrl.text.trim();

    if (identifier.isEmpty) {
      setState(() => _errorMessage = 'Please provide your email or username.');
      return;
    }
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter the 6-digit OTP code.');
      return;
    }
    if (newPass.length < 8) {
      setState(() => _errorMessage = 'New password must be at least 8 characters/digits long.');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _errorMessage = 'Passwords do not match. Please verify both fields.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final appState = AppStateService();
    final res = await appState.resetPassword(
      emailOrUsername: identifier,
      resetCode: code,
      newPassword: newPass,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (res['success'] == true) {
      Navigator.of(context).pop();
      widget.onAuthSuccess?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? '✓ Password reset successfully! Logged in.'),
          backgroundColor: AppColors.darkEmerald,
        ),
      );
    } else {
      setState(() => _errorMessage = res['message'] ?? 'Password reset failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Container(
        width: 440,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF041E16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primaryGold.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Logo / Icon
            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderEmerald)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Icon(
                      _isForgotPasswordMode ? Icons.lock_reset : Icons.person,
                      color: AppColors.primaryGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isForgotPasswordMode ? 'पासवर्ड रीसेट करें (Reset Password)' : 'इस्लामिक ऐप अकाउंट (Islamic Account)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isForgotPasswordMode
                              ? 'रजिस्टर ईमेल दर्ज करें और 6-अंकों का OTP सत्यापित करें'
                              : 'लॉग इन करें या 8+ अक्षरों के पासवर्ड से अकाउंट बनाएं',
                          style: const TextStyle(
                            color: AppColors.darkTextMuted,
                            fontSize: 10.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            if (!_isForgotPasswordMode) ...[
              // Tab Bar (Hindi + English)
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryGold,
                unselectedLabelColor: AppColors.darkTextMuted,
                indicatorColor: AppColors.primaryGold,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'लॉग इन (Sign In)'),
                  Tab(text: 'रजिस्टर करें (Register)'),
                ],
              ),
            ],

            // Flexible Scrollable Body: Adapts to small mobiles and laptops without overflowing!
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_successMessage != null)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF064E3B).withOpacity(0.35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: Color(0xFF34D399), size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (_isForgotPasswordMode)
                      _buildForgotPasswordView()
                    else
                      _tabController.index == 0 ? _buildSignInTab() : _buildSignUpTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _loginIdentifierCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Email or Username',
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primaryGold, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _loginPasswordCtrl,
            obscureText: _obscureLoginPassword,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: '8+ Digit Password',
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureLoginPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.darkTextMuted,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                setState(() {
                  _isForgotPasswordMode = true;
                  _forgotIdentifierCtrl.text = _loginIdentifierCtrl.text.trim();
                  _errorMessage = null;
                  _successMessage = null;
                });
              },
              icon: const Icon(Icons.lock_reset, size: 14, color: AppColors.brightGold),
              label: const Text(
                'Forgot Password? (पासवर्ड भूल गए?)',
                style: TextStyle(color: AppColors.brightGold, fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald),
                  )
                : const Text(
                    'लॉग इन करें (Sign In)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
          const SizedBox(height: 12),
          // Demo Admin Credentials Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF05271D),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.admin_panel_settings, color: AppColors.primaryGold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'डेमो एडमिन क्रेडेंशियल्स (Admin Login):',
                        style: TextStyle(color: AppColors.primaryGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'admin@hafizhasnainjaani.com • Admin@1234',
                        style: TextStyle(color: Colors.white70, fontSize: 9.5),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _fillDemoAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGold,
                    foregroundColor: AppColors.darkEmerald,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('स्वतः भरें', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Quick login helper buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _fillDemoStudent,
                child: const Text('छात्र डेमो (Student Demo)', style: TextStyle(color: AppColors.lightGold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _registerUsernameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'User Name (e.g. Ahmad Khan)',
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGold, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _registerEmailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Email Address (e.g. user@example.com)',
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryGold, size: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _registerPasswordCtrl,
            obscureText: _obscureRegisterPassword,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: '8-Digit Strong Password',
              helperText: 'Must be at least 8 characters long',
              helperStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 10),
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold, size: 18),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureRegisterPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.darkTextMuted,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureRegisterPassword = !_obscureRegisterPassword),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleRegister,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.darkEmerald,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald),
                  )
                : const Text(
                    'अकाउंट बनाएं और लॉग इन करें (Sign Up)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 1: Identifier Input
          TextField(
            controller: _forgotIdentifierCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Registered Email or Username',
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.alternate_email, color: AppColors.primaryGold, size: 18),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.primaryGold, size: 18),
                tooltip: 'Send OTP',
                onPressed: _isSubmitting ? null : _handleRequestOtp,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primaryGold),
              ),
              filled: true,
              fillColor: const Color(0xFF021610),
            ),
          ),

          const SizedBox(height: 10),

          if (!_isOtpSent) ...[
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _handleRequestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.mark_email_read_outlined, size: 16),
              label: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald),
                    )
                  : const Text('Get 6-Digit OTP Code (ओटीपी कोड प्राप्त करें)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),

            const SizedBox(height: 12),

            // Demo Scholar Quick Recovery Tile
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF05271D),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryGold.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primaryGold, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'एडमिन इमरजेंसी रिकवरी पिन: 786786',
                      style: TextStyle(color: AppColors.lightGold, fontSize: 10.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _forgotIdentifierCtrl.text = 'admin@hafizhasnainjaani.com';
                        _isOtpSent = true;
                        _sentOtpCode = '786786';
                        _otpCtrl.text = '786786';
                        _newPasswordCtrl.text = 'Admin@1234';
                        _confirmPasswordCtrl.text = 'Admin@1234';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('स्वतः भरें', style: TextStyle(color: Color(0xFF021610), fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_isOtpSent) ...[
            // Generated OTP Showcase Card
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF063323),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.brightGold),
                boxShadow: [
                  BoxShadow(color: AppColors.primaryGold.withOpacity(0.2), blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.key, color: AppColors.brightGold, size: 15),
                      SizedBox(width: 6),
                      Text(
                        'आपका 6-अंकों का वेरिफिकेशन ओटीपी (OTP):',
                        style: TextStyle(color: AppColors.lightGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF021610),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: Text(
                      _sentOtpCode ?? '786786',
                      style: const TextStyle(
                        color: AppColors.brightGold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'कोड नीचे स्वतः भर गया है • 15 मिनट के लिए मान्य',
                    style: TextStyle(color: Colors.white70, fontSize: 9.5),
                  ),
                ],
              ),
            ),

            // OTP Input
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 2),
              decoration: InputDecoration(
                labelText: '6-अंकों का ओटीपी दर्ज करें (Enter 6-Digit OTP)',
                labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                prefixIcon: const Icon(Icons.pin, color: AppColors.primaryGold, size: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderEmerald),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
                filled: true,
                fillColor: const Color(0xFF021610),
              ),
            ),

            const SizedBox(height: 10),

            // New Password Input
            TextField(
              controller: _newPasswordCtrl,
              obscureText: _obscureNewPassword,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'नया पासवर्ड (8+ अक्षर) (New Password)',
                labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                prefixIcon: const Icon(Icons.lock_reset, color: AppColors.primaryGold, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.darkTextMuted, size: 18),
                  onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderEmerald),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
                filled: true,
                fillColor: const Color(0xFF021610),
              ),
            ),

            const SizedBox(height: 10),

            // Confirm New Password Input
            TextField(
              controller: _confirmPasswordCtrl,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'नए पासवर्ड की पुष्टि करें (Confirm Password)',
                labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
                prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.darkTextMuted, size: 18),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderEmerald),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primaryGold),
                ),
                filled: true,
                fillColor: const Color(0xFF021610),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.darkEmerald),
                    )
                  : const Text(
                      'Confirm & Reset Password (पासवर्ड रीसेट करें)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
            ),
          ],

          const SizedBox(height: 10),

          // Back to Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isForgotPasswordMode = false;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                },
                icon: const Icon(Icons.arrow_back, size: 14, color: AppColors.lightGold),
                label: const Text(
                  '← Back to Sign In (वापस लॉग इन करें)',
                  style: TextStyle(color: AppColors.lightGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
