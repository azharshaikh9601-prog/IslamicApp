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

  bool _obscureLoginPassword = true;
  bool _obscureRegisterPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdentifierCtrl.dispose();
    _loginPasswordCtrl.dispose();
    _registerUsernameCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerPasswordCtrl.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 440,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderEmerald)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGold.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: const Icon(Icons.person, color: AppColors.primaryGold, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Islamic App Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Sign in or Register with 8+ char password',
                          style: TextStyle(
                            color: AppColors.darkTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryGold,
              unselectedLabelColor: AppColors.darkTextMuted,
              indicatorColor: AppColors.primaryGold,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Sign In (لاگ ان)'),
                Tab(text: 'Register (اکاؤنٹ بنائیں)'),
              ],
            ),

            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.fromLTRB(18, 12, 18, 0),
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
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11.5),
                      ),
                    ),
                  ],
                ),
              ),

            // Tab Views
            SizedBox(
              height: 330,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSignInTab(),
                  _buildSignUpTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _handleLogin,
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
                    'Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
          ),
          const Spacer(),
          // Quick login helper buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _fillDemoAdmin,
                child: const Text('Admin Demo', style: TextStyle(color: AppColors.primaryGold, fontSize: 11)),
              ),
              const Text('•', style: TextStyle(color: Colors.white38)),
              TextButton(
                onPressed: _fillDemoStudent,
                child: const Text('Student Demo', style: TextStyle(color: AppColors.lightGold, fontSize: 11)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
                    'Create Account & Sign In',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
          ),
        ],
      ),
    );
  }
}
