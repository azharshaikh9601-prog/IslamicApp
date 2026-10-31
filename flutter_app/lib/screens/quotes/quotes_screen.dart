import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/quote_model.dart';
import '../../services/storage_service.dart';

class QuotesScreen extends StatefulWidget {
  const QuotesScreen({super.key});

  @override
  State<QuotesScreen> createState() => _QuotesScreenState();
}

class _QuotesScreenState extends State<QuotesScreen> {
  void _shareQuote(QuoteModel quote) {
    Share.share(
      '🌙 ${quote.category} | Hafiz Hasnain Jaani\n\n'
      '${quote.arabic}\n\n'
      'اردو: ${quote.urdu}\n\n'
      'English: ${quote.english}\n\n'
      '📖 Reference: ${quote.reference}\n\n'
      'Official App: https://hafizhasnainjaani.com',
    );
  }

  void _showPosterDialog(QuoteModel quote) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkEmerald,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.3),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poster Graphic Area
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF032B1F), Color(0xFF01140E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    // Scholar Header in Poster
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.primaryGold, width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/logo.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Hafiz Hasnain Jaani',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '@HAFIZHASNAINJAANI',
                              style: TextStyle(
                                color: AppColors.primaryGold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Arabic Calligraphy
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceEmerald,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        quote.arabic,
                        style: AppTheme.arabicStyle.copyWith(fontSize: 22),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Urdu Translation
                    Text(
                      quote.urdu,
                      style: AppTheme.urduStyle.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    // Reference
                    Text(
                      '— ${quote.reference}',
                      style: const TextStyle(
                        color: AppColors.lightGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Poster Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _shareQuote(quote);
                        },
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text('Share to WhatsApp Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.darkEmerald,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Admin dialog: Post New Quote (Only accessible to Admin)
  void _showPostQuoteDialog(BuildContext context, AppStateService appState) {
    final arabicCtrl = TextEditingController();
    final urduCtrl = TextEditingController();
    final engCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    String category = 'Daily Hadith';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkEmerald,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primaryGold, width: 1.5),
          ),
          title: Row(
            children: const [
              Icon(Icons.edit_note, color: AppColors.primaryGold, size: 24),
              SizedBox(width: 8),
              Text(
                'Admin: Post Sacred Quote',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: arabicCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    labelText: 'Arabic Text (الحدیث / الآیۃ)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: urduCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Urdu Translation (اردو ترجمہ)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: engCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'English / Roman Meaning',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                TextField(
                  controller: refCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Reference (e.g. Sahih Al-Bukhari 5027)',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.borderEmerald)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: AppColors.darkEmerald,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: AppColors.lightGold),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Daily Hadith', child: Text('📗 Daily Hadith')),
                    DropdownMenuItem(value: 'Quranic Ayah', child: Text('📖 Quranic Ayah')),
                    DropdownMenuItem(value: 'Golden Saying', child: Text('💎 Golden Saying')),
                    DropdownMenuItem(value: 'Sunnah Habit', child: Text('🌿 Sunnah Habit')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () {
                if (urduCtrl.text.trim().isEmpty && arabicCtrl.text.trim().isEmpty) return;

                final newQuote = QuoteModel(
                  id: 'quote-${DateTime.now().millisecondsSinceEpoch}',
                  category: category,
                  arabic: arabicCtrl.text.trim().isEmpty ? 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ' : arabicCtrl.text.trim(),
                  urdu: urduCtrl.text.trim(),
                  english: engCtrl.text.trim(),
                  reference: refCtrl.text.trim().isEmpty ? 'Islamic Reference' : refCtrl.text.trim(),
                  likes: 1,
                );
                appState.addQuote(newQuote);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✓ Quote successfully published to community!'),
                    backgroundColor: AppColors.darkEmerald,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGold,
                foregroundColor: AppColors.darkEmerald,
              ),
              child: const Text('Post Quote', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateService();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, child) {
        final quotes = appState.quotes;

        return Column(
          children: [
            // Top Header Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Daily Islamic Quotes & Hadith',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Authentic sayings & spiritual reminders for daily reflection',
                        style: TextStyle(
                          color: AppColors.darkTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  // Admin-Only Post Button (Visible ONLY when isAdmin is true)
                  if (appState.isAdmin)
                    ElevatedButton.icon(
                      onPressed: () => _showPostQuoteDialog(context, appState),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('+ Post Quote'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGold,
                        foregroundColor: AppColors.darkEmerald,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Clean Quotes Cards List (No category buttons above)
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: quotes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final quote = quotes[index];
                  return _buildQuoteCard(context, quote);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuoteCard(BuildContext context, QuoteModel quote) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderEmerald),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category & Save Poster Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceEmerald,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryGold.withOpacity(0.3)),
                ),
                child: Text(
                  quote.category,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showPosterDialog(quote),
                icon: const Icon(Icons.image_outlined, size: 14),
                label: const Text('Status Poster'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceEmerald,
                  foregroundColor: AppColors.lightGold,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppColors.borderEmerald),
                  ),
                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  elevation: 0,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Arabic Text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF07241A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              quote.arabic,
              style: AppTheme.arabicStyle.copyWith(
                fontSize: 20,
                color: Colors.white,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          const SizedBox(height: 12),

          // Urdu Translation
          Text(
            quote.urdu,
            style: AppTheme.urduStyle.copyWith(
              fontSize: 15,
              color: AppColors.lightGold,
              height: 1.6,
            ),
            textDirection: TextDirection.rtl,
          ),

          const SizedBox(height: 8),

          // English Translation
          Text(
            quote.english,
            style: const TextStyle(
              color: AppColors.darkTextSecondary,
              fontSize: 12.5,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 12),

          // Reference & Share Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '— ${quote.reference}',
                style: const TextStyle(
                  color: AppColors.darkTextMuted,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: AppColors.primaryGold, size: 18),
                onPressed: () => _shareQuote(quote),
                tooltip: 'Share Quote',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
