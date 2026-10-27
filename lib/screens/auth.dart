import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';

// Figma p1 — Splash
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const SignInScreen(),
        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
      ));
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(fit: StackFit.expand, children: [
          const _TealPhoto(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Image.asset(logoAsset, semanticLabel: 'Zany Pottery and Glass'),
            ),
          ),
        ]),
      );
}

/// Pottery photo under the brand-teal tint (splash + auth headers).
class _TealPhoto extends StatelessWidget {
  const _TealPhoto();
  @override
  Widget build(BuildContext context) => Stack(fit: StackFit.expand, children: [
        Image.asset(img('splash_bg'), fit: BoxFit.cover),
        Container(color: Z.teal.withValues(alpha: 0.72)),
      ]);
}

/// Shared auth layout: photo header with logo and title, form below.
class _AuthLayout extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _AuthLayout({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final canPop = Navigator.of(context).canPop();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              height: 230 + top,
              child: Stack(fit: StackFit.expand, children: [
                const _TealPhoto(),
                Padding(
                  padding: EdgeInsets.fromLTRB(4, top + 4, 16, 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(
                      height: 40,
                      child: canPop
                          ? IconButton(
                              tooltip: 'Back',
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                            )
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4),
                      child: Image.asset(logoAsset, height: 40, semanticLabel: 'Zany Pottery and Glass'),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(title, style: p(24, w: FontWeight.w500, c: Colors.white)),
                    ),
                  ]),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
            ),
          ]),
        ),
      ),
    );
  }
}

void _enterApp(BuildContext context) => Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );

Widget _linkLine(String lead, String link, VoidCallback onTap) => Center(
      child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('$lead ', style: p(13.5)),
        InkWell(onTap: onTap, child: Text(link, style: p(13.5, w: FontWeight.w600, c: Z.orange, d: TextDecoration.underline))),
      ]),
    );

// Figma p2 — Sign In
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _user = TextEditingController();
  final _pass = TextEditingController();

  @override
  Widget build(BuildContext context) => _AuthLayout(title: 'Sign In', children: [
        Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ZField(
              label: 'User Name',
              hint: 'Enter Email ID or Mobile Number',
              controller: _user,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Enter your email or mobile number';
                if (t.contains('@')) return emailV(t);
                return phoneV(t);
              },
            ),
            PasswordField(label: 'Password', hint: 'Enter Password', controller: _pass, showToggle: false),
          ]),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
            child: Text('Forgot your password?', style: p(13.5)),
          ),
        ),
        const SizedBox(height: 28),
        ZButton('Sign In', onPressed: () {
          if (!_form.currentState!.validate()) return;
          AppScope.read(context).signIn();
          _enterApp(context);
        }),
        const SizedBox(height: 28),
        _linkLine("Don't Have an Account?", 'Sign Up',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpScreen()))),
      ]);
}

// Figma p3 — Create an account
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  bool _accept = true;

  void _submit() {
    if (!_form.currentState!.validate()) return;
    if (!_accept) {
      toast(context, 'Please accept the Terms and Conditions and Privacy Policy.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phone: _phone.text.trim(),
          onVerified: (ctx) {
            AppScope.read(ctx).register(
                first: _first.text.trim(), last: _last.text.trim(), email: _email.text.trim(), phone: _phone.text.trim());
            _enterApp(ctx);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _AuthLayout(title: 'Create an account', children: [
        Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ZField(label: 'First Name', hint: 'Enter First Name', controller: _first, validator: requiredV),
            ZField(label: 'Last Name', hint: 'Enter Last Name', controller: _last, validator: requiredV),
            ZField(label: 'Email', hint: 'Enter your Email', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
            ZField(label: 'Phone Number', hint: 'Enter your Phone Number', controller: _phone, keyboard: TextInputType.phone, validator: phoneV),
            PasswordField(label: 'Password', hint: 'Enter your Password', controller: _pass),
            PasswordField(
              label: 'Confirm Password',
              hint: 'Enter your Confirm Password',
              controller: _confirm,
              validator: (v) => v != _pass.text ? 'Passwords don’t match' : null,
            ),
            ZField(label: 'Got a referral code?', hint: 'Enter Code', controller: _code),
          ]),
        ),
        const SizedBox(height: 16),
        CheckLine(
          value: _accept,
          onChanged: (v) => setState(() => _accept = v),
          label: Text.rich(TextSpan(style: p(13), children: [
            const TextSpan(text: 'You accept our '),
            TextSpan(text: 'Terms and Conditions and Privacy Policy', style: p(13, c: Z.orange, d: TextDecoration.underline)),
          ])),
        ),
        const SizedBox(height: 24),
        ZButton('Sign Up', onPressed: _submit),
        const SizedBox(height: 24),
        _linkLine('Already have account?', 'Log In', () => Navigator.pop(context)),
      ]);
}

// Figma p4 — OTP Verification
class OtpScreen extends StatefulWidget {
  final String phone;
  final void Function(BuildContext context) onVerified;
  const OtpScreen({super.key, required this.phone, required this.onVerified});
  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 30;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 1) t.cancel();
      if (mounted) setState(() => _seconds = _seconds > 0 ? _seconds - 1 : 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  Widget _box(int i) => SizedBox(
        width: 44,
        height: 48,
        child: TextField(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: p(18, w: FontWeight.w500),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(counterText: '', contentPadding: EdgeInsets.symmetric(vertical: 12)),
          onChanged: (v) {
            if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
            if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
            setState(() {});
          },
        ),
      );

  @override
  Widget build(BuildContext context) => _AuthLayout(title: 'OTP Verification', children: [
        const SizedBox(height: 8),
        Text.rich(TextSpan(style: p(13.5), children: [
          const TextSpan(text: 'OTP was sent to '),
          TextSpan(text: widget.phone, style: p(13.5, c: Z.orange)),
        ])),
        const SizedBox(height: 12),
        Text('Please enter the OTP you have received your registered Mobile Number', style: p(13.5)),
        const SizedBox(height: 24),
        Text('Enter OTP', style: p(13.5, w: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(children: [
          for (var i = 0; i < 3; i++) ...[_box(i), const SizedBox(width: 10)],
          const SizedBox(width: 14),
          for (var i = 3; i < 6; i++) ...[_box(i), if (i < 5) const SizedBox(width: 10)],
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Text("Didn't receive the code? ", style: p(13.5)),
          InkWell(
            onTap: _seconds == 0
                ? () {
                    _start();
                    toast(context, 'A new code was sent to ${widget.phone}');
                  }
                : null,
            child: Text('Resend code',
                style: p(13.5, c: _seconds == 0 ? Z.orange : Z.greyBtn, d: TextDecoration.underline)),
          ),
        ]),
        const SizedBox(height: 12),
        Text('Time Remaining 0:${_seconds.toString().padLeft(2, '0')}s', style: p(13.5)),
        const SizedBox(height: 16),
        Text('Prototype: any 6 digits will verify.', style: p(11.5, c: Z.sub)),
        const SizedBox(height: 24),
        ZButton('Confirm', onPressed: _code.length == 6 ? () => widget.onVerified(context) : null),
      ]);
}

// Forgot password → OTP → new password (not in Figma; uses the same layout).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _c = TextEditingController();
  @override
  Widget build(BuildContext context) => _AuthLayout(title: 'Forgot Password', children: [
        Text('Enter the mobile number linked to your account and we’ll send you a code.', style: p(13.5)),
        Form(
          key: _form,
          child: ZField(label: 'Mobile Number', hint: 'Enter your Phone Number', controller: _c, keyboard: TextInputType.phone, validator: phoneV),
        ),
        const SizedBox(height: 28),
        ZButton('Send Code', onPressed: () {
          if (!_form.currentState!.validate()) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phone: _c.text.trim(),
                onVerified: (ctx) => Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const ResetPasswordScreen())),
              ),
            ),
          );
        }),
      ]);
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});
  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _a = TextEditingController();
  final _b = TextEditingController();
  @override
  Widget build(BuildContext context) => _AuthLayout(title: 'New Password', children: [
        Form(
          key: _form,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            PasswordField(label: 'New Password', hint: 'Enter New Password', controller: _a),
            PasswordField(
                label: 'Re-type New Password',
                hint: 'Enter Re-type New Password',
                controller: _b,
                validator: (v) => v != _a.text ? 'Passwords don’t match' : null),
          ]),
        ),
        const SizedBox(height: 28),
        ZButton('Update Password', onPressed: () {
          if (!_form.currentState!.validate()) return;
          final messenger = ScaffoldMessenger.of(context);
          Navigator.of(context).popUntil((r) => r.isFirst);
          messenger.showSnackBar(const SnackBar(content: Text('Password updated.')));
        }),
      ]);
}
