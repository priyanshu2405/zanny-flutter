import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data.dart';
import '../state.dart';
import '../theme.dart';
import '../widgets.dart';
import 'reserve.dart';

// ─── Shared building blocks for the long content pages ───────────────────

class _Page extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? bottom;
  const _Page({required this.title, required this.children, this.bottom});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: ZAppBar(title),
        body: ListView(padding: const EdgeInsets.only(bottom: 20), children: [
          ...children,
          if (bottom != null) Padding(padding: const EdgeInsets.fromLTRB(12, 20, 12, 0), child: bottom),
        ]),
      );
}

class _Hero extends StatelessWidget {
  final String image;
  const _Hero(this.image);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 0),
        child: Container(
          height: 168,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: Z.border)),
          child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
        ),
      );
}

class _Block extends StatelessWidget {
  final List<Widget> children;
  final bool grey;
  const _Block(this.children, {this.grey = false});
  @override
  Widget build(BuildContext context) => Container(
        color: grey ? Z.grey : null,
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

Widget _h(String t, {double size = 15, double top = 0}) =>
    Padding(padding: EdgeInsets.only(top: top, bottom: 6), child: Text(t, style: p(size, w: FontWeight.w600)));
Widget _body(String t) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t, style: p(13, h: 1.55, c: const Color(0xFF333333))));

/// "• Title" followed by a description line (Why Celebrate With Us?, etc.).
Widget _feature(String title, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(left: 6), child: Text('•  $title', style: p(13.5, w: FontWeight.w500))),
        Text(text, style: p(13, h: 1.5, c: const Color(0xFF333333))),
      ]),
    );

Widget _bookNow(BuildContext context, String eventType) =>
    ZButton('Book Now', height: 50, fontSize: 18, onPressed: () => pushRoot(context, PartyBookingScreen(eventType: eventType)));

// ─── Figma p6 — Training classes ─────────────────────────────────────────

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _Page(
      title: 'Training classes',
      bottom: Column(children: [
        ZButton('Enroll Now', height: 50, fontSize: 18, onPressed: () => pushRoot(context, const EnrollScreen())),
        const SizedBox(height: 14),
        ZButton('Contact Us', outlined: true, height: 50, fontSize: 18, onPressed: () => pushTab(context, const ContactScreen())),
      ]),
      children: [
        _Block([
          _h('Discover the Art of Ceramics'),
          _body(
              'Whether you\'re a complete beginner or an experienced artist looking to refine your skills, our ceramic training programs are designed to inspire creativity and build confidence. Learn from experienced instructors through hands-on workshops, guided projects, and personalized support.'),
          _h('Available in both Online and Offline Formats', size: 14),
        ]),
        const ThickDivider(),
        _Block([
          _h('Online Classes'),
          _body('Learn ceramic art from the comfort of your home through live interactive sessions and on-demand lessons.'),
          _h("What's Included:", size: 14, top: 8),
          const Bullets([
            'Live instructor-led classes',
            'Recorded sessions for review',
            'Step-by-step demonstrations',
            'Digital learning materials',
            'Q&A support',
            'Certificate of Completion',
          ], gap: 0),
        ]),
        const ThickDivider(),
        _Block([
          _h('Offline Workshops'),
          _body('Experience hands-on learning in a creative studio environment with direct guidance from expert ceramic artists.'),
          _h("What's Included:", size: 14, top: 8),
          const Bullets([
            'Practical studio sessions',
            'Access to tools and equipment',
            'Clay preparation techniques',
            'Wheel throwing and hand-building',
            'Glazing and finishing methods',
            'Small group instruction',
          ], gap: 0),
          _h('Courses We Offer', top: 14),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 6.2,
            children: [
              for (final c in courses)
                Material(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(3),
                  child: InkWell(
                    onTap: () => pushRoot(context, EnrollScreen(course: c)),
                    child: Center(child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis, style: p(11))),
                  ),
                ),
            ],
          ),
          _h('Sample Classes', top: 18),
          for (final (image, caption) in [
            (img('class1'), 'Kids pottery painting: brush techniques and layering colour.'),
            (img('class2'), 'Wheel throwing basics: centring, opening and pulling up the walls.'),
          ]) ...[
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => toast(context, 'Video playback will connect to the class library.'),
              child: AspectRatio(
                aspectRatio: 1.9,
                child: Stack(fit: StackFit.expand, children: [
                  ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.asset(image, fit: BoxFit.cover)),
                  const Center(
                    child: CircleAvatar(radius: 22, backgroundColor: Z.orange, child: Icon(Icons.play_arrow, color: Colors.white, size: 28)),
                  ),
                ]),
              ),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(0, 8, 0, 14), child: Text(caption, style: p(13))),
          ],
          _h('Ready to Start Your Creative Journey?', top: 8),
          _body(
              'Join the pottery and ceramic classes at Zany Pottery & Glass and discover the joy of creating something truly unique with your own hands.'),
        ]),
      ],
    );
  }
}

// ─── Figma p7 — Parties & Special Events ─────────────────────────────────

class PartiesScreen extends StatelessWidget {
  const PartiesScreen({super.key});
  @override
  Widget build(BuildContext context) => _Page(
        title: 'Parties & Special Events',
        bottom: _bookNow(context, partyEventTypes.first),
        children: [
          _Hero(img('parties')),
          _Block([
            _h('Parties & Special Events', size: 14),
            _body(
                'Make your next celebration truly memorable at Zany Pottery & Glass. Whether you\'re planning a birthday party, team-building event, bridal shower, or private gathering, we offer fun and interactive creative experiences that bring people together.'),
            _body(
                'Our pottery, clay building, and glass fusion activities create lasting memories while giving every guest a unique handmade keepsake to take home.'),
          ]),
          _Block(grey: true, [
            _h('Why Celebrate With Us?'),
            const SizedBox(height: 6),
            _feature('Fun for All Ages', 'From young children to adults, our creative experiences are designed for everyone.'),
            _feature('Unique & Memorable', 'Skip the ordinary party venues and create something meaningful together.'),
            _feature('Guided Experiences', 'Our friendly instructors help guests enjoy the creative process regardless of skill level.'),
            _feature('Handmade Keepsakes', 'Every guest leaves with a personalized creation they\'ll cherish.'),
            _feature('Private Event Spaces', 'Comfortable studio spaces designed for celebrations, gatherings, and special occasions.'),
          ]),
          _Block([
            _h("What's Included?"),
            const Bullets([
              'Creative Activity Experience',
              'Access to Studio Space',
              'Professional Guidance',
              'Materials & Supplies',
              'Kiln Firing (where applicable)',
              'Finished Project Pickup',
              'Friendly Event Support',
            ], gap: 2),
          ]),
          const ThickDivider(),
          _Block([
            Text('Create unforgettable memories with a unique hands-on experience', style: p(13.5)),
            const SizedBox(height: 8),
            const Bullets([
              'Kids Birthday parties',
              'Adult Birthday parties',
              'Private parties & Showers',
              'School & Group Events',
              'Team Building Event',
              'Bridal Shower',
              'Baby Shower',
              'Private Workshop',
              'School Group',
            ], gap: 2),
            _h('Event Gallery', top: 12),
            GalleryGrid([for (var i = 1; i <= 6; i++) img('party_g$i')]),
          ]),
        ],
      );
}

// ─── Figma p8 — Kids Programs ────────────────────────────────────────────

class KidsProgramsScreen extends StatelessWidget {
  const KidsProgramsScreen({super.key});
  @override
  Widget build(BuildContext context) => _Page(
        title: 'Kids Programs',
        children: [
          _Hero(img('kids')),
          _Block([
            _h('Kids Programs', size: 14),
            Text('Inspiring Creativity Through Art, Clay & Imagination', style: p(12.5, w: FontWeight.w500)),
            const SizedBox(height: 8),
            _body(
                'At Zany Pottery & Glass, we believe every child is an artist. Our Kids Programs are designed to encourage creativity, build confidence, and provide hands-on learning experiences through pottery, clay handbuilding, glass fusion, and creative art activities.'),
            _body(
                'Whether your child is discovering clay for the first time or already loves creating, our programs offer a fun, welcoming environment where imagination can flourish.'),
          ]),
          _Block(grey: true, [
            _h('Why Choose Our Kids Programs?'),
            const SizedBox(height: 6),
            _feature('Hands-On Learning', 'Children learn by creating. Our projects encourage exploration, problem-solving, and self-expression through art.'),
            _feature('Build Confidence', 'Every finished project gives children a sense of accomplishment and pride in their work.'),
            _feature('Develop Creative Skills', 'Students learn artistic techniques while improving focus, patience, and fine motor skills.'),
            _feature('Screen-Free Fun', 'Our programs provide a creative and engaging alternative to screen time.'),
            _feature('Make New Friends', 'Children connect with other young artists in a supportive and encouraging environment.'),
          ]),
          _Block([
            _h('After School Programs'),
            _body(
                'Our After School Programs offer children a chance to unwind, explore their creativity, and learn new artistic skills in a fun and structured setting.'),
            _h('Activities Include:', size: 14, top: 4),
            const Bullets([
              'Pottery Wheel Projects',
              'Clay Handbuilding',
              'Pottery Painting',
              'Glass Fusion Projects',
              'Seasonal Art Activities',
              'Creative Challenges',
            ], gap: 0),
            const SizedBox(height: 6),
            Text('Programs Available For Suitable Ages 5–14 Years', style: p(13)),
            const SizedBox(height: 10),
            SmallBtn('BOOK NOW', width: 120, onTap: () => pushRoot(context, const PartyBookingScreen(eventType: 'After School Program'))),
          ]),
          const ThickDivider(),
          _Block([
            _h('Summer Camps'),
            _body('Our Summer Camps are packed with exciting hands-on projects that keep children engaged, learning, and having fun.'),
            _h('Camp Activities:', size: 14, top: 4),
            const Bullets([
              'Pottery Wheel Experiences',
              'Clay Handbuilding Projects',
              'Glass Fusion Art',
              'Pottery Painting',
              'Themed Art Challenges',
              'Collaborative Group Projects',
            ], gap: 0),
            const SizedBox(height: 6),
            Text('Programs Available For Different Age Groups', style: p(13)),
            const SizedBox(height: 10),
            SmallBtn('BOOK NOW', width: 120, onTap: () => pushRoot(context, const PartyBookingScreen(eventType: 'Summer Camp'))),
          ]),
          const ThickDivider(),
          _Block([
            _h('Gallery of Young Artists'),
            _body(
                'See the incredible pottery, clay creations, and glass fusion artwork made by our young artists throughout the year. Every masterpiece tells a unique story and celebrates the creativity of its creator.'),
            const SizedBox(height: 6),
            GalleryGrid([for (var i = 1; i <= 6; i++) img('kids_g$i')]),
          ]),
        ],
      );
}

// ─── Figma p9 — Team Building ────────────────────────────────────────────

class TeamBuildingScreen extends StatelessWidget {
  const TeamBuildingScreen({super.key});
  static const _benefits = [
    'Improve Team Communication',
    'Encourage Creative Thinking',
    'Strengthen Workplace Relationships',
    'Boost Employee Engagement',
    'Reduce Stress & Improve Morale',
    'Create Lasting Memories',
  ];
  @override
  Widget build(BuildContext context) => _Page(
        title: 'Team Building',
        bottom: _bookNow(context, 'Team Building'),
        children: [
          _Hero(img('team_hero')),
          _Block([
            _h('Team Building', size: 14),
            _body(
                'Looking for a unique and engaging team-building experience? At Zany Pottery & Glass, we help teams connect, collaborate, and create through hands-on pottery, clay building, and glass fusion activities.'),
            _body(
                'Step away from the office and enjoy a fun, interactive experience that encourages communication, creativity, and teamwork while creating something meaningful together.'),
          ]),
          _Block(grey: true, [
            _h('Why Choose Creative Team Building?'),
            _body(
                'Traditional team-building activities often focus on competition. Our creative workshops focus on collaboration, communication, and shared experiences that bring people together in a relaxed and enjoyable environment.'),
            const SizedBox(height: 4),
            const Bullets(_benefits, weight: FontWeight.w500, gap: 2),
          ]),
          _Block([
            _h('Custom Corporate Events'),
            _body('Every organization is different. We can customize your event based on your team size, objectives, schedule, and budget.'),
            _h('Popular Corporate Events', size: 14, top: 6),
            const Bullets([
              'Staff Appreciation Events',
              'Holiday & Year-End Parties',
              'New Team Onboarding',
              'Leadership Retreats',
              'Client Appreciation Nights',
              'Wellness Days',
            ], weight: FontWeight.w500, gap: 2),
          ]),
          const ThickDivider(),
          _Block([
            _h("What's Included?"),
            const Bullets([
              'Professional Instruction',
              'All Materials & Supplies',
              'Pottery, Clay, or Glass Activities',
              'Event Coordination',
              'Creative Workspace',
              'Finished Project Processing',
              'Project Pickup Notifications',
            ], gap: 2),
          ]),
          const ThickDivider(),
          _Block([
            _body('Our creative team-building experiences encourage collaboration, creativity, and connection in a relaxed environment.'),
            const Bullets(['Boost Communication', 'Encourage Collaboration', 'Spark Creativity', 'Create Lasting Memories'], gap: 2),
            _h('Event Gallery', top: 10),
            GalleryGrid([img('team_g1'), img('team_g2'), img('team_g3'), img('team_g4'), img('team_g5'), img('team')]),
          ]),
        ],
      );
}

// ─── Figma p38 — About Us ────────────────────────────────────────────────

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => _Page(
        title: 'About Us',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
            child: Align(alignment: Alignment.centerLeft, child: Image.asset(logoAsset, height: 40)),
          ),
          _Block([
            _body(
                'Welcome to Zany Pottery & Glass, where creativity, craftsmanship, and passion come together to create exceptional ceramic and glass products. We are dedicated to designing and curating unique handcrafted pieces that bring beauty, functionality, and personality into everyday life.'),
            const SizedBox(height: 6),
            _body(
                'From elegant home décor and functional tableware to thoughtful gifts and custom creations, our collections are designed to celebrate artistry and inspire meaningful connections. Beyond our products, we are passionate about sharing our knowledge through engaging pottery and ceramic training classes for creators of all skill levels.'),
            _h('OUR MISSION', size: 14, top: 8),
            _body(
                'To create beautifully crafted pottery and glass products while fostering creativity through education, innovation, and meaningful artistic experiences.'),
            _h('OUR VISION', size: 14, top: 8),
            _body(
                'To become a trusted destination for handcrafted pottery, glass artistry, and creative learning by inspiring people to appreciate the beauty of handmade craftsmanship.'),
          ]),
        ],
      );
}

// ─── Figma p39 — Contact Us ──────────────────────────────────────────────

class ContactScreen extends StatefulWidget {
  final String? message;
  const ContactScreen({super.key, this.message});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _form = GlobalKey<FormState>();
  late final AppState _s = AppScope.read(context);
  late final _name = TextEditingController(text: _s.loggedIn ? _s.name : '');
  late final _email = TextEditingController(text: _s.loggedIn ? _s.email : '');
  late final _mobile = TextEditingController(text: _s.loggedIn ? _s.phone : '');
  late final _msg = TextEditingController(text: widget.message ?? '');

  Widget _info(IconData icon, String title, String value, {VoidCallback? onTap, Widget? extra}) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: p(15, w: FontWeight.w500)),
              InkWell(onTap: onTap, child: Text(value, style: p(12.5, c: const Color(0xFF333333)))),
              if (extra != null) ...[const SizedBox(height: 6), extra],
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Contact Us'),
        body: ListView(padding: const EdgeInsets.fromLTRB(14, 4, 14, 24), children: [
          Form(
            key: _form,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              ZField(label: 'Full Name', hint: 'Enter Full Name', controller: _name, validator: requiredV),
              ZField(label: 'Email', hint: 'Enter Email', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
              ZField(label: 'Mobile', hint: 'Enter Mobile', controller: _mobile, keyboard: TextInputType.phone, validator: phoneV),
              ZField(label: 'Message', hint: 'Enter your message', controller: _msg, maxLines: 5, validator: requiredV),
            ]),
          ),
          const SizedBox(height: 16),
          ZButton('Submit', onPressed: () {
            if (!_form.currentState!.validate()) return;
            _msg.clear();
            FocusScope.of(context).unfocus();
            toast(context, 'Thanks! We’ll get back to you within one business day.');
          }),
          const SizedBox(height: 12),
          Center(child: Text('OR', style: p(13))),
          const SizedBox(height: 16),
          _info(Icons.place_outlined, 'Office Address', Studio.address,
              extra: OutlinedButton(
                onPressed: () => openUrl(context, Studio.directions),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  side: const BorderSide(color: Z.text),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                ),
                child: Text('GET DIRECTIONS', style: p(10, c: Z.text)),
              )),
          _info(Icons.mail_outline, 'Email Address', Studio.email, onTap: () => openUrl(context, 'mailto:${Studio.email}')),
          _info(Icons.phone_in_talk_outlined, 'Phone Number', Studio.phone, onTap: () => openUrl(context, Studio.phoneUri)),
        ]),
      );
}

// ─── Privacy Policy / Terms (linked from Settings) ───────────────────────

class PolicyScreen extends StatelessWidget {
  final String title;
  final bool terms;
  const PolicyScreen({super.key, required this.title, this.terms = false});

  @override
  Widget build(BuildContext context) {
    final sections = terms
        ? const [
            ('Bookings & deposits', 'Party and private event bookings require a non-refundable deposit to hold your date. Deposits are applied to your final balance.'),
            ('Reservations', 'Table reservations are held for 15 minutes after the scheduled start time.'),
            ('Finished pieces', 'Project completion and pickup times vary with firing and finishing. We’ll notify you when your piece is ready.'),
            ('Studio safety', 'All guests must follow studio safety guidelines and staff instructions.'),
            ('Orders', 'Online orders ship within the times shown at checkout. Contact us within 7 days of delivery about damaged items.'),
          ]
        : const [
            ('What we collect', 'Your name, email, phone number, address and booking or order details.'),
            ('How we use it', 'To confirm bookings and orders, send pickup notifications and, if you opt in, share studio news.'),
            ('Your photos', 'Pictures you upload to “My Pictures” are only used to match finished pieces to your account.'),
            ('Your choices', 'Turn off notifications in Settings or contact us to update or delete your information.'),
          ];
    return Scaffold(
      appBar: ZAppBar(title),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Last updated ${DateFormat('MMMM d, yyyy').format(DateTime(2026, 6, 1))}', style: p(12, c: Z.sub)),
        for (final (h, b) in sections) ...[
          _h(h, top: 16),
          _body(b),
        ],
        const SizedBox(height: 12),
        Text('Placeholder text for the prototype — replace with the studio’s legal copy.', style: p(11.5, c: Z.sub)),
      ]),
    );
  }
}

// ─── Enroll in a training class (Enroll Now) ─────────────────────────────

class EnrollScreen extends StatefulWidget {
  final String? course;
  const EnrollScreen({super.key, this.course});
  @override
  State<EnrollScreen> createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  final _form = GlobalKey<FormState>();
  late String _course = widget.course ?? courses.first;
  String _format = 'Offline Workshop';
  DateTime? _start;
  late final AppState _s = AppScope.read(context);
  late final _name = TextEditingController(text: _s.name);
  late final _email = TextEditingController(text: _s.email);
  late final _phone = TextEditingController(text: _s.phone);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const ZAppBar('Enroll Now'),
        body: Form(
          key: _form,
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 4, 12, 24), children: [
            const SectionHeading('Class Information'),
            ZDropdown(label: 'Course', value: _course, items: courses, onChanged: (v) => setState(() => _course = v)),
            const FormLabel('Format'),
            for (final f in ['Offline Workshop', 'Online Class'])
              RadioListTile<String>(
                value: f,
                groupValue: _format,
                onChanged: (v) => setState(() => _format = v!),
                title: Text(f, style: p(14)),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            DateField(label: 'Preferred Start Date', value: _start, onPicked: (d) => setState(() => _start = d)),
            const SectionHeading('Contact Information'),
            ZField(label: 'Full Name', controller: _name, validator: requiredV),
            ZField(label: 'Email Address', controller: _email, keyboard: TextInputType.emailAddress, validator: emailV),
            ZField(label: 'Phone Number', controller: _phone, keyboard: TextInputType.phone, validator: phoneV),
            const SizedBox(height: 28),
            ZButton('Submit', onPressed: () {
              if (_start == null) return toast(context, 'Choose a preferred start date.');
              if (!_form.currentState!.validate()) return;
              final b = _s.addBooking('Training: $_course', _start!, _format);
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingDoneScreen(booking: b)));
            }),
          ]),
        ),
      );
}
