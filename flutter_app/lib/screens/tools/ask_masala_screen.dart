import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class AskMasalaScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const AskMasalaScreen({super.key, this.onBack});

  @override
  State<AskMasalaScreen> createState() => _AskMasalaScreenState();
}

class _AskMasalaScreenState extends State<AskMasalaScreen> {
  final _nameCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cityCtrl.dispose();
    _questionCtrl.dispose();
    super.dispose();
  }

  String _formatMessage() {
    final name = _nameCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final q = _questionCtrl.text.trim();

    return 'Assalamu Alaikum wa Rahmatullahi wa Barakatuh\n'
        'Hazrat Hafiz Hasnain Jaani Sahab,\n\n'
        '👤 Name / नाम: ${name.isNotEmpty ? name : "Seeker of Knowledge"}\n'
        '📍 City / शहर: ${city.isNotEmpty ? city : "India"}\n\n'
        '❓ Mas\'ala / सवाल:\n$q\n\n'
        '--- Sent via Hafiz Hasnain Jaani Official Islamic App ---';
  }

  Future<void> _submitToWhatsApp() async {
    final q = _questionCtrl.text.trim();

    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your question or Mas’ala! / कृपया अपना सवाल लिखें!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final text = _formatMessage();
    final encoded = Uri.encodeComponent(text);
    final uri = Uri.parse('https://wa.me/919241299847?text=$encoded');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp. Please check your connection.'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error launching WhatsApp.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _copyDraftMessage() {
    final q = _questionCtrl.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write your question first! / पहले अपना सवाल लिखें!'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Clipboard.setData(ClipboardData(text: _formatMessage()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied to clipboard! / संदेश कॉपी हो गया!'),
        backgroundColor: Color(0xFF1B6B4E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF031E16),
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryGold, size: 20),
                onPressed: widget.onBack,
              )
            : null,
        title: Row(
          children: const [
            Icon(Icons.question_answer_rounded, color: AppColors.primaryGold, size: 20),
            SizedBox(width: 8),
            Text(
              "Ask Mas'ala (सवाल पूछें)",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        children: [
          // 1. Scholar Office Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0C241C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold.withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryGold, width: 1.5),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Flexible(
                            child: Text(
                              'Hafiz Hasnain Jaani',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.check_circle, color: AppColors.brightGold, size: 14),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Direct Deeni Guidance & Masail Consultation',
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Purnia, Bihar • Fiqh-e-Hanafi Consultation',
                        style: TextStyle(
                          color: AppColors.darkTextMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. IMPORTANT NOTICE (English & Hindi)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0E2E23), Color(0xFF071F17)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryGold, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: AppColors.brightGold, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Important Notice • ज़रूरी सूचना',
                      style: TextStyle(
                        color: AppColors.brightGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // English Notice
                const Text(
                  '“Please describe your question or Mas\'ala clearly and in complete detail. I will personally review your question and try my best to provide you with appropriate Islamic guidance. Please be patient, as a response may take some time.”',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.borderEmerald, thickness: 1),
                ),
                // Hindi Notice
                const Text(
                  '“कृपया अपना सवाल या दीन से जुड़ा मसला पूरी जानकारी और साफ़ शब्दों में लिखें। मैं खुद आपके सवाल को पढ़कर सही इस्लामी जानकारी देने की पूरी कोशिश करूँगा। जवाब मिलने में कुछ समय लग सकता है, इसलिए कृपया इंतज़ार करें।”',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. Question Form
          const Text(
            'Submit Your Mas’ala / सवाल पूछें',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // Name Field (English & Hindi)
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              labelText: 'Your Name (आपका नाम)',
              hintText: 'Enter your full name / अपना नाम लिखें',
              hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primaryGold, size: 18),
              filled: true,
              fillColor: AppColors.darkCard,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // City Field (English & Hindi)
          TextField(
            controller: _cityCtrl,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              labelText: 'Your City / District (शहर व ज़िला)',
              hintText: 'e.g. Purnia, Delhi, Patna / अपना शहर लिखें',
              hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGold, size: 18),
              filled: true,
              fillColor: AppColors.darkCard,
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Question Field (English & Hindi)
          TextField(
            controller: _questionCtrl,
            maxLines: 5,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              labelText: "Your Question or Mas'ala (अपना सवाल या मसला लिखें)",
              hintText: "Describe your religious question in detail...\nअपना मसला विस्तार से लिखें...",
              hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 12),
              alignLabelWithHint: true,
              labelStyle: const TextStyle(color: AppColors.lightGold, fontSize: 12),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 70),
                child: Icon(Icons.help_outline_rounded, color: AppColors.primaryGold, size: 18),
              ),
              filled: true,
              fillColor: AppColors.darkCard,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderEmerald),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 4. Enhanced Send via WhatsApp Option
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isSubmitting ? null : _submitToWhatsApp,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF25D366).withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Circular WhatsApp Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Titles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  _isSubmitting ? 'Opening WhatsApp...' : 'Send via WhatsApp',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Direct',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Desk: +91 92412 99847 • सीधे व्हाट्सएप पर भेजें',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Forward Send Indicator
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFF128C7E),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Secondary Quick Actions: Copy Draft
          Center(
            child: TextButton.icon(
              onPressed: _copyDraftMessage,
              icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.lightGold),
              label: const Text(
                'Copy Formatted Message / संदेश कॉपी करें',
                style: TextStyle(color: AppColors.lightGold, fontSize: 11.5, fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Privacy & Direct Desk Trust Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF0C241C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderEmerald.withOpacity(0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(Icons.verified_user_rounded, color: AppColors.primaryGold, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Private & Confidential: Your question is sent directly to Hazrat Hafiz Hasnain Jaani\'s official WhatsApp desk (+91 92412 99847).\nसुरक्षित व गोपनीय: आपका सवाल सीधे हज़रत के आधिकारिक डेस्क पर जाएगा।',
                    style: TextStyle(
                      color: AppColors.darkTextMuted,
                      fontSize: 10.5,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
