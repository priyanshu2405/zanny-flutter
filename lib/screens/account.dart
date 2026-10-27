import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'auth.dart';
import 'info_pages.dart';

// ─── Figma p35 — My Profile ──────────────────────────────────────────────

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  static const _finished = ['glass_blue', 'glass_leaf', 'glass_flower', 'clay_bowls', 'glass_ocean', 'glass_swirl'];

  Future<void> _upload(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('Take a photo', style: p(14)),
              onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('Choose from gallery', style: p(14)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
        ]),
      ),
    );
    if (source == null) return;
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (file == null || !context.mounted) return;
      AppScope.read(context).addPicture(file.path);
      toast(context, 'Picture uploaded. We’ll notify you when your piece is ready for pickup.');
    } catch (_) {
      if (context.mounted) toast(context, 'Couldn’t open the ${source == ImageSource.camera ? 'camera' : 'gallery'}. Check app permissions.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    Widget field(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: Z.orange, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: p(13)),
                const SizedBox(height: 4),
                Text(value, style: p(13.5, h: 1.5)),
              ]),
            ),
          ]),
        );
    return Scaffold(
      appBar: ZAppBar('My Profile', actions: [
        TextButton(
          onPressed: () => pushTab(context, const EditProfileScreen()),
          child: Text('Edit', style: p(15, c: Colors.white)),
        ),
      ]),
      body: ListView(padding: const EdgeInsets.only(bottom: 20), children: [
        field(Icons.person_outline, 'Name', s.name),
        const Divider(indent: 20, endIndent: 20),
        field(Icons.mail_outline, 'Email', s.email),
        const Divider(indent: 20, endIndent: 20),
        field(Icons.phone_outlined, 'Phone Number', s.phone),
        const Divider(indent: 20, endIndent: 20),
        field(Icons.location_on_outlined, 'Address', s.address),
        const Divider(indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('My Pictures', style: p(13.5, w: FontWeight.w500)),
            const SizedBox(height: 4),
            Text('Upload photos of your finished pieces here and you will receive a notifications when ready for pickup.',
                style: p(11.5, c: const Color(0xFF444444))),
            InkWell(
              onTap: () => _upload(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(children: [
                  Expanded(child: Text('Upload Pictures here', style: p(13.5, w: FontWeight.w600))),
                  const Icon(Icons.attach_file, size: 22),
                ]),
              ),
            ),
          ]),
        ),
        const Divider(indent: 20, endIndent: 20),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          child: Row(children: [
            Expanded(child: Text('Finished pieces', style: p(13.5, w: FontWeight.w500))),
            IconButton(
              tooltip: 'Share',
              onPressed: () => toast(context, 'Sharing will open the system share sheet in the production app.'),
              icon: const Icon(Icons.share_outlined, size: 22),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              for (final path in s.uploadedPictures)
                ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(File(path), fit: BoxFit.cover)),
              for (final f in _finished) ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.asset(img(f), fit: BoxFit.cover)),
            ],
          ),
        ),
      ]),
    );
  }
}

// ─── Figma p36 — Edit Profile ────────────────────────────────────────────

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final AppState _s = AppScope.read(context);
  late final _name = TextEditingController(text: _s.name);
  late final _email = TextEditingController(text: _s.email);
  late final _phone = TextEditingController(text: _s.phone);
  late final _address = TextEditingController(text: _s.address);

  Widget _label(IconData icon, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 0, 8),
        child: Row(children: [Icon(icon, color: Z.orange, size: 22), const SizedBox(width: 10), Text(t, style: p(13))]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Edit Profile'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), children: [
            _label(Icons.person_outline, 'Name'),
            TextFormField(controller: _name, style: p(14), validator: requiredV),
            _label(Icons.mail_outline, 'Email'),
            TextFormField(controller: _email, style: p(14), keyboardType: TextInputType.emailAddress, validator: emailV),
            _label(Icons.phone_outlined, 'Phone Number'),
            TextFormField(controller: _phone, style: p(14), keyboardType: TextInputType.phone, validator: phoneV),
            _label(Icons.location_on_outlined, 'Address'),
            TextFormField(controller: _address, style: p(14, h: 1.6), maxLines: 4, validator: requiredV),
            const SizedBox(height: 36),
            ZButton('Save', onPressed: () {
              if (!_form.currentState!.validate()) return;
              _s.updateProfile(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim(), address: _address.text.trim());
              Navigator.pop(context);
              toast(context, 'Profile saved.');
            }),
          ]),
        ),
      );
}

// ─── Figma p34 — Settings ────────────────────────────────────────────────

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    Widget row(IconData icon, String label, {Widget? trailing, VoidCallback? onTap}) => Column(children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Icon(icon, color: Z.text),
            title: Text(label, style: p(14)),
            trailing: trailing,
            onTap: onTap,
          ),
          const Divider(indent: 20, endIndent: 20),
        ]);
    return Scaffold(
      appBar: const ZAppBar('Settings'),
      body: ListView(padding: const EdgeInsets.only(top: 8), children: [
        row(Icons.notifications_none, 'Notifications',
            trailing: Switch(value: s.notificationsOn, onChanged: s.toggleNotifications),
            onTap: () => s.toggleNotifications(!s.notificationsOn)),
        row(Icons.lock_outline, 'Change Password', onTap: () => pushTab(context, const ChangePasswordScreen())),
        row(Icons.shield_outlined, 'Privacy Policy', onTap: () => pushTab(context, const PolicyScreen(title: 'Privacy Policy'))),
        row(Icons.description_outlined, 'Terms & Conditions',
            onTap: () => pushTab(context, const PolicyScreen(title: 'Terms & Conditions', terms: true))),
      ]),
    );
  }
}

// ─── Figma p37 — Change Password ─────────────────────────────────────────

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _cur = TextEditingController();
  final _new = TextEditingController();
  final _again = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Change Password'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 24), children: [
            PasswordField(label: 'Current Password', hint: 'Enter Current Password', controller: _cur, validator: requiredV),
            PasswordField(
              label: 'New Password',
              hint: 'Enter New Password',
              controller: _new,
              validator: (v) {
                if (v == null || v.length < 6) return 'Use at least 6 characters';
                if (v == _cur.text) return 'Choose a password you haven’t used';
                return null;
              },
            ),
            PasswordField(
              label: 'Re-type New Password',
              hint: 'Enter Re-type New Password',
              controller: _again,
              validator: (v) => v != _new.text ? 'Passwords don’t match' : null,
            ),
            const SizedBox(height: 100),
            ZButton('Update Password', onPressed: () {
              if (!_form.currentState!.validate()) return;
              Navigator.pop(context);
              toast(context, 'Password updated.');
            }),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => pushRoot(context, const ForgotPasswordScreen()),
                child: Text('Forgot your Password', style: p(13.5)),
              ),
            ),
          ]),
        ),
      );
}

// ─── Figma p40 — Notifications ───────────────────────────────────────────

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  AppState? _s;

  @override
  void dispose() {
    // Mark as read once the user has seen the list.
    final s = _s;
    if (s != null) WidgetsBinding.instance.addPostFrameCallback((_) => s.markNotificationsRead());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = _s = AppScope.of(context);
    return Scaffold(
      appBar: const ZAppBar('Notifications'),
      body: !s.notificationsOn
          ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Text('Notifications are turned off in Settings.', style: p(13.5, c: Z.sub))))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: s.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final n = s.notifications[i];
                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 12, 12, 12),
                  decoration: BoxDecoration(
                    color: n.unread ? const Color(0xFFFFFAF7) : Colors.white,
                    border: Border.all(color: n.unread ? Z.orange : const Color(0xFFCFCFCF)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const CircleAvatar(radius: 13, backgroundColor: Z.orange, child: Icon(Icons.notifications, size: 15, color: Colors.white)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n.title, style: p(12, w: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(n.body, style: p(11.5, c: const Color(0xFF444444))),
                        const SizedBox(height: 4),
                        Text(n.time, style: p(11.5, w: FontWeight.w600)),
                      ]),
                    ),
                  ]),
                );
              },
            ),
    );
  }
}
